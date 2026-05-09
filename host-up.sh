#!/usr/bin/env bash
#
# host-up.sh
#
# Quick live-host discovery across a CIDR range. Wraps nmap -sn with sane
# defaults and writes results in a clean, pipeable format.
#
# Usage:  ./host-up.sh <cidr-range>
# Example: ./host-up.sh 10.10.10.0/24
#
# Output:
#   stdout: one IP per line (live hosts only)
#   file:   ./host-up_<cidr>_<timestamp>.txt
#
# Author: Tielman van Lill (Zorthuun)
# License: MIT

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <cidr-range>"
    echo "Example: $0 10.10.10.0/24"
    exit 1
fi

CIDR="$1"

if ! command -v nmap >/dev/null 2>&1; then
    echo "[!] nmap is not installed."
    exit 1
fi

# sanitise CIDR for filename (replace / with _)
CIDR_CLEAN="${CIDR//\//_}"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
OUTFILE="./host-up_${CIDR_CLEAN}_${TIMESTAMP}.txt"

echo "[+] Sweeping ${CIDR} for live hosts..." >&2

# -sn  : ping scan, no port scan
# -n   : no DNS resolution (faster)
# -T4  : aggressive timing
# Output via grep + awk for clean IP-only stdout
nmap -sn -n -T4 "${CIDR}" \
    | awk '/Nmap scan report for/ {print $NF}' \
    | tee "${OUTFILE}"

COUNT="$(wc -l < "${OUTFILE}")"

echo "[+] ${COUNT} live host(s) written to ${OUTFILE}" >&2
