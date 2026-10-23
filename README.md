<div align="left"><img src="https://s3.amazonaws.com/weclouddata/images/logos/wcd_logo_new_2.png" alt="WeCloudData" width="25%"></div>

## Bash Lab: Output, Decisions, Comparisons, and Loops

A Bash script is a saved sequence of commands. In this lab, you will write four small scripts: one that introduces itself, one that chooses a message, one that checks numbers, and one that repeats a task. Read the explanation, try the example, then write the exercise yourself.

### Your workspace

In Coder, open `~/bash-demo1` in the editor. Open the integrated terminal and run `cd ~/bash-demo1`. Keep the terminal in this lab root for every command below.

```text
bash-demo1/
├── scripts/
│   ├── demoscript.sh
│   ├── if_else.sh
│   ├── comparison.sh
│   ├── forloop.sh
│   └── hostfile
├── solutions/
│   ├── demoscript.sh
│   ├── if_else.sh
│   ├── comparison.sh
│   └── forloop.sh
├── tests/
│   ├── demoscript.bats
│   ├── if_else.bats
│   ├── comparison.bats
│   └── forloop.bats
└── README.md
```

Each exercise script has one `TODO` comment describing its complete task. Write your code below it. Replace the placeholder message and `exit 1` if present. Save before testing. Use `bash`, rather than `sh`, to run these scripts. All numeric inputs are valid decimal integers without leading zeros; input-error handling is outside this lab.

### 1. Commands, variables, and output

Bash runs commands in order. `echo` prints a line, `ls -1` lists visible entries one per line, and `pwd` prints the current working directory. A comment begins with `#` and explains the code without being executed. The first line `#!/bin/bash` identifies the interpreter for direct execution; `bash file.sh` also chooses Bash explicitly.

A variable gives a value a name. Write `name="Maya"` without spaces around `=`, and use `"$name"` to read the value. Double quotes keep text with spaces together. `$(command)` captures a command's output so you can include it in a message. For example:

```bash
name="Maya"
echo "Hello, $name"
echo "Our classroom folder is $(pwd)"
```

This prints two lines: `Hello, Maya` and a message containing your current directory. Notice that the directory comes from the computer; it is not typed into the script.

#### Exercise: Introduce your script

Open `scripts/demoscript.sh`. Print the following content in this exact order: `Welcome! This is my first shell script!`, then `Files in the current directory:`, then the complete output of `ls -1`, then `Current directory: <path>`. Use `pwd` to obtain `<path>`. End each output line with a newline, print nothing extra, leave error output empty, and finish successfully.

Run `bash scripts/demoscript.sh` from the lab root. You should see the two opening lines, the visible lab entries, and the current directory on the final line. Check with `bats tests/demoscript.bats`. These tests check the complete output in three different directory situations, including an empty folder and a path containing spaces. They compare the results those commands should produce. An extra standalone path line is an error, even if the correct final line also appears.

### 2. Input and if/else decisions

`read -r value` waits for one line of keyboard input and stores it in `value`. An `if` statement then chooses what to do. `[ "$value" -gt 5 ]` asks whether a number is greater than 5; the spaces inside `[ ... ]` are required. `else` handles a false condition, and `elif` checks another condition when needed.

```bash
read -r age
if [ "$age" -ge 18 ]; then
  echo "Adult ticket"
else
  echo "Youth ticket"
fi
```

Enter 20 and you get `Adult ticket`; enter 12 and you get `Youth ticket`. Only one branch runs. With two numbers, remember a third possibility: they can be equal. `-gt` means greater than, `-lt` means less than, and `-eq` means equal.

#### Exercise: Choose the correct comparison message

Open `scripts/if_else.sh`. Read two integers, `a` and `b`, on separate lines. Use `if`/`else` branching, adding `elif` or a nested decision as needed. Print exactly one result line and no input prompts:

| Situation | Required result |
| --- | --- |
| `a > b` | `<a> is greater than <b>` |
| `a < b` | `<b> is greater than <a>` |
| `a = b` | `<a> is equal to <b>` |

