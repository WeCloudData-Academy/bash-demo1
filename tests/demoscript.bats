#!/usr/bin/env bats

setup() {
  local root="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  SCRIPT="${EXERCISE_SCRIPT_DIR:-$root/scripts}/demoscript.sh"
  export LC_ALL=C
  mkdir "$BATS_TEST_TMPDIR/classroom"
  cd "$BATS_TEST_TMPDIR/classroom"
}

# Keep all test preparation and assertions in this file.
check_directory() {
  local listing expected
  listing="$(ls -1)"
  expected=$'Welcome! This is my first shell script!\nFiles in the current directory:\n'
  if [ -n "$listing" ]; then expected+="$listing"$'\n'; fi
  expected+="Current directory: $(pwd)"$'\n'
  printf '%s' "$expected" > "$BATS_TEST_TMPDIR/expected"
  run bash -c 'bash "$1" > "$2" 2> "$3"' _ "$SCRIPT" \
    "$BATS_TEST_TMPDIR/stdout" "$BATS_TEST_TMPDIR/stderr"
  [ "$status" -eq 0 ]
  [ ! -s "$BATS_TEST_TMPDIR/stderr" ]
  diff -u "$BATS_TEST_TMPDIR/expected" "$BATS_TEST_TMPDIR/stdout"
}

@test "Print the exact welcome, heading, complete listing, and current directory" {
  touch 'alpha.txt' 'two words.txt' '.hidden'
  mkdir folder
  check_directory
}

@test "An empty directory produces no invented listing lines" {
  check_directory
}

@test "Report another working directory whose path contains spaces" {
  mkdir 'another classroom'
  cd 'another classroom'
  touch 'a different file'
  check_directory
}
