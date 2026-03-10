#!/usr/bin/env bash
#
# Install PostgreSQL in the Lume macOS VM and set the postgres role password.
# Uses the same VM name and IP resolution as ssh-vm.sh / openclaw-in-vm.sh.
#
# Env:
#   VM_NAME - VM name (default: openclaw)
#   VM_USER - SSH username (required; for example your VM account or `lume`)
#   VM_IP   - optional; if set, skip resolving IP via lume get
#   POSTGRES_PASSWORD - optional password for the `postgres` role; if unset, a password is generated once and reused
#   PRINT_POSTGRES_PASSWORD - set to 1 to print the password to stdout after install
#
# Usage:
#   VM_USER=youruser ./scripts/vm/install-postgres-vm.sh
#
set -euo pipefail

VM_NAME="${VM_NAME:-openclaw}"

if [[ -z "${VM_USER:-}" ]]; then
  echo "VM_USER is required (SSH username in the VM). Example: VM_USER=youruser $0"
  exit 1
fi

if ! command -v lume &>/dev/null; then
  echo "Lume is not installed. Run ./scripts/vm/install-lume.sh first."
  exit 1
fi

IP="${VM_IP:-}"
if [[ -z "$IP" ]]; then
  for _ in {1..30}; do
    IP=$(lume get "$VM_NAME" 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1 || true)
    [[ -n "$IP" ]] && break
    sleep 2
  done
fi

if [[ -z "$IP" ]]; then
  echo "Could not get VM IP. Is the VM running? Run: lume get $VM_NAME"
  exit 1
fi

POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
PRINT_POSTGRES_PASSWORD="${PRINT_POSTGRES_PASSWORD:-0}"
POSTGRES_PASSWORD_B64=""
if [[ -n "$POSTGRES_PASSWORD" ]]; then
  POSTGRES_PASSWORD_B64="$(printf '%s' "$POSTGRES_PASSWORD" | base64 | tr -d '\n')"
fi

echo "Installing PostgreSQL on $VM_USER@$IP (VM: $VM_NAME)..."

# Remote script: install PostgreSQL (Homebrew or Postgres.app) and set postgres role password.
REMOTE_SCRIPT='
set -euo pipefail
export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/homebrew/opt/postgresql@16/bin:/usr/local/opt/postgresql@16/bin:$PATH"

PASSWORD_DIR="$HOME/.config/lume-openclaw"
PASSWORD_FILE="$PASSWORD_DIR/postgres-password"

if [[ -n "${POSTGRES_PASSWORD_B64:-}" ]]; then
  POSTGRES_PASSWORD="$(printf "%s" "$POSTGRES_PASSWORD_B64" | base64 -d)"
  mkdir -p "$PASSWORD_DIR"
  chmod 700 "$PASSWORD_DIR"
  printf "%s" "$POSTGRES_PASSWORD" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
elif [[ -f "$PASSWORD_FILE" ]]; then
  POSTGRES_PASSWORD="$(cat "$PASSWORD_FILE")"
else
  mkdir -p "$PASSWORD_DIR"
  chmod 700 "$PASSWORD_DIR"
  POSTGRES_PASSWORD="$(LC_ALL=C tr -dc "A-Za-z0-9" </dev/urandom | head -c 24)"
  printf "%s" "$POSTGRES_PASSWORD" > "$PASSWORD_FILE"
  chmod 600 "$PASSWORD_FILE"
fi

install_via_homebrew() {
  echo "Installing PostgreSQL via Homebrew..."
  brew install postgresql@16
  brew services start postgresql@16
  echo "Waiting for PostgreSQL to start..."
  sleep 5
}

install_via_postgresapp() {
  echo "Installing Postgres.app (no sudo required)..."
  POSTGRES_APP="$HOME/Applications/Postgres.app"
  PGDATA="$HOME/pgdata"
  mkdir -p "$HOME/Applications"
  if [[ ! -d "$POSTGRES_APP" ]]; then
    DMG="/tmp/postgres-app.dmg"
    curl -sL -o "$DMG" "https://github.com/PostgresApp/PostgresApp/releases/download/v2.9.2/Postgres-2.9.2-18.dmg"
    hdiutil attach -nobrowse -quiet "$DMG"
    VOL=$(ls /Volumes | grep -i postgres | head -1)
    cp -R "/Volumes/$VOL/Postgres.app" "$HOME/Applications/"
    hdiutil detach "/Volumes/$VOL" -quiet 2>/dev/null || true
    rm -f "$DMG"
  fi
  BIN="$POSTGRES_APP/Contents/Versions/latest/bin"
  [[ -d "$BIN" ]] || BIN="$POSTGRES_APP/Contents/Versions/18/bin"
  export PATH="$BIN:$PATH"
  if [[ ! -d "$PGDATA" ]]; then
    "$BIN/initdb" -D "$PGDATA" -U "$USER"
    echo "host all all 127.0.0.1/32 scram-sha-256" >> "$PGDATA/pg_hba.conf"
    echo "host all all ::1/128 scram-sha-256" >> "$PGDATA/pg_hba.conf"
  fi
  "$BIN/pg_ctl" -D "$PGDATA" -l "$PGDATA/logfile" start
  sleep 3
  export PATH="$BIN:$PATH"
}

if command -v psql &>/dev/null; then
  echo "PostgreSQL already available."
elif command -v brew &>/dev/null; then
  install_via_homebrew
else
  install_via_postgresapp
fi

export PATH="/opt/homebrew/bin:/usr/local/bin:/opt/homebrew/opt/postgresql@16/bin:/usr/local/opt/postgresql@16/bin:$HOME/Applications/Postgres.app/Contents/Versions/latest/bin:$HOME/Applications/Postgres.app/Contents/Versions/18/bin:$PATH"
createuser -s postgres 2>/dev/null || true
psql -v pw="$POSTGRES_PASSWORD" -d postgres -c "ALTER USER postgres WITH PASSWORD :'pw';"
echo "PostgreSQL is ready. User: postgres"
if [[ "${PRINT_POSTGRES_PASSWORD:-0}" == "1" ]]; then
  echo "Password: $POSTGRES_PASSWORD"
else
  echo "Password stored at: $PASSWORD_FILE"
  echo "Reveal it inside the VM only when needed: cat \"$PASSWORD_FILE\""
fi
echo "Password file: $PASSWORD_FILE"
'

ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 "$VM_USER@$IP" \
  "POSTGRES_PASSWORD_B64='$POSTGRES_PASSWORD_B64' PRINT_POSTGRES_PASSWORD='$PRINT_POSTGRES_PASSWORD' bash -s" <<< "$REMOTE_SCRIPT"

echo "Done."
