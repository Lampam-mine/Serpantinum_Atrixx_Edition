#!/usr/bin/env bash
# core: подключает папку оверлея к конфигам композитора через include.
# Файлы апстрима не меняются; в пользовательский конфиг добавляется один управляемый блок.

HYPR_CFG="$HOME/.config/hypr/hyprland.conf"
SWAY_CFG="$HOME/.config/sway/config"

mod_desc() { echo "include оверлея в конфиги композитора + команда atrixx"; }

mod_apply() {
  mkdir -p "$ATRIXX_CONF/hypr.d" "$ATRIXX_CONF/sway.d" "$HOME/.local/bin"

  # Наши файлы: пересоздаются при каждом apply. Пользовательские правки кладите в *.d/user-*.conf
  printf '# managed by Atrixx Edition\nsource = %s/hypr.d/*.conf\n' "$ATRIXX_CONF" >"$ATRIXX_CONF/hypr.conf"
  printf '# managed by Atrixx Edition\ninclude %s/sway.d/*.conf\n' "$ATRIXX_CONF" >"$ATRIXX_CONF/sway.conf"
  # Чтобы glob в source/include никогда не оказывался пустым:
  echo "# atrixx placeholder" >"$ATRIXX_CONF/hypr.d/00-atrixx.conf"
  echo "# atrixx placeholder" >"$ATRIXX_CONF/sway.d/00-atrixx.conf"

  local found=0
  if [[ -f $HYPR_CFG ]]; then
    block_put "$HYPR_CFG" core '#' "source = $ATRIXX_CONF/hypr.conf" && found=1
  fi
  if [[ -f $SWAY_CFG ]]; then
    block_put "$SWAY_CFG" core '#' "include $ATRIXX_CONF/sway.conf" && found=1
  fi
  ((found)) || echo "[core] Конфиг Hyprland/Sway не найден. Niri и Mango пока не поддержаны: подключите $ATRIXX_CONF вручную." >&2

  ln -sf "$ATRIXX_ROOT/bin/atrixx" "$HOME/.local/bin/atrixx"
}

mod_revert() {
  block_del "$HYPR_CFG" core '#'
  block_del "$SWAY_CFG" core '#'
  rm -f "$ATRIXX_CONF/hypr.conf" "$ATRIXX_CONF/sway.conf" \
        "$ATRIXX_CONF/hypr.d/00-atrixx.conf" "$ATRIXX_CONF/sway.d/00-atrixx.conf"
  [[ -L $HOME/.local/bin/atrixx ]] && rm -f "$HOME/.local/bin/atrixx"
  return 0
}
