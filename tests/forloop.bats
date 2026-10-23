#!/usr/bin/env bats

setup() {
  local root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="${EXERCISE_SCRIPT_DIR:-$root/scripts}/forloop.sh"
  export HOST_FILE="$BATS_TEST_TMPDIR/host list"
  export LOG_FILE="$BATS_TEST_TMPDIR/ping results.log"
  export CALL_LOG="$BATS_TEST_TMPDIR/calls"
  export REACHABLE_HOSTS="$BATS_TEST_TMPDIR/reachable"
  : > "$HOST_FILE"
  : > "$REACHABLE_HOSTS"
  mkdir "$BATS_TEST_TMPDIR/bin" "$BATS_TEST_TMPDIR/classroom"
  export PATH="$BATS_TEST_TMPDIR/bin:$PATH"
  # The simulated ping belongs to this test and needs no real network.
  cat > "$BATS_TEST_TMPDIR/bin/ping" <<'MOCK'
#!/bin/bash
printf '%s' "$#" >> "$CALL_LOG"
printf '\t%s' "$@" >> "$CALL_LOG"
printf '\n' >> "$CALL_LOG"
[ "$#" -eq 3 ] && [ "$1" = -c ] && [ "$2" = 1 ] || exit 2
printf 'stdout:%s\n' "$3"
printf 'stderr:%s\n' "$3" >&2
grep -Fxq -- "$3" "$REACHABLE_HOSTS"
MOCK
  chmod +x "$BATS_TEST_TMPDIR/bin/ping"
  cd "$BATS_TEST_TMPDIR/classroom"
}

# Run directly with Bats and compare the complete output files.
check_hosts() {
  local host outcome expected='' calls='' log="${LOG_PREFIX:-}"
  while [ "$#" -gt 0 ]; do
    host="$1"; outcome="$2"; shift 2
    if [ "$outcome" = up ]; then expected+="$host Host is Up"$'\n'
    else expected+="$host Host is not reachable"$'\n'; fi
    calls+=$'3\t-c\t1\t'"$host"$'\n'
    log+="stdout:$host"$'\n'"stderr:$host"$'\n'
  done
  run bash -c 'bash "$1" > "$2" 2> "$3"' _ "$SCRIPT" \
    "$BATS_TEST_TMPDIR/stdout" "$BATS_TEST_TMPDIR/stderr"
  [ "$status" -eq 0 ]
  [ ! -s "$BATS_TEST_TMPDIR/stderr" ]
  printf '%s' "$expected" > "$BATS_TEST_TMPDIR/expected-output"
  diff -u "$BATS_TEST_TMPDIR/expected-output" "$BATS_TEST_TMPDIR/stdout"
  if [ -n "$calls" ]; then
    printf '%s' "$calls" > "$BATS_TEST_TMPDIR/expected-calls"
    diff -u "$BATS_TEST_TMPDIR/expected-calls" "$CALL_LOG"
  else [ ! -s "$CALL_LOG" ]; fi
  if [ -n "$log" ]; then
    printf '%s' "$log" > "$BATS_TEST_TMPDIR/expected-log"
    diff -u "$BATS_TEST_TMPDIR/expected-log" "$LOG_FILE"
  else [ ! -s "$LOG_FILE" ]; fi
}

@test "Mixed results preserve order, repeated hosts, ping arguments, and both log streams" {
  printf 'down.test\nup.test down-again.test\nup.test\n' > "$HOST_FILE"
  cp "$HOST_FILE" "$BATS_TEST_TMPDIR/original-hosts"
  printf 'up.test\n' > "$REACHABLE_HOSTS"
  check_hosts down.test down up.test up down-again.test down up.test up
  cmp "$HOST_FILE" "$BATS_TEST_TMPDIR/original-hosts"
}

@test "All failures still visit every host and finish successfully" {
  printf 'a.test\nb.test\nc.test\n' > "$HOST_FILE"
  check_hosts a.test down b.test down c.test down
}

@test "All successes report every host exactly once" {
  printf 'green.test\nblue.test\n' > "$HOST_FILE"
  cp "$HOST_FILE" "$REACHABLE_HOSTS"
  check_hosts green.test up blue.test up
}

@test "Preserve existing log bytes and append exact records on a second run" {
  printf 'up.test\ndown.test\n' > "$HOST_FILE"
  printf 'up.test\n' > "$REACHABLE_HOSTS"
  LOG_PREFIX='existing bytes without a newline'
  printf '%s' "$LOG_PREFIX" > "$LOG_FILE"
  check_hosts up.test up down.test down
  LOG_PREFIX+=$'stdout:up.test\nstderr:up.test\nstdout:down.test\nstderr:down.test\n'
  : > "$CALL_LOG"
  check_hosts up.test up down.test down
}

@test "An empty list makes no calls and preserves an existing log" {
  LOG_PREFIX=$'existing log\n'
  printf '%s' "$LOG_PREFIX" > "$LOG_FILE"
  check_hosts
}

@test "A whitespace-only list makes no calls and creates no log" {
  printf ' \n\t\n' > "$HOST_FILE"
  check_hosts
  [ ! -e "$LOG_FILE" ]
}

@test "Default host and log paths work from another working directory" {
  unset HOST_FILE LOG_FILE
  printf '8.8.8.8\n' > "$REACHABLE_HOSTS"
  # Keep the assertion path local so the script must choose its default.
  LOG_FILE="$PWD/pingresults.log"
  export -n LOG_FILE
  check_hosts 8.8.8.8 up 192.168.123.123 down
}
