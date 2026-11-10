# Trim Galore for TAFFISH

Trim adapters and low-quality ends from reads, keep paired files synchronized, or generate an offline quality report. This tool packages unmodified [Trim Galore v2.4.0](https://github.com/FelixKrueger/TrimGalore/releases/tag/v2.4.0), the Rust implementation by Felix Krueger.

| Package | Installed command | Image | Upstream identity |
| --- | --- | --- | --- |
| `trimgalore` · tool · `2.4.0-r1` | `taf-trimgalore` | `ghcr.io/taffish/trimgalore:2.4.0-r1` | `trim_galore 2.4.0` · `508d85f` |

After this version appears in the Hub Index, run `taf update` and `taf install trimgalore 2.4.0-r1`. Use `taf-trimgalore-v2.4.0-r1` to select the exact version, or `taf-trimgalore` for the installed alias.

## Run a sample

Start in a writable project directory. Give each run a new output directory.

```sh
taf-trimgalore trim_galore --fastqc -o qc reads.fq.gz
taf-trimgalore --paired --cores 4 -o paired sample_R1.fq.gz sample_R2.fq.gz
```

Single reads produce `*_trimmed.fq[.gz]`; pairs produce `*_val_1.fq[.gz]` and `*_val_2.fq[.gz]`. The accompanying text and JSON record the trimming settings and counts. `--fastqc` adds `*_fastqc.html` and `*_fastqc.zip` for the trimmed output. Open the HTML directly; it does not need the ZIP, a running container, Java or a network connection. The ZIP includes the module data and both chart formats. SVG is the default in HTML; use `--fastqc_args=--png` for raster charts. Sample names can appear in reports: check before sharing them.

`taf-trimgalore --help` shows installed-wrapper help. `taf-trimgalore -- --help` and `taf-trimgalore trim_galore --help` show upstream help. If the first argument is a filename, use the explicit `trim_galore` form; otherwise TAFFISH treats it as a command. In TAFFISH 0.11 the command wrapper joins arguments as shell text. Use plain project names when possible; for **trusted** names with spaces, preserve the inner quotes:

```sh
taf-trimgalore trim_galore -o '"QC results"' '"reads with spaces.fq"'
```

## Choose the right mode

| Task | Upstream options | Result or constraint |
| --- | --- | --- |
| Trim using a library-prep preset | `--library pbat` (also emseq, accel, zymo, scbs) | Applies end clipping; does not select adapters or change the minimum length. JSON records the resolved preset. |
| RRBS with synchronized mates | `--rrbs --paired R1.fq.gz R2.fq.gz` | Separate from the clipping presets. |
| Compress after trimming | `--clumpify --cores 2 reads.fq.gz` | Groups similar reads; requires the gzip output path. |
| Reorder without trimming | `--clump_only --cores 2 reads.fq.gz` | Writes `*_clumped*` and a clumping report. FASTQ IDs, sequences and qualities are preserved, not file order, unusual plus-line text, CRLF or compressed bytes. |
| Emit unaligned BAM and QC | `--output-format ubam --fastqc reads.fq` | Single-end `*_trimmed.bam`; paired FASTQ inputs produce one interleaved `*_val.bam`. Not an alignment or a general BAM editor. |
| Carry per-read information | `--preserve-tags CB,UB sample.ubam`; `--paired --passthrough I1.fq.gz R1.fq.gz R2.fq.gz` | Choose tags explicitly for supported uBAM paths; passthrough is a paired FASTQ workflow. |

Do not reuse an output directory to preserve prior results: planned name collisions *within a run* are refused, but a successful new run can replace an earlier run's files. Use distinct input basenames when several reports go into a single directory. Malformed or misdeclared input can fail before output; check stderr before retrying. The upstream [usage guide](https://www.trimgalore.com/) covers additional modes, including poly-A/G trimming, specialty preprocessing and inline demultiplexing.

## Backends and resources

Docker, Podman and Linux Apptainer use the same CLI and write results into the bound working directory. Native image targets: Linux amd64 and arm64. For example, prefix the report command above with `TAFFISH_CONTAINER_BACKEND=docker`, `TAFFISH_CONTAINER_BACKEND=podman` or `TAFFISH_CONTAINER_BACKEND=apptainer`. No exposed ports, display, GPU or background service are involved. The installation in the image is read-only; keep input readable, output writable and enough temporary space on the host.

**No database or model installation is needed.** Adapter presets, the FastQC 1.1.1 engine's configuration lists, report assets and fonts are embedded with the software. Adapter detection operates on the reads, not on a remote catalog. A custom FASTA (`-a file:adapters.fa`) or barcode list is project input, not a managed reference release: put a readable copy in the project directory. Use and share third-party inputs under their own terms. The app does not fetch missing files or need an administrator to initialize a cache.

## Packaging and limits

The build verifies [commit 508d85f](https://github.com/FelixKrueger/TrimGalore/commit/508d85feae324e993e0ccbe14e9090cf2897f68d), its tree and the upstream Cargo.lock before compiling without algorithm changes. The final Debian 12 slim image contains the binary, runtime libraries, bash, gzip, unzip, source identity, lockfile and notices; the compiler and Cargo cache stay in the builder. The bundled Rust engine renders charts locally using embedded Liberation Sans. It produces Java FastQC 0.13.0-compatible output; a standalone Java FastQC, cutadapt, samtools, MultiQC and a desktop viewer are not part of the image. MultiQC is a separate downstream consumer.

The offline smoke covers version/commit, help/linkage, single and paired trimming, RRBS, gzip clumping, FASTQ reordering, the library preset and both FASTQ and uBAM reports. It tests software behavior with tiny inputs, not production throughput or scientific validity for every library or optional combination.

The packaged wrapper was tested with Docker, Podman and Apptainer on native Linux amd64, and with Docker and Podman on arm64. Docker reported image sizes of approximately 91 MiB (amd64) and 112 MiB (arm64); the tested amd64 SIF was approximately 35 MiB. These are local image sizes, not registry download sizes.

To test a source checkout without installing an alias, use `taf run -b docker -- trim_galore --fastqc -o qc reads.fq` from the checkout. `taf build` creates a local versioned wrapper under `target/`; the installed command shown above is the normal user entry point. The HTML is an output file, not a service: it remains readable after any of these commands exits.

## License and citation

TAFFISH packaging: [Apache-2.0](LICENSE). Trim Galore is GPL-3.0-only; bundled FastQC, fonts, Rust dependencies and OS packages retain their respective licenses. See `/opt/trimgalore/share/licenses`, `/opt/trimgalore/share/doc/CITATION.cff` and Debian copyright notices. Cite Felix Krueger, *Trim Galore*, [concept DOI 10.5281/zenodo.5127898](https://doi.org/10.5281/zenodo.5127898), and record version 2.4.0.
