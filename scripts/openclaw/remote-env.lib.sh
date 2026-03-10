#!/usr/bin/env bash

remote_env_prelude() {
  cat <<'EOF'
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.npm-global/bin:$HOME/.volta/bin:$HOME/.asdf/shims:/opt/homebrew/bin:/usr/local/bin:$PATH"

for dir in "$HOME"/node-v*/bin; do
  if [ -d "$dir" ]; then
    export PATH="$dir:$PATH"
  fi
done

if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)" >/dev/null 2>&1 || true
fi
if [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)" >/dev/null 2>&1 || true
fi

for file in "$HOME/.zprofile" "$HOME/.zshrc" "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.profile"; do
  if [ -f "$file" ]; then
    . "$file" >/dev/null 2>&1 || true
  fi
done

if [ -s "$HOME/.nvm/nvm.sh" ]; then
  . "$HOME/.nvm/nvm.sh" >/dev/null 2>&1 || true
  nvm use --silent default >/dev/null 2>&1 || true
fi
EOF
}
