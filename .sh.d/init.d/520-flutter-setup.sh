# shell environment setup for flutter

## rustup if present
if [[ -d ~/lib/flutter/bin ]]; then
  export PATH="${PATH}:${HOME}/lib/flutter/bin"
fi
