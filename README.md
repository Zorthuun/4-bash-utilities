# bash-utilities

Small Bash tools I've written to streamline recon and engagement workflow. Nothing revolutionary — just utilities I got tired of doing manually.

Use at your own risk. Always confirm scope before running anything that touches a network you don't own.

## Tools

### `recon-init.sh`

Sets up a clean engagement folder structure and runs initial recon scans against a target. Useful at the start of an engagement when you want to capture nmap output cleanly without forgetting flags.

**Usage:**
```bash
./recon-init.sh <target-ip-or-hostname> <engagement-name>
```

**What it does:**
1. Creates a standard engagement folder layout
2. Runs nmap host discovery
3. Runs full TCP port scan
4. Runs service version detection on discovered open ports
5. Logs everything with timestamps to a `notes.md` file

### `host-up.sh`

Quickly identifies live hosts in a CIDR range and writes results in a clean format suitable for piping into other tools. A wrapper around `nmap -sn` with sane defaults and timestamped output.

**Usage:**
```bash
./host-up.sh <cidr-range>
```

**Example:**
```bash
./host-up.sh 10.10.10.0/24
```

## Why these exist

Both scripts solve a small but real problem: I kept forgetting flags, mistyping output paths, or losing track of which scan ran when. Wrapping the workflow in a small script saves time per engagement and makes my notes more consistent.
