#!/bin/sh
# Private, offline release checks; never a runtime entry point.
set -eu
mode=$1
umask 077
scratch=$(mktemp -d /tmp/taf-trimgalore.XXXXXXXX)
cd "$scratch"
step=setup
finish() {
    code=$?
    trap - EXIT HUP INT TERM
    if [ "$code" -ne 0 ]; then
        printf 'smoke-stage=%s/%s exit=%s\n' "$mode" "$step" "$code" >&2
        if [ -f run.log ]; then tail -n 24 run.log >&2; fi
    fi
    cd /
    rm -r -- "$scratch" || exit 1
    exit "$code"
}
trap finish EXIT
trap 'exit 129' HUP
trap 'exit 130' INT
trap 'exit 143' TERM
export LC_ALL=C
record() {
    awk -v id="$1" -v seq="$2" 'BEGIN {print "@" id; print seq; print "+"; for (i=1;i<=length(seq);i++) printf "F"; print ""}'
}
trim() { trim_galore "$@" >run.log 2>&1; }
read1() { record r1 ACGTACGTAGATCGGAAGAGC > reads.fq; }
report() {
    base=$1
    test -s "$base.html"
    unzip -tq "$base.zip"
    member=$(basename "$base")
    unzip -p "$base.zip" "$member/fastqc_data.txt" > stats.txt
    grep -F '##FastQC' stats.txt >/dev/null
    grep -F 'Mean Length' stats.txt >/dev/null
    grep -F 'Basic Statistics' "$base.html" >/dev/null
}
case "$mode" in
    identity)
        step=version
        trim_galore --version >run.log 2>&1
        # Validate identity, not architecture spelling, build time or banner size.
        awk '/^trim_galore / { versions++; if ($0 != "trim_galore 2.6.0") bad=1 }
          /^[0-9a-f]+[[:space:]]/ { commits++; if ($1 != "a77e643") bad=1 }
          END { exit(bad || versions != 1 || commits != 1) }' run.log
        ;;
    help)
        step=help; trim --help
        grep -F -- '--clump_only' run.log >/dev/null
        grep -F -- '--library' run.log >/dev/null
        step=linkage; ldd /opt/trimgalore/bin/trim_galore > run.log 2>&1
        if grep -F 'not found' run.log; then exit 1; fi
        ;;
    single)
        read1; step=single; trim --dont_gzip --length 5 -o out reads.fq
        record r1 ACGTACGT > expected.fq
        cmp expected.fq out/reads_trimmed.fq
        test -s out/reads.fq_trimming_report.txt
        grep -F '"total_reads": 1' out/reads.fq_trimming_report.json >/dev/null
        ;;
    paired)
        record r1/1 ACGTACGTAGATCGGAAGAGC > r1.fq
        record r1/2 TGCATGCAAGATCGGAAGAGC > r2.fq
        step=paired; trim --paired --dont_gzip --length 5 -o out r1.fq r2.fq
        record r1/1 ACGTACGT > one.fq; record r1/2 TGCATGCA > two.fq
        cmp one.fq out/r1_val_1.fq; cmp two.fq out/r2_val_2.fq
        ;;
    rrbs)
        record r1 CGGACGTAGATCGGAAGAGC > reads.fq
        step=rrbs; trim --rrbs --dont_gzip --length 3 -o out reads.fq
        record r1 CGGAC > expected.fq
        cmp expected.fq out/reads_trimmed.fq
        grep -F '"rrbs": true' out/reads.fq_trimming_report.json >/dev/null
        ;;
    fastqc)
        read1; step=fastqc; trim --fastqc --dont_gzip --length 5 -o out reads.fq
        report out/reads_trimmed_fastqc
        ;;
    raw-fastqc)
        read1; step=raw-fastqc; trim --length 5 --dont_gzip --fastqc_raw --fastqc -o out reads.fq
        report out/reads_raw_fastqc
        report out/reads_trimmed_fastqc
        unzip -p out/reads_raw_fastqc.zip '*/fastqc_data.txt' > raw-stats
        unzip -p out/reads_trimmed_fastqc.zip '*/fastqc_data.txt' > trimmed-stats
        awk -F '\t' '$1=="Filename" && $2=="reads_raw.fq" {name=1}
          $1=="Sequence length" && $2==21 {length_ok=1}
          END {exit(!name || !length_ok)}' raw-stats
        awk -F '\t' '$1=="Sequence length" && $2==8 {ok=1} END {exit(!ok)}' trimmed-stats
        test ! -e out/reads_raw.fq && test ! -L out/reads_raw.fq
        ;;
    gzip)
        read1; gzip -c reads.fq > reads.fq.gz
        step=gzip; trim --clumpify --cores 2 --length 5 -o out reads.fq.gz
        gzip -dc out/reads_trimmed.fq.gz > actual.fq
        record r1 ACGTACGT > expected.fq; cmp expected.fq actual.fq
        grep -iF 'clumpify' run.log >/dev/null
        ;;
    ubam)
        read1; step=ubam; trim --fastqc --output-format ubam --length 5 -o out reads.fq
        gzip -dc out/reads_trimmed.bam > raw
        printf 'BAM\001' > magic; head -c 4 raw > actual; cmp magic actual
        report out/reads_trimmed_fastqc
        ;;
    reorder)
        read1; record r2 TAGCTAGCTAGCTAGC >> reads.fq
        step=reorder; trim --clump_only --cores 2 --dont_gzip -o out reads.fq
        paste - - - - < reads.fq > before; paste - - - - < out/reads_clumped.fq > after
        sort before > expected; sort after > actual; cmp expected actual
        test -s out/reads.fq_clumping_report.txt
        ;;
    library)
        read1; step=library; trim --library pbat --length 2 --dont_gzip -o out reads.fq
        grep -F '"preset": "pbat"' out/reads.fq_trimming_report.json >/dev/null
        test -s out/reads_trimmed.fq
        ;;
    *) echo "Unknown smoke mode: $mode" >&2; exit 2 ;;
esac
printf 'PASS %s\n' "$mode"
