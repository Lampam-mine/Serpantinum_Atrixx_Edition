#!/usr/bin/env bash
# Работа с оригинальным Serpantinum. Его файлы мы НЕ трогаем и НЕ копируем:
# ставится и обновляется он только собственным установщиком автора.

upstream_present() { have serpantinumd || [[ -x $HOME/.local/bin/serpantinumd ]]; }

# Последний релиз апстрима (без jq). Печатает "unknown" при ошибке сети.
upstream_latest() {
  local v
  v=$(curl -fsSL --max-time 10 "https://api.github.com/repos/$UPSTREAM_REPO/releases/latest" 2>/dev/null \
      | grep -m1 '"tag_name"' | sed -E 's/.*"tag_name": *"v?([^"]+)".*/\1/') || true
  echo "${v:-unknown}"
}

# Скачивает оригинальный установщик в файл, показывает хэш, запускает после согласия.
# Установщик интерактивный: для обновления выберите в нём "update".
upstream_run() {
  local tmp; tmp=$(mktemp)
  curl -fsSL "$UPSTREAM_INSTALL_URL" -o "$tmp" || { rm -f "$tmp"; die "Не удалось скачать установщик апстрима."; }
  log "Установщик апстрима: sha256=$(sha "$tmp")"
  warn "Оригинальный установщик отправляет анонимную телеметрию (см. README апстрима)."
  if ask "Запустить оригинальный установщик Serpantinum?"; then
    bash "$tmp" </dev/tty || warn "Установщик апстрима завершился с ошибкой."
    mkdir -p "$ATRIXX_STATE"; sha "$tmp" >"$ATRIXX_STATE/upstream.installer.sha"
  else
    warn "Пропущено."
  fi
  rm -f "$tmp"
}

# Сверка с протестированной веткой апстрима.
check_compat() {
  local v; v=$(upstream_latest)
  if [[ $v == unknown ]]; then
    warn "Не удалось узнать версию апстрима (нет сети?). Проверка пропущена."; return 0
  fi
  if [[ $v == "$TESTED_UPSTREAM" || $v == "$TESTED_UPSTREAM".* ]]; then
    log "Апстрим $v совместим (проверено: $TESTED_UPSTREAM.x)."
  else
    warn "Апстрим $v новее проверенной ветки $TESTED_UPSTREAM.x — оверлей для неё не тестировался."
    ask "Применить оверлей всё равно?" || return 1
  fi
}
