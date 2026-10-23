#!/usr/bin/env bats

setup() {
  local root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="${EXERCISE_SCRIPT_DIR:-$root/scripts}/comparison.sh"
}

check_pairs() {
  local relation="$1" a b expected
  case "$relation" in
    less) expected=$'0\n0\n1\n1\n1\n0\n' ;;
    equal) expected=$'1\n0\n1\n0\n0\n1\n' ;;
    greater) expected=$'1\n1\n0\n0\n1\n0\n' ;;
  esac
  for a in -7 -1 0 1 7; do
    for b in -7 -1 0 1 7; do
      case "$relation" in
        less) [ "$a" -lt "$b" ] || continue ;;
        equal) [ "$a" -eq "$b" ] || continue ;;
        greater) [ "$a" -gt "$b" ] || continue ;;
      esac
      printf '%s\n%s\n' "$a" "$b" > "$BATS_TEST_TMPDIR/input"
      printf '%s' "$expected" > "$BATS_TEST_TMPDIR/expected"
      run bash -c 'bash "$1" < "$2" > "$3" 2> "$4"' _ "$SCRIPT" \
        "$BATS_TEST_TMPDIR/input" "$BATS_TEST_TMPDIR/stdout" "$BATS_TEST_TMPDIR/stderr"
      [ "$status" -eq 0 ] || return 1
      [ ! -s "$BATS_TEST_TMPDIR/stderr" ] || return 1
      diff -u "$BATS_TEST_TMPDIR/expected" "$BATS_TEST_TMPDIR/stdout" || return 1
    done
  done
}

@test "Less: exactly six correct comparison statuses in order" {
  check_pairs less
}

@test "Equal: exactly six correct comparison statuses in order" {
  check_pairs equal
}

@test "Greater: exactly six correct comparison statuses in order" {
  check_pairs greater
}
