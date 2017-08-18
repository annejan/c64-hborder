#!/bin/bash
if [[ -f hborder.prg ]]; then
  rm hborder.prg
fi

# Build the object
java -jar ../../KickAss.jar hborder.asm

if [[ -f hborder.prg ]]; then
  x64 hborder.prg
fi
