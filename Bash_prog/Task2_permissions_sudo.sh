#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Nayram Banyie Mawah
# @index        4191624
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports a file's permissions (symbolic + numeric), changes
#               them using both numeric and symbolic chmod syntax, attempts
#               a chown only if running as root, and reports the result.
# @date         2026-09-13
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  path to an existing file to inspect/modify"
  exit 1
}

if [[ "$#" -ne 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

FILE_PATH="$1"

# --- validate input ---------------------------------------------------------
# We must confirm the file exists before doing anything with stat/chmod,
# otherwise every following command would fail with a confusing error.
if [[ ! -e "$FILE_PATH" ]]; then
  echo "Error: '$FILE_PATH' does not exist." >&2
  exit 1
fi

# --- helper: report permissions in symbolic + numeric form -----------------
report_permissions() {
  local label="$1"
  echo "----- Permissions ($label) -----"
  # 'stat' gives us both formats directly and portably across most Linux distros.
  # %A = symbolic (e.g. rwxr-xr-x), %a = numeric/octal (e.g. 755)
  local symbolic
  local numeric
  symbolic=$(stat -c '%A' "$FILE_PATH" 2>/dev/null)
  numeric=$(stat -c '%a' "$FILE_PATH" 2>/dev/null)

  if [[ -z "$symbolic" || -z "$numeric" ]]; then
    # Fall back to ls -l parsing if stat's GNU-style flags aren't supported
    # (e.g. on some BSD/macOS systems), since the flag syntax differs there.
    echo "Warning: 'stat -c' unsupported on this system, falling back to ls -l." >&2
    ls -l "$FILE_PATH"
  else
    echo "Symbolic: $symbolic"
    echo "Numeric:  $numeric"
  fi
  echo "---------------------------------"
}

# --- step 1: report current permissions -------------------------------------
report_permissions "before changes"

# --- step 2: demonstrate numeric chmod --------------------------------------
if chmod 644 "$FILE_PATH"; then
  echo "Success: applied numeric chmod 644 to '$FILE_PATH'."
else
  echo "Error: numeric chmod failed on '$FILE_PATH'." >&2
  exit 1
fi

# --- step 2b: demonstrate symbolic chmod ------------------------------------
if chmod u+x "$FILE_PATH"; then
  echo "Success: applied symbolic chmod u+x to '$FILE_PATH'."
else
  echo "Error: symbolic chmod failed on '$FILE_PATH'." >&2
  exit 1
fi

# --- step 3: attempt chown only if running as root/sudo ---------------------
# id -u returns 0 for root. We check this instead of just trying chown and
# catching the failure, because we want a clear, intentional skip message
# rather than a generic permission-denied error.
CURRENT_UID=$(id -u)
if [[ "$CURRENT_UID" -eq 0 ]]; then
  # Chown to root:root as a harmless demonstration.
  if chown root:root "$FILE_PATH"; then
    echo "Success: changed ownership of '$FILE_PATH' to root:root."
  else
    echo "Error: chown failed even though running as root." >&2
    exit 1
  fi
else
  echo "Notice: skipping chown step - root privileges are required and this script is not running as root (current UID: $CURRENT_UID)."
fi

# --- step 4: report permissions again to show before/after -----------------
report_permissions "after changes"

echo "Done."
exit 0
