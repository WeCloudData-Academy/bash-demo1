#!/bin/bash
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST_FILE="${HOST_FILE:-$SCRIPT_DIR/hostfile}"
LOG_FILE="${LOG_FILE:-./pingresults.log}"

# TODO: Use a for loop to visit every whitespace-separated address in HOST_FILE
# in order, including repeats. Call ping -c 1 <address> exactly once per item.
# Append both ping output streams to LOG_FILE without changing its existing contents.
# Print exactly <address> Host is Up on success or <address> Host is not reachable
# on failure, one line per item. Continue after failures. Support paths with spaces
# and the provided defaults. Keep HOST_FILE unchanged. For an empty list, do nothing. Leave stderr empty and
# finish with status 0 in every case. Assume the host list is readable and log writable.

# Replace the two placeholder lines with your solution.
printf 'Exercise not implemented yet.\n' >&2
exit 1
