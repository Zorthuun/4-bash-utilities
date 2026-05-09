#!/usr/bin/env bash
#
# recon-init.sh
#
# Bootstraps an engagement folder structure and runs initial nmap recon
# against a single target. Output is captured cleanly into the folder
# structure and timestamped in a notes file.
#
# Usage:  ./recon-init.sh <target> <engagement-name>
# Example: ./recon-init.sh 10.10.10.5 acme-internal
#
# Author: Tielman van Lill (Zorthuun)
# License: MIT

set -euo pipefail

# ---- argument check ----
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <target> <engagement-name>"
    echo "Example: $0 10.10.10.5 acme-internal"
    exit 1
fi

TARGET="$1"
ENGAGEMENT="$2"
TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
BASE_DIR="./${ENGAGEMENT}"

# ---- check dependencies ----
if ! command -v nmap >/dev/null 2>&1; then
    echo "[!] nmap is not installed. Install it before running this script."
    exit 1
fi

# ---- create folder structure ----
echo "[+] Creating engagement folder: ${BASE_DIR}"
mkdir -p "${BASE_DIR}"/{01-scope,02-recon,03-enum,04-exploit,05-loot,06-report}

NOTES="${BASE_DIR}/notes.md"

# ---- initialise notes file ----
cat > "${NOTES}" <<EOF
# Engagement: ${ENGAGEMENT}

- **Target:** ${TARGET}
- **Started:** ${TIMESTAMP}
- **Tester:** $(whoami)@$(hostname)

## Activity log

- ${TIMESTAMP} — engagement folder initialised
EOF

log() {
    local msg="$1"
    local now
    now="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "- ${now} — ${msg}" >> "${NOTES}"
    echo "[+] ${msg}"
}

# ---- 1. host discovery ----
log "Running host discovery (nmap -sn)"
nmap -sn "${TARGET}" -oA "${BASE_DIR}/02-recon/host-discovery" >/dev/null

# ---- 2. full TCP port scan ----
log "Running full TCP port scan (this may take a while)"
nmap -p- -T4 --min-rate=1000 -Pn "${TARGET}" \
    -oA "${BASE_DIR}/02-recon/tcp-allports" >/dev/null

# ---- 3. parse open ports ----
OPEN_PORTS="$(grep -oP '^\d+/open' "${BASE_DIR}/02-recon/tcp-allports.gnmap" 2>/dev/null \
              | cut -d/ -f1 | paste -sd, - || true)"

if [[ -z "${OPEN_PORTS}" ]]; then
    log "No open TCP ports found. Stopping."
    echo "[!] No open ports detected on ${TARGET}."
    exit 0
fi

log "Open TCP ports: ${OPEN_PORTS}"

# ---- 4. service version + default scripts on open ports ----
log "Running service detection on open ports"
nmap -sC -sV -p"${OPEN_PORTS}" -Pn "${TARGET}" \
    -oA "${BASE_DIR}/02-recon/tcp-services" >/dev/null

log "Initial recon complete. Output is in ${BASE_DIR}/02-recon/"

cat <<EOF

[✓] Engagement bootstrapped: ${BASE_DIR}
    Open ports: ${OPEN_PORTS}
    Notes:      ${NOTES}

Next steps to consider:
  - Service-specific enumeration on each open port
  - UDP top 100 scan if relevant
  - Web tech fingerprinting if HTTP(S) present
EOF
