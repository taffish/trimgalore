# trimgalore

TAFFISH wrapper for [Trim Galore](https://www.trimgalore.com/), a FASTQ
adapter and quality trimmer for next-generation sequencing data. This package
wraps upstream Trim Galore v2.2.0, the Rust "Oxidized Edition".

## Package Identity

| field | value |
| --- | --- |
| name | `trimgalore` |
| command | `taf-trimgalore` |
| kind | `tool` |
| TAFFISH version | `2.2.0-r1` |
| container image | `ghcr.io/taffish/trimgalore:2.2.0-r1` |
| upstream project | `FelixKrueger/TrimGalore` |
| upstream release | `v2.2.0` |
| upstream command | `trim_galore` |
| runtime version | `trim_galore 2.2.0 (Oxidized Edition)`, commit `5846564` |
| native platforms | `linux/amd64`, `linux/arm64` |

## What Is Packaged

Trim Galore v2.2.0 is a single Rust binary. Unlike the older 0.6.x Perl
wrapper series, it does not require external `cutadapt`, Java, or an external
`fastqc` executable for the core workflows. FastQC-compatible reports are
produced by the bundled `fastqc-rust` engine when `--fastqc` is used.

This app installs the official upstream Linux release binary for the target
architecture:

- `trim_galore-linux-x86_64.tar.gz`
- `trim_galore-linux-aarch64.tar.gz`

Both release assets are checksum-verified in the Docker build. The runtime
image includes the glibc/zlib/libgcc dynamic libraries needed by the binary,
plus `bash`, `gzip`, and `unzip` for common command-line use and smoke checks.

## Usage

Show TAFFISH wrapper help:

```sh
taf-trimgalore --help
```

Show the upstream Trim Galore version:

```sh
taf-trimgalore trim_galore --version
taf-trimgalore -- --version
```

Single-end trimming:

```sh
taf-trimgalore trim_galore reads.fq.gz
taf-trimgalore trim_galore --cores 4 --output_dir trimmed reads.fq.gz
```

Paired-end trimming:

```sh
taf-trimgalore trim_galore --paired sample_R1.fq.gz sample_R2.fq.gz
taf-trimgalore trim_galore --paired --cores 8 --output_dir trimmed sample_R1.fq.gz sample_R2.fq.gz
```

RRBS mode:

```sh
taf-trimgalore trim_galore --rrbs --paired sample_R1.fq.gz sample_R2.fq.gz
taf-trimgalore trim_galore --rrbs --non_directional reads.fq.gz
```

Built-in FastQC-compatible reports:

```sh
taf-trimgalore trim_galore --fastqc reads.fq.gz
taf-trimgalore trim_galore --fastqc --fastqc_args "--nogroup --svg" reads.fq.gz
```

v2.2 clumpify compression:

```sh
taf-trimgalore trim_galore --clumpify --cores 2 reads.fq.gz
taf-trimgalore trim_galore --clumpify --compression 6 --cores 4 reads.fq.gz
```

Option-leading calls also work because `src/main.taf` directly calls the
upstream command:

```sh
taf-trimgalore --paired sample_R1.fq.gz sample_R2.fq.gz
taf-trimgalore --fastqc reads.fq.gz
```

The clearer form in documentation is still `taf-trimgalore trim_galore ...`,
because it makes the boundary between the TAFFISH wrapper and the upstream
command explicit.

## Command Mode

This is a normal TAFFISH tool app with command mode enabled. The default
command is `trim_galore`, and the same container can also be entered with
explicit commands:

```sh
taf-trimgalore trim_galore --help
taf-trimgalore bash
taf-trimgalore gzip --help
```

There is no separate `trimgalore`, `trim-galore`, `cutadapt`, or `fastqc`
executable installed by this package. The app name is `trimgalore`; the
upstream command remains `trim_galore`.

## Inputs And Outputs

Trim Galore reads FASTQ input, including plain and gzipped FASTQ. Common output
names follow upstream conventions:

- Single-end: `*_trimmed.fq` or `*_trimmed.fq.gz`
- Paired-end: `*_val_1.fq(.gz)` and `*_val_2.fq(.gz)`
- Reports: `*_trimming_report.txt` and `*_trimming_report.json`
- Built-in FastQC: `*_fastqc.html` and `*_fastqc.zip`

By default, output compression mirrors the input. Use `--dont_gzip` for plain
FASTQ output, or `--compression 1..9` for gzip output level control. `--clumpify`
requires gzip output and `--cores >= 2`.

The JSON trimming report uses upstream schema version 1 and is intended for
programmatic parsing, including MultiQC workflows.

## Feature Coverage

Packaged and smoke-tested:

- version and help surface
- single-end adapter trimming
- paired-end trimming and pair validation
- RRBS trimming path
- built-in FastQC-compatible HTML/ZIP report generation
- gzip input/output path
- v2.2 `--clumpify` path
- dynamic library resolution

Supported by upstream and available through this wrapper, but not exhaustively
tested by smoke:

- demultiplexing with `--demux`
- `--clock` and `--implicon` preprocessing modes
- all adapter presets and multi-adapter file modes
- very large multi-core production runs
- all `--fastqc_args` translations

Not packaged as separate executables:

- external `cutadapt`
- external Java FastQC
- MultiQC
- BBMap clumpify

For v2.2.0 these are not required for the normal Trim Galore binary. MultiQC is
still a useful downstream app for aggregating reports, but it is intentionally
kept separate.

## Platform Notes

The upstream release provides native Linux binaries for both x86_64 and
aarch64, so this TAFFISH app declares native `linux/amd64` and `linux/arm64`
builds. No Docker/Podman amd64 emulation is required on arm64 hosts.

The binary is dynamically linked against glibc, zlib, libgcc, libm, and libc.
The Dockerfile checks `ldd` during build and smoke checks assert that no dynamic
dependency is missing.

## Versioning

This package version is `2.2.0-r1`.

The upstream binary reports:

```text
trim_galore 2.2.0 (Oxidized Edition)
5846564 - linux/<arch> - built 2026-05-07T22:56:14Z
```

The architecture string differs between `linux/amd64` and `linux/arm64`, so
metadata and smoke checks bind the package to version `2.2.0` and commit prefix
`5846564`.

## Upstream

- Project: <https://github.com/FelixKrueger/TrimGalore>
- Homepage: <https://www.trimgalore.com/>
- Release: <https://github.com/FelixKrueger/TrimGalore/releases/tag/v2.2.0>
- License: GPL-3.0-only
- Citation: Krueger F. Trim Galore: consistent quality and adapter trimming for
  next-generation sequencing data. Babraham Institute.

No formal DOI or PMID was found in the upstream release README.
