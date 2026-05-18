# Testing

This repository uses `scripts/check_ci.sh` as the default local validation gate.

```bash
scripts/check_ci.sh
```

The gate runs:

- `moon check`
- `moon check --warn-list +73`
- `moon test core`
- `moon test dpi`
- `moon test --build-only`
- `moon build`
- `scripts/check_examples_build.sh`
- `scripts/check_ffi_surface.sh`

`moon test --build-only` is intentional for the macOS package. The current
MoonBit native test runner executes generated native tests through `tcc -run`,
and that path does not currently pass macOS framework arguments such as
`-framework AppKit` in a way `tcc -run` accepts. The failure mode is:

```text
tcc: error: file 'AppKit' not found
```

That is a toolchain/native-runner execution limitation, not evidence that the
macOS package fails to compile. The same limitation can affect AppKit-linked
examples when they are executed through `moon run --target native`. Until the
runner supports framework-linked native execution on macOS, the repository gate
verifies macOS tests and examples with build-only commands and keeps executable
unit tests on packages that do not need AppKit framework execution.

For upstream-vs-MoonBit example transcript parity, run the slower optional gate
only in an environment where `moon run --target native` can execute
AppKit-linked examples:

```bash
RUN_EXAMPLE_TRANSCRIPTS=1 scripts/check_ci.sh
```

This runs `scripts/check_example_transcripts.sh`, normalizes unstable prefixes,
ANSI sequences, timestamps, IDs, and addresses, then performs a strict diff on
the remaining message bodies.
