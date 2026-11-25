#!/usr/bin/env bash
# Общие функции Serpantinum Atrixx Edition.

ATRIXX_STATE="${ATRIXX_STATE:-$HOME/.local/state/atrixx}"
ATRIXX_CONF="${ATRIXX_CONF:-$HOME/.config/atrixx}"
ATRIXX_REPO_URL="${ATRIXX_REPO_URL:-https://github.com/Lampam-mine/Serpantinum_Atrixx_Edition.git}"
UPSTREAM_REPO="ilyamiro/serpantinum"
UPSTREAM_INSTALL_URL="${UPSTREAM_INSTALL_URL:-https://raw.githubusercontent.com/$UPSTREAM_REPO/master/install/install.sh}"

if [[ -t 1 ]]; then C_G=$'\e[32m'; C_Y=$'\e[33m'; C_R=$'\e[31m'; C_0=$'\e[0m'; else C_G=; C_Y=; C_R=; C_0=; fi
log()  { printf '%s[atrixx]%s %s\n' "$C_G" "$C_0" "$*"; }
warn() { printf '%s[atrixx]%s %s\n' "$C_Y" "$C_0" "$*" >&2; }
die()  { printf '%s[atrixx]%s %s\n' "$C_R" "$C_0" "$*" >&2; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

not_root() { [[ $EUID -ne 0 ]] || die "Не запускайте от root (как и оригинальный Serpantinum)."; }

# ask "вопрос" -> 0 если да. ATRIXX_YES=1 отвечает «да» автоматически.
ask() {
  [[ ${ATRIXX_YES:-0} == 1 ]] && return 0
  local a
  read -r -p "$1 [y/N] " a </dev/tty 2>/dev/null || return 1
  [[ $a =~ ^[Yy]$ ]]
}

take_lock() {
  mkdir -p "$ATRIXX_STATE"
  exec 9>"$ATRIXX_STATE/lock"
  flock -n 9 || die "Уже запущен другой процесс atrixx."
}
release_lock() { exec 9>&-; }

sha() { sha256sum "$1" | cut -d' ' -f1; }

# Резервная копия оригинала — один раз, до первого нашего изменения.
backup_file() {
  local f=$1 d="$ATRIXX_STATE/backups" key
  [[ -f $f ]] || return 0
  mkdir -p "$d"
  key=$(printf '%s' "$f" | sha256sum | cut -c1-12)
  if [[ ! -e $d/$key.orig ]]; then
    cp -p "$f" "$d/$key.orig"
    printf '%s\n' "$f" >"$d/$key.path"
  fi
}

# Управляемые блоки: наш код в пользовательском файле между маркерами.
#   block_put <file> <id> <comment-prefix> <body>
block_del() {
  local f=$1 id=$2 cm=$3 tmp
  [[ -f $f ]] || return 0
  tmp=$(mktemp)
  awk -v b="$cm >>> atrixx:$id >>>" -v e="$cm <<< atrixx:$id <<<" \
    '$0==b{s=1;h=0;next} $0==e{s=0;next} s{next}
     {if(h){print "";h=0} if($0==""){h=1;next} print}
     END{if(h)print ""}' "$f" >"$tmp"
  cat "$tmp" >"$f"
  rm -f "$tmp"
}
block_put() {
  local f=$1 id=$2 cm=$3 body=$4
  [[ -f $f ]] || return 1
  backup_file "$f"
  block_del "$f" "$id" "$cm"
  printf '\n%s >>> atrixx:%s >>>\n%s\n%s <<< atrixx:%s <<<\n' "$cm" "$id" "$body" "$cm" "$id" >>"$f"
}
block_has() { [[ -f $1 ]] && grep -qF "$2 >>> atrixx:$3 >>>" "$1"; }
