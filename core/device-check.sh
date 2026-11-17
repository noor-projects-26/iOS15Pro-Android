#!/data/data/com.termux/files/usr/bin/bash

echo "================================"
echo "      iOS15Pro-Android"
echo "        DEVICE CHECK"
echo "================================"

get_info() {
    value="$(getprop "$1")"
    [ -n "$value" ] && echo "$value" || echo "Not available"
}

echo "Brand: $(get_info ro.product.brand)"
echo "Model: $(get_info ro.product.model)"
echo "Device: $(get_info ro.product.device)"
echo "Android: $(get_info ro.build.version.release)"
echo "SDK: $(get_info ro.build.version.sdk)"
echo "Architecture: $(uname -m)"

echo
echo "===== DISPLAY INFORMATION ====="

DENSITY="$(getprop ro.sf.lcd_density)"

if [ -n "$DENSITY" ]; then
    echo "System density: $DENSITY"
else
    echo "System density: Not exposed"
fi

echo "Resolution: Not available through current permissions"
echo "Window Manager: Restricted or unavailable"

echo
echo "===== ROOT CHECK ====="

if [ "$(id -u)" = "0" ]; then
    echo "Root: Available"
else
    echo "Root: Not available"
fi

echo
echo "===== ENVIRONMENT ====="
echo "Termux: $PREFIX"
echo "User ID: $(id -u)"

echo "================================"
echo "Device check completed safely."