Replace the placeholders with the input values. Leave error output empty and finish with status 0. Run `bash scripts/if_else.sh`, enter `9`, press Enter, then enter `3`. Expect `9 is greater than 3`. Try `5` and `5` as well. Verify with `bats tests/if_else.bats`; it checks all 25 ordered pairs from `-7, -1, 0, 1, 7`, covering greater, less, equal, negative, and zero cases.

### 3. Comparisons and exit status

Every command returns an exit status. A status of 0 means success; a nonzero value means failure. A comparison uses this same rule: a true condition returns 0 and a false one returns 1. `$?` holds the status of the command that just finished. Print it immediately, because running another command replaces it.

```bash
test 4 -lt 9
echo "$?"
test 4 -eq 9
echo "$?"
```

The example prints 0 and then 1. `test condition` and `[ condition ]` are two forms of the same kind of check. These are the six integer comparison operators:

| Operator | Meaning |
| --- | --- |
| `-lt` | Less than |
| `-le` | Less than or equal to |
| `-gt` | Greater than |
| `-ge` | Greater than or equal to |
| `-eq` | Equal to |
| `-ne` | Not equal to |

#### Exercise: Show all six comparison results

Open `scripts/comparison.sh`. Read integers `h` and `g` on separate lines. Execute `test` or `[ ]` for the six operators in the table's order. Immediately after each comparison, run `echo "$?"`. Print exactly six newline-terminated result lines, without prompts, and finish with status 0 and empty error output.

Run `bash scripts/comparison.sh` and enter `3`, then `5`. Expect six lines: `0`, `0`, `1`, `1`, `1`, `0`. Before trying equal inputs, predict which checks will succeed. Verify with `bats tests/comparison.bats`. The tests use all 25 ordered pairs from the same five-number set. They compare every output byte and check all six result positions for each pair of inputs.

### 4. for loops and command results

A `for` loop applies the same commands to each item in a list. For example, this prints three separate lines:

```bash
for color in red green blue; do
  echo "Color: $color"
done
```

Bash puts the next item into `color`, runs the body, and repeats until the list ends. You can use `$(cat "$HOST_FILE")` as a simple whitespace-separated list of host addresses. This is suitable here because addresses contain no spaces; it is not a general method for reading arbitrary text lines.

A command can also provide the condition for `if`. With `if ping -c 1 "$host"; then ...; else ...; fi`, a successful ping selects the first branch and a failure selects the second. Ordinary output and error output are separate streams. `>> "$LOG_FILE" 2>&1` appends both streams to the log: first redirect ordinary output, then send error output to the same destination. `>>` preserves old content, while `>` replaces it.

#### Exercise: Check every host and keep a log

Open `scripts/forloop.sh`. Keep its provided setup variables. `HOST_FILE` defaults to `hostfile` beside the script; `LOG_FILE` defaults to `pingresults.log` in the current directory. Use a `for` loop to process every whitespace-separated address in file order, including repeated addresses. Call `ping -c 1 <address>` exactly once for each item and append both ping output streams to the log.

Print only `<address> Host is Up` for a success or `<address> Host is not reachable` for a failure, one newline-terminated line per item. Continue after failures and finish with status 0. Support input and log paths containing spaces. For an empty list, produce no messages or ping calls, preserve an existing log, and do not create a new log. Assume the input file is readable and the log location is writable. No error output should escape to the terminal.

Run `LOG_FILE="./ping results.log" bash scripts/forloop.sh` from the lab root. You should see one status per supplied host; actual reachability depends on your network. Check with `bats tests/forloop.bats`. Its simulated hosts verify exact call arguments and order, success and failure messages, continuation, repeats, complete log bytes, append behavior across two runs, empty and whitespace-only lists, paths with spaces, and both default paths. The host list must remain unchanged.

### How to test your exercises

#### Step 1: Open the terminal in the lab root

Save your script, then run these commands in Coder's integrated terminal:

```bash
cd ~/bash-demo1
unset EXERCISE_SCRIPT_DIR
pwd
ls
```

`pwd` should show your home directory followed by `/bash-demo1`. `ls` should include `README.md`, `scripts`, `solutions`, and `tests`. Stay in this lab root when running the commands below. The `unset` command makes sure the tests check your exercises instead of a previously selected answer folder.

#### Step 2: Test one script at a time

Choose the row matching the script you edited. Run its command from the lab root. Bats supplies the inputs automatically, so you do not type numbers or host addresses during a test. The host tests simulate `ping` and need no network connection.

