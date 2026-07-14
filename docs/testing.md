# Testing

This repository uses `scripts/check_ci.sh` as the default local validation gate.

```bash
scripts/check_ci.sh
```

The gate runs:

- `moon check`
- `moon check --warn-list +73`
- `moon test --release`
- `moon build`
- `scripts/check_examples_build.sh`
- `scripts/check_ffi_surface.sh`
- `scripts/check_monitor_thread_boundary.sh`

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
