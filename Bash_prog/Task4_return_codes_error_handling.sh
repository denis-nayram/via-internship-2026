#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Nayram Banyie Mawah
# @index        4191624
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks (host reachability, disk
#               space, config file existence/readability, required tool
#               availability), exiting with a specific documented code on
#               the first failure. Uses trap to clean up temp files on any
#               exit path.
# @date         2026-09-13
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found or unreadable
#   5 = required command not found
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  host to test reachability against (e.g. google.com)"
  exit 1
}

if [[ "$#" -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

HOST="$1"
CONFIG_FILE="./sample_config.conf"
REQUIRED_TOOL="awk"
MIN_FREE_KB=1048576  # 1 GB in KB, arbitrary threshold for demonstration

TMP_FILE=$(mktemp /tmp/task4_check.XXXXXX)

# --- cleanup on any exit (success, failure, or Ctrl+C) ----------------------
# trap ensures the temp file is always removed, regardless of how the script
# terminates, so we never litter /tmp even on unexpected interruption.
cleanup() {
  rm -f "$TMP_FILE"
  echo "Info: cleaned up temporary files."
}
trap cleanup EXIT INT TERM

# --- helper: interpret a command's exit status and act on it ---------------
# Centralizing this logic means every check reports failures the same way
# and exits with the correct documented code, instead of repeating
# if/else blocks five times with a risk of inconsistency.
check_status() {
  local result="$1"       # the $? value passed in from the caller
  local success_msg="$2"
  local failure_msg="$3"
  local exit_code="$4"

  if [[ "$result" -eq 0 ]]; then
    echo "PASS: $success_msg"
  else
    echo "FAIL: $failure_msg" >&2
    exit "$exit_code"
  fi
}

# --- create a dummy config file for the file-check demonstration -----------
# This makes the script runnable out of the box without requiring the user
# to supply their own config file first.
echo "sample_setting=true" > "$CONFIG_FILE" 2>"$TMP_FILE"
if [[ $? -ne 0 ]]; then
  echo "Error: could not create demo config file '$CONFIG_FILE'." >&2
  exit 4
fi

echo "Running system checks against host: $HOST"
echo ""

# --- check 1: host reachability ---------------------------------------------
ping -c 1 -W 2 "$HOST" > "$TMP_FILE" 2>&1
check_status "$?" \
  "host '$HOST' is reachable." \
  "host '$HOST' is not reachable (see ping output for details)." \
  2

# --- check 2: sufficient free disk space ------------------------------------
# df -k --output=avail gives available space in KB for the current directory.
# We fall back to plain df parsing if --output isn't supported (e.g. macOS).
AVAILABLE_KB=$(df -k . 2>"$TMP_FILE" | awk 'NR==2 {print $4}')
if [[ -z "$AVAILABLE_KB" ]]; then
  echo "FAIL: could not determine available disk space." >&2
  exit 3
fi

if [[ "$AVAILABLE_KB" -ge "$MIN_FREE_KB" ]]; then
  check_status 0 "sufficient disk space available (${AVAILABLE_KB}KB free)." "" 3
else
  check_status 1 "" "insufficient disk space: only ${AVAILABLE_KB}KB free, need ${MIN_FREE_KB}KB." 3
fi

# --- check 3: required config/data file exists and is readable -------------
if [[ -f "$CONFIG_FILE" && -r "$CONFIG_FILE" ]]; then
  check_status 0 "config file '$CONFIG_FILE' exists and is readable." "" 4
else
  check_status 1 "" "config file '$CONFIG_FILE' is missing or unreadable." 4
fi

# --- check 4: required command/tool is installed ----------------------------
if command -v "$REQUIRED_TOOL" > "$TMP_FILE" 2>&1; then
  check_status 0 "required tool '$REQUIRED_TOOL' is installed." "" 5
else
  check_status 1 "" "required tool '$REQUIRED_TOOL' is not installed." 5
fi

echo ""
echo "All checks passed."
exit 0
