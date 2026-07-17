#!/usr/bin/env python3
"""Run macOS native tests with verified AddressSanitizer instrumentation."""

import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


ASAN_FLAGS = ["-g", "-fsanitize=address", "-fno-omit-frame-pointer"]


def command_output(command: list[str], environment: dict[str, str]) -> str:
    return subprocess.run(
        command,
        env=environment,
        check=True,
        text=True,
        capture_output=True,
    ).stdout.strip()


def moon_home() -> Path:
    configured = os.environ.get("MOON_HOME")
    if configured:
        home = Path(configured).expanduser().resolve()
    else:
        moon = shutil.which("moon")
        if moon is None:
            raise RuntimeError("moon was not found in PATH")
        home = Path(moon).resolve().parent.parent
    if not (home / "lib" / "libmoonbitrun.o").is_file():
        raise RuntimeError(f"invalid MOON_HOME: {home}")
    return home


def verify_compiler(clang: str, sdk_root: str, directory: Path) -> Path:
    source = directory / "asan_probe.c"
    executable = directory / "asan_probe"
    source.write_text("int main(void) { return 0; }\n", encoding="utf-8")
    environment = os.environ.copy()
    environment.pop("DYLD_INSERT_LIBRARIES", None)
    environment.update(
        {"ASAN_OPTIONS": "detect_leaks=0:abort_on_error=1", "SDKROOT": sdk_root},
    )
    subprocess.run(
        [clang, *ASAN_FLAGS, str(source), "-o", str(executable)],
        env=environment,
        check=True,
        capture_output=True,
    )
    try:
        subprocess.run(
            [str(executable)],
            env=environment,
            check=True,
            capture_output=True,
            timeout=5,
        )
    except subprocess.TimeoutExpired as error:
        raise RuntimeError(
            "clang linked ASan, but its runtime did not start within five seconds"
        ) from error
    runtime = Path(
        command_output(
            [clang, "-print-file-name=libclang_rt.asan_osx_dynamic.dylib"],
            environment,
        ),
    ).resolve()
    if not runtime.is_file():
        raise RuntimeError(f"ASan runtime was not found for {clang}: {runtime}")
    return runtime


def create_moon_home_overlay(source: Path, destination: Path, clang: str) -> None:
    destination.mkdir()
    for entry in source.iterdir():
        if entry.name != "lib":
            (destination / entry.name).symlink_to(entry)
    destination_lib = destination / "lib"
    destination_lib.mkdir()
    for entry in (source / "lib").iterdir():
        if entry.name != "libmoonbitrun.o":
            (destination_lib / entry.name).symlink_to(entry)
    empty_source = destination / "empty_moonbitrun.c"
    empty_source.write_text("/* Disable mimalloc for ASan. */\n", encoding="utf-8")
    subprocess.run(
        [clang, "-c", str(empty_source), "-o", str(destination_lib / "libmoonbitrun.o")],
        check=True,
    )


def create_compiler_wrapper(path: Path) -> None:
    path.write_text(
        "#!/bin/sh\n"
        f'exec "$MBW_ASAN_REAL_CC" {" ".join(ASAN_FLAGS)} "$@"\n',
        encoding="utf-8",
    )
    path.chmod(0o755)


def verify_build(build: Path) -> tuple[int, int]:
    archives = list(build.rglob("libmacos.a"))
    if not archives:
        raise RuntimeError("ASan build did not produce libmacos.a")
    for archive in archives:
        symbols = command_output(["nm", "-u", str(archive)], os.environ.copy())
        if "asan_init" not in symbols:
            raise RuntimeError(f"native stubs are not ASan-instrumented: {archive}")

    executables = [
        path
        for path in build.rglob("*.exe")
        if "test" in path.parts
        and path.parent.name == "macos"
        and not any(part.endswith(".dSYM") for part in path.parts)
        and os.access(path, os.X_OK)
    ]
    if not executables:
        raise RuntimeError("ASan build did not produce macOS test executables")
    for executable in executables:
        libraries = command_output(["otool", "-L", str(executable)], os.environ.copy())
        if "libclang_rt.asan" not in libraries:
            raise RuntimeError(f"ASan runtime is not linked: {executable}")
        symbols = command_output(["nm", str(executable)], os.environ.copy())
        if "_mi_malloc" in symbols:
            raise RuntimeError(f"mimalloc is still linked: {executable}")
    return len(archives), len(executables)


def main() -> None:
    repository = Path(__file__).resolve().parent.parent
    environment = os.environ.copy()
    environment.pop("DYLD_INSERT_LIBRARIES", None)
    sdk_root = command_output(
        ["xcrun", "--sdk", "macosx", "--show-sdk-path"],
        environment,
    )
    clang = os.environ.get("MBW_ASAN_CC") or command_output(
        ["xcrun", "--find", "clang"],
        environment,
    )
    with tempfile.TemporaryDirectory(prefix="window-asan-") as temporary:
        temporary_path = Path(temporary)
        runtime = verify_compiler(clang, sdk_root, temporary_path)
        overlay = temporary_path / "moon-home"
        build = temporary_path / "build"
        wrapper = temporary_path / "asan-clang"
        create_moon_home_overlay(moon_home(), overlay, clang)
        create_compiler_wrapper(wrapper)
        environment.update(
            {
                "ASAN_OPTIONS": os.environ.get(
                    "MBW_ASAN_OPTIONS",
                    "detect_leaks=0:abort_on_error=1:halt_on_error=1",
                ),
                "MBW_ASAN_REAL_CC": clang,
                "MOON_AR": "/usr/bin/ar",
                "MOON_CC": str(wrapper),
                "MOON_HOME": str(overlay),
                "SDKROOT": sdk_root,
            },
        )
        print(f"ASan compiler: {clang}")
        print(f"ASan runtime: {runtime}")
        subprocess.run(
            [
                "moon",
                "test",
                "--release",
                "--target",
                "native",
                "--target-dir",
                str(build),
                "modules/window/macos",
            ],
            cwd=repository,
            env=environment,
            check=True,
        )
        archive_count, executable_count = verify_build(build)
        print(f"ASan-instrumented native archives: {archive_count}")
        print(f"ASan-linked test executables without mimalloc: {executable_count}")
        print("AddressSanitizer check passed")


if __name__ == "__main__":
    try:
        main()
    except (OSError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"AddressSanitizer check failed: {error}", file=sys.stderr)
        sys.exit(1)
