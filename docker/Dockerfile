# Pinned multi-platform indexes; each native builder selects its own platform.
# A digest or lock verifies identity, not future availability. Restore missing
# inputs from verified archives; audit new revisions rather than changing a hash.
FROM rust:1.88-bookworm@sha256:af306cfa71d987911a781c37b59d7d67d934f49684058f96cf72079c3626bfe0 AS builder
ENV SOURCE_DATE_EPOCH=1794219431
WORKDIR /build
# The tag is a locator; the commit, tree and Cargo.lock are the identity.
# Cargo checks crate checksums. A vanished crate requires an identical verified
# copy or a new reviewed dependency set; do not regenerate the upstream lock.
RUN set -eu; \
    git -c http.version=HTTP/1.1 clone --depth 1 --branch v2.4.0 \
        https://github.com/FelixKrueger/TrimGalore.git src; \
    cd src; \
    test "$(git rev-parse HEAD)" = 508d85feae324e993e0ccbe14e9090cf2897f68d; \
    test "$(git rev-parse 'HEAD^{tree}')" = 125f72acb703b0f27b5bff8d0c89f7f40f6071ec; \
    echo 'd314e687ff367c0ad47541548626da0811bb6c0628abca54644a70a1fbf27a0f  Cargo.lock' | sha256sum -c -; \
    cargo build --release --locked; \
    prefix=/opt/trimgalore; \
    install -d -m 0755 "$prefix/bin" "$prefix/share/doc" "$prefix/share/licenses"; \
    install -m 0755 target/release/trim_galore "$prefix/bin/"; \
    install -m 0644 README.md CHANGELOG.md CITATION.cff Cargo.lock "$prefix/share/doc/"; \
    install -m 0644 LICENSE "$prefix/share/licenses/Trim-Galore-GPL-3.0.txt"; \
    git show -s --format='%H%n%T%n%cI' HEAD > "$prefix/share/doc/source.txt"; \
    cd "$CARGO_HOME/registry/src"; \
    find . -type f \( -iname 'license*' -o -iname 'licence*' -o -iname 'copying*' -o -iname 'notice*' -o -iname 'OFL.txt' \) \
        -exec cp --parents --target-directory="$prefix/share/licenses" -- {} +

FROM debian:12-slim@sha256:734a72b3d6142a71993b4bc580ca01d8ca687f77a2c422d96a961d3376b179bc
# Debian security revisions may roll off the active bookworm mirrors. For an
# identical rebuild use an audited snapshot or the original verified debs;
# otherwise review the changed package set and rerun both native builds.
RUN set -eu; \
    apt-get -o Acquire::Retries=3 update; \
    apt-get -o Acquire::Retries=3 install -y --no-install-recommends bash ca-certificates gzip unzip; \
    rm -rf /var/lib/apt/lists/*; \
    install -d -m 0755 /opt/trimgalore /usr/local/libexec

COPY --from=builder /opt/trimgalore/ /opt/trimgalore/
COPY docker/Liberation-OFL.txt /opt/trimgalore/share/licenses/Liberation-OFL.txt
COPY docker/smoke.sh /usr/local/libexec/taf-trimgalore-smoke
ENV PATH=/opt/trimgalore/bin:$PATH
ENV TAFFISH_ENV=TAFFISH
ENV TAFFISH_NAME=trimgalore
WORKDIR /tmp
# Build both native images on stable identity only. Rendering, gzip, uBAM
# and negative cases belong to the offline runtime matrix, not to build-time.
RUN set -eu; \
    chmod 0644 /opt/trimgalore/share/licenses/Liberation-OFL.txt; \
    chmod 0755 /usr/local/libexec/taf-trimgalore-smoke; \
    /usr/local/libexec/taf-trimgalore-smoke identity
