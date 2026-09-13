#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Nayram Banyie Mawah
# @index        4191624
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven Todo List CRUD app. Data is stored in a CSV
#               file (todo_data.csv) next to the script. Every destructive
#               operation backs up the data file first.
# @date         2026-09-13
#
# Exit codes:
#   0 = normal exit chosen from menu
#   1 = missing/invalid data file that could not be recovered
# -----------------------------------------------------------------

set -u

DATA_FILE="todo_data.csv"
BACKUP_FILE="${DATA_FILE}.bak"

usage() {
  echo "Usage: $0"
  echo "  Interactive menu-driven Todo List app. No arguments needed."
  echo "  Data is stored in '$DATA_FILE' (CSV: id,description,status,due_date)."
  exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

# --- ensure the data file exists --------------------------------------------
# We create it with no records rather than failing, so a first-time run
# works out of the box.
if [[ ! -f "$DATA_FILE" ]]; then
  if ! : > "$DATA_FILE"; then
    echo "Error: could not create data file '$DATA_FILE'." >&2
    exit 1
  fi
  echo "Info: created new data file '$DATA_FILE'."
fi

# --- backup helper, called before any destructive change -------------------
backup_data() {
  if cp "$DATA_FILE" "$BACKUP_FILE"; then
    echo "Info: backed up data to '$BACKUP_FILE'."
  else
    echo "Error: failed to back up data file before making changes." >&2
    return 1
  fi
}

# --- generate the next numeric ID -------------------------------------------
next_id() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo 1
    return
  fi
  # Take the highest existing ID (field 1) and add 1.
  awk -F',' 'BEGIN{max=0} {if ($1+0>max) max=$1+0} END{print max+1}' "$DATA_FILE"
}

# --- Create -------------------------------------------------------------
add_task() {
  local desc status due id

  read -rp "Task description: " desc
  if [[ -z "$desc" ]]; then
    echo "Error: description cannot be empty. Task not added." >&2
    return 1
  fi

  read -rp "Status (pending/done) [pending]: " status
  status="${status:-pending}"
  if [[ "$status" != "pending" && "$status" != "done" ]]; then
    echo "Error: status must be 'pending' or 'done'. Task not added." >&2
    return 1
  fi

  read -rp "Due date (optional, e.g. 2026-09-20): " due

  id=$(next_id)
  # Store safely as CSV; description/due date are assumed not to contain commas
  # for simplicity, which is reasonable for a terminal todo app.
  if echo "${id},${desc},${status},${due}" >> "$DATA_FILE"; then
    echo "Success: added task #$id."
  else
    echo "Error: failed to write new task to '$DATA_FILE'." >&2
    return 1
  fi
}

# --- Read (list all) ---------------------------------------------------
list_tasks() {
  if [[ ! -s "$DATA_FILE" ]]; then
    echo "No tasks found."
    return
  fi
  printf "%-5s %-30s %-10s %-12s\n" "ID" "DESCRIPTION" "STATUS" "DUE DATE"
  echo "--------------------------------------------------------------"
  while IFS=',' read -r id desc status due; do
    printf "%-5s %-30s %-10s %-12s\n" "$id" "$desc" "$status" "$due"
  done < "$DATA_FILE"
}

# --- Read (search) ---------------------------------------------------
search_tasks() {
  local term results
  read -rp "Search term (matches description): " term
  if [[ -z "$term" ]]; then
    echo "Error: search term cannot be empty." >&2
    return 1
  fi

  results=$(grep -i "$term" "$DATA_FILE")
  if [[ -z "$results" ]]; then
    echo "No matching tasks found for '$term'."
  else
    printf "%-5s %-30s %-10s %-12s\n" "ID" "DESCRIPTION" "STATUS" "DUE DATE"
    echo "--------------------------------------------------------------"
    echo "$results" | while IFS=',' read -r id desc status due; do
      printf "%-5s %-30s %-10s %-12s\n" "$id" "$desc" "$status" "$due"
    done
  fi
}

# --- helper: does a task with this ID exist? --------------------------------
task_exists() {
  local search_id="$1"
  grep -q "^${search_id}," "$DATA_FILE"
}

# --- Update ---------------------------------------------------------
update_task() {
  local id new_desc new_status new_due tmp_file

  read -rp "Enter ID of task to update: " id
  if [[ -z "$id" || ! "$id" =~ ^[0-9]+$ ]]; then
    echo "Error: please enter a valid numeric ID." >&2
    return 1
  fi

  if ! task_exists "$id"; then
    echo "Notice: no task found with ID $id."
    return 1
  fi

  read -rp "New description (leave blank to keep current): " new_desc
  read -rp "New status (pending/done, leave blank to keep current): " new_status
  read -rp "New due date (leave blank to keep current): " new_due

  if [[ -n "$new_status" && "$new_status" != "pending" && "$new_status" != "done" ]]; then
    echo "Error: status must be 'pending' or 'done'. Update cancelled." >&2
    return 1
  fi

  backup_data || return 1

  tmp_file=$(mktemp) || { echo "Error: could not create temp file." >&2; return 1; }

  while IFS=',' read -r cur_id cur_desc cur_status cur_due; do
    if [[ "$cur_id" == "$id" ]]; then
      cur_desc="${new_desc:-$cur_desc}"
      cur_status="${new_status:-$cur_status}"
      cur_due="${new_due:-$cur_due}"
    fi
    echo "${cur_id},${cur_desc},${cur_status},${cur_due}" >> "$tmp_file"
  done < "$DATA_FILE"

  if mv "$tmp_file" "$DATA_FILE"; then
    echo "Success: updated task #$id."
  else
    echo "Error: failed to save updated data." >&2
    rm -f "$tmp_file"
    return 1
  fi
}

# --- Delete ---------------------------------------------------------
delete_task() {
  local id confirm tmp_file

  read -rp "Enter ID of task to delete: " id
  if [[ -z "$id" || ! "$id" =~ ^[0-9]+$ ]]; then
    echo "Error: please enter a valid numeric ID." >&2
    return 1
  fi

  if ! task_exists "$id"; then
    echo "Notice: no task found with ID $id."
    return 1
  fi

  read -rp "Are you sure you want to delete task #$id? (y/N): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Cancelled: task #$id was not deleted."
    return 0
  fi

  backup_data || return 1

  tmp_file=$(mktemp) || { echo "Error: could not create temp file." >&2; return 1; }
  grep -v "^${id}," "$DATA_FILE" > "$tmp_file"

  if mv "$tmp_file" "$DATA_FILE"; then
    echo "Success: deleted task #$id."
  else
    echo "Error: failed to save data after deletion." >&2
    rm -f "$tmp_file"
    return 1
  fi
}

# --- menu ------------------------------------------------------------------
show_menu() {
  echo ""
  echo "===== Todo List Menu ====="
  echo "1) Add task"
  echo "2) View all tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Exit"
  echo "==========================="
}

main_loop() {
  local choice
  while true; do
    show_menu
    read -rp "Choose an option [1-6]: " choice
    case "$choice" in
      1) add_task ;;
      2) list_tasks ;;
      3) search_tasks ;;
      4) update_task ;;
      5) delete_task ;;
      6)
        echo "Goodbye."
        exit 0
        ;;
      *)
        echo "Error: invalid option '$choice'. Please choose 1-6." >&2
        ;;
    esac
  done
}

main_loop
