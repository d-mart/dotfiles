#!/bin/bash

# Upgrade git pager to fancier options if present.
# Fall back to less

if command -v diff-so-fancy >/dev/null 2>&1; then
  exec diff-so-fancy | less --tabs=4 -RFX
else
  exec less
fi
