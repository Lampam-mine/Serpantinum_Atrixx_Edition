#!/usr/bin/env bash
# perf-lite: облегчённые эффекты Hyprland для слабого железа (opt-in: atrixx enable perf-lite).
# Пишет только в наш каталог; пользовательский конфиг уже подключён модулем core.

mod_desc() { echo "Hyprland: без анимаций и размытия (для слабого железа)"; }

mod_apply() {
  mkdir -p "$ATRIXX_CONF/hypr.d"
  cat >"$ATRIXX_CONF/hypr.d/50-perf-lite.conf" <<'CONF'
# managed by Atrixx Edition (perf-lite)
animations {
    enabled = false
}
decoration {
    blur {
        enabled = false
    }
}
CONF
}

mod_revert() { rm -f "$ATRIXX_CONF/hypr.d/50-perf-lite.conf"; }
