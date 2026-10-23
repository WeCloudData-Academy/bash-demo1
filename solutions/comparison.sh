#!/bin/bash
read -r h
read -r g

# Print each comparison's exit status before another command can replace it.
test "$h" -lt "$g"
echo "$?"
test "$h" -le "$g"
echo "$?"
test "$h" -gt "$g"
echo "$?"
test "$h" -ge "$g"
echo "$?"
test "$h" -eq "$g"
echo "$?"
test "$h" -ne "$g"
echo "$?"
