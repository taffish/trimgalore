taf-trimgalore 2.2.0-r1

TAFFISH wrapper for Trim Galore v2.2.0, the Rust Oxidized Edition.
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
  taf-trimgalore --fastqc reads.fq.gz

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
  taf-trimgalore trim_galore --dont_gzip --length 20 reads.fq.gz

Common Trim Galore options:
  -q, --quality              3-prime Phred quality trimming cutoff
  -a, --adapter              Adapter sequence; repeatable
  --adapter2                 Read 2 adapter sequence
  --illumina, --nextera      Common adapter presets
  --small_rna, --bgiseq      Library adapter presets
  --paired                   Paired-end mode
  --length                   Minimum length after trimming
  --clip_R1, --clip_R2       Remove bases from the 5-prime end
  -o, --output_dir           Output directory; created if missing
  --dont_gzip                Force plain FASTQ output
  --compression              Gzip compression level, 1 to 9
  --clumpify                 Reorder gzip output for better compression
  --rrbs, --non_directional  RRBS modes
  --fastqc                   Produce built-in FastQC-compatible reports
  --fastqc_args              Arguments for the built-in FastQC engine
  -j, --cores                Worker threads for trimming and compression
  --poly_a, --poly_g         Force poly-A or poly-G trimming
  --no_poly_g                Disable poly-G auto-detection

Packaged commands:
  trim_galore   Upstream Trim Galore binary
  bash          Convenience shell in the same container
  gzip          Convenience compression tool
  unzip         Convenience ZIP inspection tool

Output:
  Single-end output is usually *_trimmed.fq or *_trimmed.fq.gz.
  Paired-end output is usually *_val_1.fq(.gz) and *_val_2.fq(.gz).
  Reports are *_trimming_report.txt and *_trimming_report.json.
  With --fastqc, outputs include *_fastqc.html and *_fastqc.zip.

Notes:
  - The clearest command-mode form is taf-trimgalore trim_galore ...
  - taf-trimgalore --help and taf-trimgalore --version are handled by the
    TAFFISH wrapper. Use taf-trimgalore trim_galore --version or
    taf-trimgalore -- --version for the upstream version.
  - If the first argument is an upstream option, taf-trimgalore forwards it to
    trim_galore, so taf-trimgalore --paired R1.fq.gz R2.fq.gz also works.
  - v2.2.0 is a single Rust binary. External cutadapt, Java FastQC, and a
    separate fastqc command are not required or installed.
  - Built-in --fastqc writes FastQC 0.12.1-compatible HTML and ZIP reports.
    MultiQC can consume the text and JSON reports, but is not packaged here.
  - --clumpify requires gzip output and --cores 2 or higher.
  - Input and output paths should be reachable from the current working
    directory or mounted user paths.

Container:
  image: ghcr.io/taffish/trimgalore:2.2.0-r1
  supported backends: apptainer, podman, docker
  supported platforms: linux/amd64, linux/arm64

Upstream:
  project: Trim Galore
  homepage: https://www.trimgalore.com/
  license: GPL-3.0-only
