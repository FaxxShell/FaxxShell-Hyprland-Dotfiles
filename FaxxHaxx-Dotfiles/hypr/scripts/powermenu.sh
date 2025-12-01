#!/bin/bash
# Gorgeous Wofi Power Menu – Uses YOUR existing wofi theme

# 1. Blurred screenshot
grim - | convert - -blur 0x9 /tmp/wofi-bg.png

# 2. Detect your current wofi config & style
WOFI_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/wofi/config"
WOFI_STYLE="${XDG_CONFIG_HOME:-$HOME/.config}/wofi/style.css"

# Use defaults if missing
[[ ! -f "$WOFI_CONFIG" ]] && WOFI_CONFIG=""
[[ ! -f "$WOFI_STYLE" ]] && WOFI_STYLE=""

# 3. Build wofi command with your theme
WOFI_CMD="wofi --show dmenu \
    --cache-file /dev/null \
    --allow-images --allow-markup \
    --width 420 --height 500 \
    --prompt '' \
    --define background_image=/tmp/wofi-bg.png"

# Add your config & style if they exist
[[ -f "$WOFI_CONFIG" ]] && WOFI_CMD="$WOFI_CMD --conf $WOFI_CONFIG"
[[ -f "$WOFI_STYLE" ]] && WOFI_CMD="$WOFI_CMD --style $WOFI_STYLE"

# 4. Menu entries (Noto Color Emoji + bold labels)
entries=$(
cat <<'ENT'
<span font='18'></span>  <b>Power Off</b>
<span font='18'></span>  <b>Reboot</b>
<span font='18'></span>  <b>Suspend</b>
<span font='18'></span>  <b>Hibernate</b>
<span font='18'>󰍃</span>  <b>Logout</b>
<span font='18'></span>  <b>Lock Screen</b>
ENT
)

# 5. Show menu
chosen=$(echo "$entries" | eval "$WOFI_CMD" --dmenu)

# 6. Execute
case "$chosen" in
    *"Power Off"*)   rc-service poweroff fast ;;
    *"Reboot"*)      rc-service reboot fast ;;
    *"Suspend"*)     rc-service suspend fast || systemctl suspend ;;  # fallback
    *"Hibernate"*)   rc-service hibernate fast || systemctl hibernate ;;
    *"Logout"*)      hyprctl dispatch exit ;;
    *"Lock Screen"*) hyprlock -q --immediate || swaylock -f -c 000000 ;;
esac
