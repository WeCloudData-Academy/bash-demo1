#!/bin/bash
# Read one integer from each input line.
read -r a
read -r b

# Choose exactly one of the three possible relationships.
if [ "$a" -gt "$b" ]; then
  echo "$a is greater than $b"
elif [ "$a" -lt "$b" ]; then
  echo "$b is greater than $a"
else
  echo "$a is equal to $b"
fi
