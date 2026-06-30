ARG TRIMGALORE_VERSION=2.3.0
ARG TRIMGALORE_TAG=v2.3.0
ARG TRIMGALORE_COMMIT=c6528e54512e0e388a392d36475291bcbf0eb0dd
ARG TRIMGALORE_COMMIT_SHORT=c6528e5
ARG TRIMGALORE_SOURCE_DATE_EPOCH=1782576051

FROM rust:1.88-bookworm AS builder

ARG TRIMGALORE_TAG
ARG TRIMGALORE_COMMIT
ARG TRIMGALORE_SOURCE_DATE_EPOCH
ENV SOURCE_DATE_EPOCH=${TRIMGALORE_SOURCE_DATE_EPOCH}

WORKDIR /tmp/build

RUN set -eux; \
    git clone --depth 1 --branch "${TRIMGALORE_TAG}" https://github.com/FelixKrueger/TrimGalore.git src; \
    cd src; \
    test "$(git rev-parse HEAD)" = "${TRIMGALORE_COMMIT}"; \
    cargo build --release --locked; \
    mkdir -p /opt/trimgalore/bin /opt/trimgalore/share/doc/trimgalore /opt/trimgalore/share/licenses/trimgalore; \
    install -m 0755 target/release/trim_galore /opt/trimgalore/bin/trim_galore; \
    install -m 0644 README.md CHANGELOG.md CITATION.cff /opt/trimgalore/share/doc/trimgalore/; \
    install -m 0644 LICENSE /opt/trimgalore/share/licenses/trimgalore/LICENSE; \
    { \
      echo "name=Trim Galore"; \
      echo "version=$(grep -m1 '^version = ' Cargo.toml | sed 's/version = //; s/\"//g')"; \
      echo "release=${TRIMGALORE_TAG}"; \
      echo "commit=${TRIMGALORE_COMMIT}"; \
      echo "source=https://github.com/FelixKrueger/TrimGalore.git"; \
      echo "source_date_epoch=${TRIMGALORE_SOURCE_DATE_EPOCH}"; \
      echo "build=cargo build --release --locked"; \
    } > /opt/trimgalore/share/doc/trimgalore/source.txt

FROM debian:12-slim

ARG TRIMGALORE_VERSION
ARG TRIMGALORE_COMMIT_SHORT
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    for attempt in 1 2 3; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            bash \
            ca-certificates \
            gzip \
            libc6 \
            libgcc-s1 \
            unzip \
            zlib1g; then \
        break; \
      fi; \
      if [ "$attempt" = "3" ]; then exit 1; fi; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/trimgalore /opt/trimgalore

ENV PATH=/opt/trimgalore/bin:${PATH}

RUN set -eux; \
    command -v trim_galore >/dev/null; \
    command -v bash >/dev/null; \
    command -v gzip >/dev/null; \
    command -v unzip >/dev/null; \
    command -v ldd >/dev/null; \
    trim_galore --version 2>&1 | grep -F "trim_galore ${TRIMGALORE_VERSION}" >/dev/null; \
    trim_galore --version 2>&1 | grep -F "${TRIMGALORE_COMMIT_SHORT}" >/dev/null; \
    trim_galore --help 2>&1 | grep -F "Trim Galore: A fast, single-pass" >/dev/null; \
    trim_galore --help 2>&1 | grep -F "built in via the bundled fastqc-rust library" >/dev/null; \
    trim_galore --help 2>&1 | grep -F "output-format" >/dev/null; \
    trim_galore --help 2>&1 | grep -F "passthrough" >/dev/null; \
    ! ldd /opt/trimgalore/bin/trim_galore | grep -F "not found" >/dev/null

RUN set -eux; \
    mkdir -p /tmp/trimgalore-check; \
    cd /tmp/trimgalore-check; \
    printf "@r1\nACGTACGTAGATCGGAAGAGC\n+\nFFFFFFFFFFFFFFFFFFFFFF\n" > reads.fq; \
    trim_galore --dont_gzip --length 5 -o out reads.fq >/tmp/trimgalore-check.log 2>&1; \
    test -s out/reads_trimmed.fq; \
    grep -F "ACGTACGT" out/reads_trimmed.fq >/dev/null; \
    grep -F "Reads with adapters:" out/reads.fq_trimming_report.txt >/dev/null; \
    grep -F '"total_reads": 1' out/reads.fq_trimming_report.json >/dev/null; \
    trim_galore --fastqc --dont_gzip --length 5 -o fastqc-out reads.fq >/tmp/trimgalore-fastqc-check.log 2>&1; \
    test -s fastqc-out/reads_trimmed_fastqc.html; \
    test -s fastqc-out/reads_trimmed_fastqc.zip; \
    unzip -p fastqc-out/reads_trimmed_fastqc.zip reads_trimmed_fastqc/summary.txt | grep -F "Basic Statistics" >/dev/null; \
    trim_galore --output-format ubam --length 5 -o ubam-out reads.fq >/tmp/trimgalore-ubam-check.log 2>&1; \
    test -s ubam-out/reads_trimmed.bam; \
    gzip -cd ubam-out/reads_trimmed.bam | head -c 4 | od -An -tx1 | tr -d " \n" | grep -Fx "42414d01" >/dev/null; \
    cd /; \
    rm -rf /tmp/trimgalore-check

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=trimgalore
