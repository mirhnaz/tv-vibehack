#!/usr/bin/env bash
# Linux variant of build-and-install.sh: builds with the SDK in ~/Android/Sdk and installs with the
# native adb binary instead of the Python client.
#
# Usage: TV_HOST=192.168.29.61 launcher/build-and-install-linux.sh
set -euo pipefail
cd "$(dirname "$0")"
: "${TV_HOST:?set TV_HOST to the TV IP address, e.g. TV_HOST=192.168.1.50 $0}"
STOCK_LAUNCHER="${STOCK_LAUNCHER:-com.google.android.tvlauncher}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SERIAL="$TV_HOST:${TV_PORT:-5555}"
[ -f local.properties ] || echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew assembleDebug -q --console=plain
adb connect "$ANDROID_SERIAL" >/dev/null
adb install -r app/build/outputs/apk/debug/app-debug.apk
adb shell pm grant com.gathin.tvhome android.permission.ACCESS_FINE_LOCATION || true
adb shell cmd package set-home-activity --user 0 com.gathin.tvhome/.MainActivity
adb shell pm disable-user --user 0 "$STOCK_LAUNCHER"
# precompile so the launcher opens instantly
adb shell cmd package compile -m speed -f com.gathin.tvhome
adb shell input keyevent KEYCODE_HOME
echo "Installed."
