#!/usr/bin/env bash
# Bootstrap: bash -c "$(curl -fsSL https://raw.githubusercontent.com/Lampam-mine/Serpantinum_Atrixx_Edition/main/install.sh)"
set -euo pipefail
[[ $EUID -ne 0 ]] || { echo "Не запускайте от root." >&2; exit 1; }

REPO_URL="${ATRIXX_REPO_URL:-https://github.com/Lampam-mine/Serpantinum_Atrixx_Edition.git}"
DEST="${ATRIXX_ROOT_DIR:-$HOME/.local/share/atrixx/repo}"

for c in git curl; do command -v "$c" >/dev/null || { echo "Нужен $c" >&2; exit 1; }; done

if [[ -d $DEST/.git ]]; then
  git -C "$DEST" pull --ff-only
else
  mkdir -p "$(dirname "$DEST")"
  git clone --depth 1 "$REPO_URL" "$DEST"
fi
exec "$DEST/bin/atrixx" install "$@"
