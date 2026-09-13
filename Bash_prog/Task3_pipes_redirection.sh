#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Nayram Banyie Mawah
# @index        4191624
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data, then uses pipes and text tools
#               (grep, sort, uniq, wc, awk, cut) to summarize it: total
#               lines, counts per log level, top 3 IPs, and all ERROR lines.
#               Output goes to results.txt; any pipeline errors go to
#               errors.log instead of the terminal.
# @date         2026-09-13
# -----------------------------------------------------------------

set -u

usage() {
  echo "Usage: $0"
  echo "  Takes no arguments. Generates its own sample log data."
  exit 1
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
fi

LOG_FILE="sample.log"
RESULTS_FILE="results.txt"
ERRORS_FILE="errors.log"

# Truncate/reset previous outputs so re-running the script doesn't append to
# stale results from a prior run.
: > "$ERRORS_FILE"

# --- generate sample log data via heredoc -----------------------------------
# We generate the data ourselves so the script is fully self-contained and
# reproducible without needing an external log file to be supplied.
if ! cat > "$LOG_FILE" <<'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 INFO 192.168.1.11 User login successful
2026-09-11 10:00:30 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:00:45 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:01:01 INFO 192.168.1.12 File uploaded
2026-09-11 10:01:20 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:40 INFO 192.168.1.10 User logout
2026-09-11 10:02:00 WARN 192.168.1.14 High memory usage
2026-09-11 10:02:20 INFO 192.168.1.15 User login successful
2026-09-11 10:02:45 ERROR 192.168.1.16 Authentication failed
2026-09-11 10:03:00 INFO 192.168.1.10 User login successful
2026-09-11 10:03:20 INFO 192.168.1.17 File downloaded
2026-09-11 10:03:40 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:04:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:04:20 INFO 192.168.1.18 User login successful
2026-09-11 10:04:45 INFO 192.168.1.10 File uploaded
2026-09-11 10:05:00 ERROR 192.168.1.19 Database connection lost
2026-09-11 10:05:20 INFO 192.168.1.20 User login successful
2026-09-11 10:05:40 WARN 192.168.1.11 CPU usage above 90%
2026-09-11 10:06:00 INFO 192.168.1.10 User logout
2026-09-11 10:06:20 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:06:45 INFO 192.168.1.21 User login successful
2026-09-11 10:07:00 INFO 192.168.1.10 File uploaded
2026-09-11 10:07:20 WARN 192.168.1.14 High memory usage
2026-09-11 10:07:45 ERROR 192.168.1.16 Authentication failed
2026-09-11 10:08:00 INFO 192.168.1.22 User login successful
2026-09-11 10:08:20 INFO 192.168.1.10 User login successful
2026-09-11 10:08:40 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:09:00 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:09:20 INFO 192.168.1.24 File uploaded
2026-09-11 10:09:45 INFO 192.168.1.10 User logout
2026-09-11 10:10:00 WARN 192.168.1.11 CPU usage above 90%
2026-09-11 10:10:20 ERROR 192.168.1.19 Database connection lost
2026-09-11 10:10:45 INFO 192.168.1.25 User login successful
2026-09-11 10:11:00 INFO 192.168.1.10 File downloaded
2026-09-11 10:11:20 WARN 192.168.1.14 High memory usage
2026-09-11 10:11:45 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:12:00 INFO 192.168.1.10 User login successful
2026-09-11 10:12:20 INFO 192.168.1.26 File uploaded
2026-09-11 10:12:45 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:13:00 ERROR 192.168.1.16 Authentication failed
2026-09-11 10:13:20 INFO 192.168.1.27 User login successful
2026-09-11 10:13:45 INFO 192.168.1.10 User logout
2026-09-11 10:14:00 WARN 192.168.1.11 CPU usage above 90%
2026-09-11 10:14:20 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:14:45 INFO 192.168.1.28 User login successful
2026-09-11 10:15:00 INFO 192.168.1.10 File uploaded
2026-09-11 10:15:20 WARN 192.168.1.14 High memory usage
2026-09-11 10:15:45 ERROR 192.168.1.19 Database connection lost
2026-09-11 10:16:00 INFO 192.168.1.29 User login successful
2026-09-11 10:16:20 INFO 192.168.1.10 User login successful
2026-09-11 10:16:45 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:17:00 ERROR 192.168.1.23 Connection timeout
EOF
then
  echo "Error: failed to generate sample log data." >&2
  exit 1
fi

echo "Info: generated $(wc -l < "$LOG_FILE") lines of sample log data in '$LOG_FILE'."

# --- build the summary report ------------------------------------------------
# Each pipeline's stderr is redirected to $ERRORS_FILE (2>>) instead of the
# terminal, per the task's redirection requirement. Using >> (append) so
# multiple pipeline failures across this script all land in the same file.
{
  echo "===== Log Summary Report ====="
  echo "Generated: $(date)"
  echo ""

  # 1. Total number of log lines
  echo "-- Total lines --"
  wc -l < "$LOG_FILE" 2>>"$ERRORS_FILE"
  echo ""

  # 2. Count of lines per log level
  # awk pulls out the 3rd whitespace-separated field (the level), then we
  # sort + count occurrences of each unique value.
  echo "-- Lines per log level --"
  awk '{print $3}' "$LOG_FILE" 2>>"$ERRORS_FILE" | sort | uniq -c | sort -rn
  echo ""

  # 3. Top 3 most frequent IP addresses
  # The IP is the 4th field. We count occurrences, sort numerically
  # descending, and keep only the top 3.
  echo "-- Top 3 IP addresses --"
  awk '{print $4}' "$LOG_FILE" 2>>"$ERRORS_FILE" | sort | uniq -c | sort -rn | head -n 3
  echo ""

  # 4. All ERROR lines
  echo "-- All ERROR lines --"
  grep "ERROR" "$LOG_FILE" 2>>"$ERRORS_FILE"
  echo ""

  echo "===== End of report ====="
} > "$RESULTS_FILE"

# --- verify the report was actually produced --------------------------------
if [[ -s "$RESULTS_FILE" ]]; then
  echo "Success: summary report written to '$RESULTS_FILE'."
else
  echo "Error: '$RESULTS_FILE' was not created or is empty." >&2
  exit 1
fi

if [[ -s "$ERRORS_FILE" ]]; then
  echo "Notice: some pipeline commands reported errors - see '$ERRORS_FILE'."
else
  echo "Info: no pipeline errors were recorded."
fi

exit 0