| Script you write | Command to run from the lab root | Output when every check passes |
| --- | --- | --- |
| `scripts/demoscript.sh` | `bats --formatter tap tests/demoscript.bats` | `1..3`, followed by 3 `ok` result lines |
| `scripts/if_else.sh` | `bats --formatter tap tests/if_else.bats` | `1..3`, followed by 3 `ok` result lines |
| `scripts/comparison.sh` | `bats --formatter tap tests/comparison.bats` | `1..3`, followed by 3 `ok` result lines |
| `scripts/forloop.sh` | `bats --formatter tap tests/forloop.bats` | `1..7`, followed by 7 `ok` result lines |

The `--formatter tap` option keeps the output in the plain text format shown here. It does not change what the tests check. If you use the shorter command `bats tests/demoscript.bats`, an interactive terminal may show checkmarks, crosses, and a summary instead.

#### Step 3: Recognize a passing result

After you correctly finish `demoscript.sh`, its test command produces:

```text
1..3
ok 1 Print the exact welcome, heading, complete listing, and current directory
ok 2 An empty directory produces no invented listing lines
ok 3 Report another working directory whose path contains spaces
```

`1..3` means there are three test cases. Each `ok` means that case passed. The other scripts follow the same format, using their own test names and the counts in the table. A fully passing run contains no `not ok` lines. Bats reports test results rather than displaying the script's normal welcome message or comparison results.

#### Step 4: Recognize a failing result and revise your code

If a requirement is not met, you will see `not ok` followed by the test name and details about the failed check. For example, an unfinished `demoscript.sh` produces output like this excerpt:

```text
1..3
not ok 1 Print the exact welcome, heading, complete listing, and current directory
# (from function `check_directory' in file tests/demoscript.bats, line 21,
#  in test file tests/demoscript.bats, line 29)
#   `check_directory' failed
```

The remaining test cases are listed after this excerpt. Line numbers can change if the test file is edited. The same rule applies to all four scripts: even one `not ok` means that the run did not fully pass. An unfinished exercise is expected to fail.

Read the failed test's name, return to the matching file in `scripts/`, fix your code, save it, and run the same command again. Do not change the tests to make your answer pass. If a `diff` is shown, lines beginning with `-` describe expected content, and lines beginning with `+` describe actual content; the `---` and `+++` lines are file headings. Extra messages, missing lines, or incorrect final newlines can cause a failure even when part of your answer is correct.

For more diagnostic output, run `bats --formatter tap --print-output-on-failure tests/demoscript.bats`, replacing the filename for another exercise. These tests capture script output in temporary files; the extra output may show a difference report rather than the full script output. You can also run `bash scripts/demoscript.sh` manually to inspect what it prints. For input-based scripts, enter values only during that manual run.

Immediately after any test command, run `echo "$?"` if you want its exit status. `0` means all checks passed; `1` means at least one test failed. Run it before any other command, because another command replaces that status. If a test file cannot be found, run `cd ~/bash-demo1` and try the command again.

#### Step 5: Check the whole lab

From the same lab root, run `bats --formatter tap tests/`. A successful run starts with `1..16` and has 16 `ok` lines, with no `not ok` lines. If any case fails, use its name to identify the exercise and run that script's individual test again after fixing it.

There are 16 test cases, some containing several input combinations. The numeric exercises each cover all 25 ordered pairs from `-7, -1, 0, 1, 7`. Every exercise has one self-contained `.bats` file. Tests check complete output bytes, exit status, error output, host calls, and log contents as appropriate. The instructor reviews the requested commands, branching, and loops; output tests do not prove a particular implementation. If your code loops forever, press `Ctrl+C`, fix it, and run the test again.

### Reference solutions

The `solutions/` folder contains a complete answer for each of the four exercises, with brief comments explaining the code. Try the exercises first, then compare your approach with these examples. Run an answer from the lab root, for example `bash solutions/demoscript.sh`. The host-loop answer reuses `scripts/hostfile` by default.

To check all four answers using the same tests, run `EXERCISE_SCRIPT_DIR="$PWD/solutions" bats tests/` from the lab root. Running `bats tests/` without that setting continues to check your work in `scripts/`.
