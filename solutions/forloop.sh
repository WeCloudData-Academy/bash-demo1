#!/bin/bash
# Reuse the host list from the exercises rather than keeping a second copy.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HOST_FILE="${HOST_FILE:-$SCRIPT_DIR/../scripts/hostfile}"
LOG_FILE="${LOG_FILE:-./pingresults.log}"

# Addresses contain no spaces, so whitespace splitting produces the intended list.
for host in $(cat "$HOST_FILE"); do
  if ping -c 1 "$host" >> "$LOG_FILE" 2>&1; then
    echo "$host Host is Up"
  else
    echo "$host Host is not reachable"
  fi
done

# Completing the list is successful even when individual hosts are unreachable.
exit 0
