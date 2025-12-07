# Bail early if gpg isn't installed
if ! command -v gpg &>/dev/null; then
  return 0
fi

# Required for GPG to know which terminal to use for passphrase prompts
export GPG_TTY=$(tty)

# Start gpg-agent if not already running
if command -v gpg-agent &>/dev/null; then
  gpg-agent --daemon &>/dev/null 2>&1 || true
fi

# Optional: helper to check if you have any secret keys
function gpg-has-keys() {
  gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -q sec
}

# Optional: warn on shell start if no keys exist (remove if annoying)
if [[ -t 1 ]] && ! gpg-has-keys; then
  echo "[gpg] No secret keys found. Run 'gpg --full-generate-key' to create one."
fi

# create gpg-agent config if it doesn't exist
if [[ ! -f ~/.gnupg/gpg-agent.conf ]]; then
  mkdir -p ~/.gnupg
  cat <<EOF > ~/.gnupg/gpg-agent.conf
default-cache-ttl 3600
max-cache-ttl 86400
#pinentry-program pinentry-tty
EOF
  chmod 600 ~/.gnupg/gpg-agent.conf
fi
