#!/bin/bash
ENTRIES=( "$@" )
for ENTRY in "${ENTRIES[@]}"
do
  grep "${ENTRY}" /etc/hosts > /dev/null
  RETVAL=$?

  if [ $RETVAL -ne 0 ]; then
    echo "${ENTRY}" >> /etc/hosts
  fi
done
