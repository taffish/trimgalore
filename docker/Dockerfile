ARG TRIMGALORE_VERSION=2.2.0
ARG TRIMGALORE_COMMIT_SHORT=5846564

FROM debian:12-slim AS fetcher

ARG TARGETARCH
ARG TRIMGALORE_VERSION
ARG TRIMGALORE_COMMIT_SHORT
ENV DEBIAN_FRONTEND=noninteractive

RUN set -eux; \
    for attempt in 1 2 3; do \
      if apt-get -o Acquire::Retries=3 update \
       && apt-get -o Acquire::Retries=3 install -y --no-install-recommends \
            ca-certificates \
            curl \
            tar; then \
        break; \
      fi; \
      if [ "$attempt" = "3" ]; then exit 1; fi; \
      apt-get clean; \
      rm -rf /var/lib/apt/lists/*; \
      sleep 5; \
    done; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp/build

RUN set -eux; \
    arch="${TARGETARCH:-$(dpkg --print-architecture)}"; \
    case "${arch}" in \
      amd64) \
        tg_arch="x86_64"; \
        tg_sha="7ed9de04632ef4b8430aa03ee9a8d0872822299279dfda4d637ff73cde7a6474"; \
        ;; \
      arm64) \
        tg_arch="aarch64"; \
        tg_sha="507c203ae72374a7a1ffa84ea20560707908fb720741d64dfb81984bfda22118"; \
        ;; \
      *) \
        echo "Unsupported TARGETARCH: ${arch}" >&2; \
        exit 1; \
        ;; \
    esac; \
    asset="trim_galore-linux-${tg_arch}.tar.gz"; \
    curl -fsSL \
      -o "${asset}" \
      "https://github.com/FelixKrueger/TrimGalore/releases/download/v${TRIMGALORE_VERSION}/${asset}"; \
    echo "${tg_sha}  ${asset}" | sha256sum -c -; \
    mkdir -p /opt/trimgalore/bin /opt/trimgalore/share/doc/trimgalore /opt/trimgalore/share/licenses/trimgalore; \
    tar -xzf "${asset}" --strip-components=1 -C /tmp/build; \
    install -m 0755 trim_galore /opt/trimgalore/bin/trim_galore; \
    install -m 0644 README.md /opt/trimgalore/share/doc/trimgalore/README.md; \
    install -m 0644 LICENSE /opt/trimgalore/share/licenses/trimgalore/LICENSE; \
    { \
      echo "name=Trim Galore"; \
      echo "version=${TRIMGALORE_VERSION}"; \
      echo "release=v${TRIMGALORE_VERSION}"; \
      echo "commit_short=${TRIMGALORE_COMMIT_SHORT}"; \
      echo "target_arch=${arch}"; \
      echo "asset=https://github.com/FelixKrueger/TrimGalore/releases/download/v${TRIMGALORE_VERSION}/${asset}"; \
      echo "asset_sha256=${tg_sha}"; \
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

COPY --from=fetcher /opt/trimgalore /opt/trimgalore

ENV PATH=/opt/trimgalore/bin:${PATH}

RUN set -eux; \
    command -v trim_galore >/dev/null; \
    command -v bash >/dev/null; \
    command -v gzip >/dev/null; \
    command -v unzip >/dev/null; \
    command -v ldd >/dev/null; \
    trim_galore --version 2>&1 | grep -F "trim_galore ${TRIMGALORE_VERSION} (Oxidized Edition)" >/dev/null; \
    trim_galore --version 2>&1 | grep -F "${TRIMGALORE_COMMIT_SHORT}" >/dev/null; \
    trim_galore -h 2>&1 | grep -F "Fast adapter and quality trimming for NGS data" >/dev/null; \
    trim_galore --help 2>&1 | grep -F "built in via the bundled fastqc-rust library" >/dev/null; \
    ldd /opt/trimgalore/bin/trim_galore | grep -F "libz.so" >/dev/null; \
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
    cd /; \
    rm -rf /tmp/trimgalore-check

WORKDIR /root

ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=trimgalore
