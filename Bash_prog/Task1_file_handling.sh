#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task1_file_handling.sh
# @author       Nayram Banyie Mawah
# @index        4191624
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Demonstrates basic file handling: create dir/file, write,
#               append, read, backup, and safe deletion, with checks at
#               every step.
# @date         2026-09-13
# -----------------------------------------------------------------

set -u  # treat unset variables as errors (helps catch typos in var names)

usage() {
  echo "Usage: $0 <target-directory>"
  echo "  <target-directory>  path to the directory this script will work in"
  exit 1
}

# --- argument validation -------------------------------------------------
# We check argument count first because every later step depends on having
# a valid directory to work inside of. Failing fast here avoids confusing
# errors further down the script.
if [[ "$#" -ne 1 ]]; then
  echo "Error: exactly one argument is required." >&2
  usage
fi

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

TARGET_DIR="$1"
FILE_NAME="sample.txt"
FILE_PATH="${TARGET_DIR}/${FILE_NAME}"
BACKUP_PATH="${FILE_PATH}.bak"

# --- step 1: create directory if it doesn't exist -------------------------
if [[ -d "$TARGET_DIR" ]]; then
  echo "Info: directory '$TARGET_DIR' already exists."
else
  # mkdir -p so it also creates any missing parent directories
  if mkdir -p "$TARGET_DIR"; then
    echo "Success: created directory '$TARGET_DIR'."
  else
    echo "Error: could not create directory '$TARGET_DIR' (permission denied?)." >&2
    exit 1
  fi
fi

# --- step 2: create a new file and write content --------------------------
# Using '>' (not '>>') here because we specifically want to create/overwrite
# the file with fresh content at this stage.
if echo "This is the initial content of the file." > "$FILE_PATH"; then
  echo "Success: created and wrote to '$FILE_PATH'."
else
  echo "Error: failed to write to '$FILE_PATH'." >&2
  exit 1
fi

# --- step 3: append additional content -------------------------------------
if echo "This line was appended afterwards." >> "$FILE_PATH"; then
  echo "Success: appended content to '$FILE_PATH'."
else
  echo "Error: failed to append to '$FILE_PATH'." >&2
  exit 1
fi

# --- step 4: read and display the file's contents ---------------------------
if [[ -r "$FILE_PATH" ]]; then
  echo "----- Contents of $FILE_PATH -----"
  cat "$FILE_PATH"
  echo "-----------------------------------"
else
  echo "Error: '$FILE_PATH' is not readable." >&2
  exit 1
fi

# --- step 5: copy the file to a .bak version --------------------------------
if cp "$FILE_PATH" "$BACKUP_PATH"; then
  echo "Success: backed up '$FILE_PATH' to '$BACKUP_PATH'."
else
  echo "Error: failed to create backup '$BACKUP_PATH'." >&2
  exit 1
fi

# --- step 6: delete the original, only after confirming it exists ----------
# We re-check existence right before deleting (rather than trusting earlier
# state) in case something else modified the filesystem mid-script.
if [[ -f "$FILE_PATH" ]]; then
  echo "Notice: about to delete '$FILE_PATH' (backup already exists at '$BACKUP_PATH')."
  if rm "$FILE_PATH"; then
    echo "Success: deleted '$FILE_PATH'."
  else
    echo "Error: failed to delete '$FILE_PATH'." >&2
    exit 1
  fi
else
  echo "Error: '$FILE_PATH' does not exist, nothing to delete." >&2
  exit 1
fi

echo "Done. All file handling operations completed successfully."
exit 0
