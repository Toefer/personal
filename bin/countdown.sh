#!/usr/bin/env bash
# countdown.sh
#
# will countdown from x seconds then alarm continously until interrupted
# Tested on MacOS 10.12.5 and Ubuntu 16.04.2 LTS
# For Macs, I used jot. Otherwise, I used seq to countdown/up.

# usage
function usage {
  echo "Usage: $0 <minutes>"
  echo
  echo "Will countdown from X minutes then alarm continuously until interrupted (Ctrl-c)"
}

function clear_screen {
  echo -ne '\0033\0143'
}

function get_screen_dimensions {
  COLUMNS=$(tput cols)
  LINES=$(tput lines)
  WIDTH=$(( $COLUMNS - 16 - 1 ))   # remove spacing to print times and allow cursor at the eol
  HEIGHT=$(( $LINES - 1 ))
}

function print_counter {
  if [[ $(uname -s) == "Darwin" ]]; then
    command="jot - 1 $HEIGHT"
  else
    command="seq 1 $HEIGHT"
  fi
  CD_HOUR=$(($1/3600))
  CD_MIN=$((($1/60)%60))
  CD_SEC=$(($1%60))
  printf "\r%02d:%02d:%02d%${WIDTH}s%02d:%02d:%02d" $CD_HOUR $CD_MIN $CD_SEC ' ' $CD_HOUR $CD_MIN $CD_SEC
  for j in $($command); do
    echo
  done 
  printf "\r%02d:%02d:%02d%${WIDTH}s%02d:%02d:%02d" $CD_HOUR $CD_MIN $CD_SEC ' ' $CD_HOUR $CD_MIN $CD_SEC
}


# clear screen on exit
trap "clear_screen; exit" SIGINT

# check args
if [[ $# -ne 1  ]]; then
  usage
  exit 1
else
  CD_SECOND=$(expr $1 \* 60)
fi

# some variable checking
re='^[0-9]+$'
if ! [[ $CD_SECOND =~ $re ]]; then
  usage
  exit 1
elif [ $CD_SECOND -gt 359999 ]; then
  usage
  exit 1
elif [ $CD_SECOND -lt 1 ]; then
  usage
  exit 1
fi

clear_screen

# countdown.  print times on left and right hand sides of the terminal
if [[ $(uname -s) == "Darwin" ]]; then
  command="jot - $CD_SECOND 1"
else
  command="seq $CD_SECOND -1 1"
fi

for i in $($command); do
  get_screen_dimensions
  print_counter $i
  sleep 1
done

# countup.  beep continuously every second until receive a SIGINT
i=0
while true; do
  get_screen_dimensions
  print_counter $i
  sleep 1
  i=$(($i+1))
  printf "\a"
done

