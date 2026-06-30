taf-trimgalore 2.3.0-r1

TAFFISH wrapper for Trim Galore v2.3.0, the Rust rewrite.
Trim Galore performs FASTQ adapter trimming, quality trimming, RRBS handling,
and optional built-in FastQC-compatible report generation.

Usage:
  taf-trimgalore [TAF-APP-OPTION]
  taf-trimgalore [TRIMGALORE-CMD] [TRIMGALORE-ARGS...]
  taf-trimgalore [TRIMGALORE-OPTION] [TRIMGALORE-ARGS...]

TAF app options:
  -h, --help       Show this help text
  -v, --version    Show package and command version
  --compile        Print generated shell code instead of running it
  --               Stop parsing TAFFISH wrapper options

Default upstream command:
  trim_galore

Upstream option calls:
  taf-trimgalore -- --version
  taf-trimgalore -- --help
  taf-trimgalore --paired sample_R1.fq.gz sample_R2.fq.gz

Command mode:
  taf-trimgalore trim_galore --version
  taf-trimgalore trim_galore --help
  taf-trimgalore trim_galore reads.fq.gz
  taf-trimgalore bash

Recommended examples:
  taf-trimgalore trim_galore reads.fq.gz
  taf-trimgalore trim_galore --paired sample_R1.fq.gz sample_R2.fq.gz
  taf-trimgalore trim_galore --paired --cores 8 --output_dir trimmed sample_R1.fq.gz sample_R2.fq.gz
  taf-trimgalore trim_galore --rrbs --paired sample_R1.fq.gz sample_R2.fq.gz
  taf-trimgalore trim_galore --fastqc reads.fq.gz
  taf-trimgalore trim_galore --clumpify --compression 6 --cores 4 reads.fq.gz
  taf-trimgalore trim_galore --output-format ubam reads.fq
  taf-trimgalore trim_galore --preserve-tags CB,UB sample.ubam
  taf-trimgalore trim_galore --paired --passthrough I1.fq.gz sample_R1.fq.gz sample_R2.fq.gz

Common Trim Galore options:
  --paired, --length, -o/--output_dir, --dont_gzip, --compression, --cores
  -a/--adapter, --adapter2, --illumina, --nextera, --small_rna, --bgiseq
  --rrbs, --non_directional, --fastqc, --fastqc_args
  --poly_a, --poly_g, --no_poly_g
  --clumpify, --output-format ubam, --preserve-tags, --passthrough

Packaged commands:
  trim_galore   Upstream Trim Galore binary
  bash, gzip, unzip

Output:
  Single-end output is usually *_trimmed.fq or *_trimmed.fq.gz.
  Paired-end output is usually *_val_1.fq(.gz) and *_val_2.fq(.gz).
  Reports are *_trimming_report.txt and *_trimming_report.json.
  With --fastqc, outputs include *_fastqc.html and *_fastqc.zip.
  With --output-format ubam, single-end output is *_trimmed.bam and paired
  output is one interleaved *_val.bam.

Notes:
  - The clearest command-mode form is taf-trimgalore trim_galore ...
  - taf-trimgalore --help and taf-trimgalore --version are handled by the
    TAFFISH wrapper. Use taf-trimgalore trim_galore --version or
    taf-trimgalore -- --version for the upstream version.
  - If the first argument is an upstream option, taf-trimgalore forwards it to
    trim_galore, so taf-trimgalore --paired R1.fq.gz R2.fq.gz also works.
  - v2.3.0 is a single Rust binary. External cutadapt, Java FastQC, and a
    separate fastqc command are not required or installed.
  - v2.3.0 is built from the fixed upstream Git tag because the old v2.2
    prebuilt binary asset names are not published for this release.
  - Built-in --fastqc writes FastQC 0.12.1-compatible HTML and ZIP reports.
    MultiQC can consume the text and JSON reports, but is not packaged here.
  - --clumpify requires gzip output and --cores 2 or higher.
  - --output-format ubam is single-threaded in v2.3.0; some specialty modes
    such as --clumpify and --passthrough are rejected with uBAM output.
  - --passthrough requires paired-end input and exactly one passthrough FASTQ.

Container:
  image: ghcr.io/taffish/trimgalore:2.3.0-r1
  supported backends: apptainer, podman, docker
  supported platforms: linux/amd64, linux/arm64

Upstream:
  project: Trim Galore
  homepage: https://www.trimgalore.com/
  license: GPL-3.0-only
