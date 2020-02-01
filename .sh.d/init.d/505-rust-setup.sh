# shell environment setup for rust

## rustup if present
if [[ -d ~/.cargo/bin ]]; then
    export PATH="${PATH}:${HOME}/.cargo/bin"
fi
