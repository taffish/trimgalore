taf-trimgalore 2.4.0-r1 - trim reads, reorder FASTQ, or write an offline FastQC report

Usage:
  taf-trimgalore trim_galore [options] input.fq[.gz]
  taf-trimgalore --paired [options] R1.fq.gz R2.fq.gz
  taf-trimgalore --help           Show this wrapper help
  taf-trimgalore -- --help        Show all Trim Galore options
  taf-trimgalore --version        Show the package version
  taf-trimgalore -- --version     Show the upstream binary version

Examples:
  taf-trimgalore trim_galore -o trimmed reads.fq.gz
  taf-trimgalore --paired --cores 4 -o trimmed R1.fq.gz R2.fq.gz
  taf-trimgalore --rrbs --paired -o rrbs R1.fq.gz R2.fq.gz
  taf-trimgalore --library pbat --paired -o clipped R1.fq.gz R2.fq.gz
  taf-trimgalore --clump_only --cores 2 -o reordered reads.fq.gz
  taf-trimgalore --output-format ubam --fastqc -o qc-bam reads.fq

Quality reports:
  TAFFISH_CONTAINER_BACKEND=docker taf-trimgalore --fastqc -o qc reads.fq.gz
  TAFFISH_CONTAINER_BACKEND=podman taf-trimgalore --fastqc -o qc reads.fq.gz
  TAFFISH_CONTAINER_BACKEND=apptainer taf-trimgalore --fastqc -o qc reads.fq.gz
  Open qc/*_fastqc.html in your own browser; no server, port or internet is
  needed to read the report. The ZIP contains the measurements and images.
  SVG is the default. To embed PNG instead, add --fastqc_args=--png.

Inputs and outputs:
  Work in a directory containing your input files. Built-in adapters and
  library presets need no download. For your own adapters use -a file:adapters.fa.
  Use a fresh -o directory; reruns can replace results. Within one run, every
  planned output name must be distinct. Rename same-named mates if necessary.
  Single-end: *_trimmed.fq[.gz]; paired: *_val_1.fq[.gz] and *_val_2.fq[.gz].
  Trimming also writes text and JSON reports. --clump_only reorders records
  without trimming and writes *_clumped* and a text clumping report instead.
  For predictable paths, use simple filenames. With TAFFISH 0.11, to pass a
  space in a trusted name include the inner quotes, e.g.:
    taf-trimgalore trim_galore -o '"QC results"' '"reads with spaces.fq"'

More: https://www.trimgalore.com/  |  https://github.com/taffish/trimgalore
