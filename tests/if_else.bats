#!/usr/bin/env bats

setup() {
  local root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="${EXERCISE_SCRIPT_DIR:-$root/scripts}/if_else.sh"
}

check_pairs() {
  local relation="$1" a b expected
  for a in -7 -1 0 1 7; do
    for b in -7 -1 0 1 7; do
      case "$relation" in
        greater) [ "$a" -gt "$b" ] || continue; expected="$a is greater than $b" ;;
        less) [ "$a" -lt "$b" ] || continue; expected="$b is greater than $a" ;;
        equal) [ "$a" -eq "$b" ] || continue; expected="$a is equal to $b" ;;
      esac
      printf '%s\n%s\n' "$a" "$b" > "$BATS_TEST_TMPDIR/input"
      printf '%s\n' "$expected" > "$BATS_TEST_TMPDIR/expected"
      run bash -c 'bash "$1" < "$2" > "$3" 2> "$4"' _ "$SCRIPT" \
        "$BATS_TEST_TMPDIR/input" "$BATS_TEST_TMPDIR/stdout" "$BATS_TEST_TMPDIR/stderr"
      [ "$status" -eq 0 ] || return 1
      [ ! -s "$BATS_TEST_TMPDIR/stderr" ] || return 1
      diff -u "$BATS_TEST_TMPDIR/expected" "$BATS_TEST_TMPDIR/stdout" || return 1
    done
  done
}

@test "First number greater: exact result for positive, negative, and zero inputs" {
  check_pairs greater
}

@test "Second number greater: exact result for positive, negative, and zero inputs" {
  check_pairs less
}

@test "Equal numbers: exact result for negative, zero, and positive inputs" {
  check_pairs equal
}
