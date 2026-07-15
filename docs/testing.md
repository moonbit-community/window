# Testing

This repository uses `scripts/check_ci.sh` as the default local validation gate.

```bash
scripts/check_ci.sh
```

The gate runs:

- `moon fmt --check`
- `moon check`
- `moon check --warn-list +73`
- `moon test --release`
- `moon build`
- `scripts/check_examples_build.sh`
- `scripts/check_ffi_surface.sh`
- `scripts/check_event_loop_thread_boundary.sh`
- `scripts/check_monitor_thread_boundary.sh`
- `scripts/check_window_thread_boundary.sh`

`moon test --release` is intentional for this repository. On macOS, the default
debug test runner can still execute generated native tests through a `tcc -run`
path that does not pass framework arguments such as `-framework AppKit` in a way
`tcc -run` accepts. The failure mode is:

```text
tcc: error: file 'AppKit' not found
```

That is a debug/native-runner limitation, not evidence that the macOS package
fails. Release mode is the reliable local executable test gate and currently
runs the AppKit-linked macOS white-box tests.

`scripts/check_asan.py` rebuilds the macOS package in isolated MoonBit and
target directories with one compiler wrapper that injects AddressSanitizer into
the runtime, generated C, native stubs, and final links. It rejects a run unless
`libmacos.a` contains ASan instrumentation and every macOS test executable links
the ASan runtime. Leak detection is disabled by default because this gate checks
address safety, not process-exit reachability; override `MBW_ASAN_OPTIONS` when
investigating leaks. Passing ASan is dynamic evidence for the paths exercised by
the tests, not a proof that all memory usage is safe.

Run the ASan-enabled gate explicitly with:

```bash
RUN_ASAN=1 scripts/check_ci.sh
```

GitHub CI enables this mode on its macOS 14 runner. If the host compiler can
link ASan but its runtime cannot start, the executable probe fails the gate;
the script never treats build-only instrumentation as a passing ASan run.

Examples are still built with `scripts/check_examples_build.sh` because they are
interactive AppKit applications. Use the optional transcript gate when validating
example output behavior.

For upstream-vs-MoonBit example transcript parity, run the slower optional gate:

```bash
RUN_EXAMPLE_TRANSCRIPTS=1 scripts/check_ci.sh
```

This runs `scripts/check_example_transcripts.sh`, normalizes unstable prefixes,
ANSI sequences, timestamps, IDs, and addresses, then performs a strict diff on
the remaining message bodies.
