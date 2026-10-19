#!/usr/bin/env bash
# Re-enable every package that is disabled now but was enabled in a backup folder, then make the
# backed-up HOME activity the default again. Uses the native adb binary.
#
# Usage: TV_HOST=192.168.29.61 tools/restore-from-backup.sh backup/20261019-075620
set -euo pipefail
cd "$(dirname "$0")/.."
B="${1:?usage: restore-from-backup.sh <backup folder>}"
export ANDROID_SERIAL="${TV_HOST:?set TV_HOST}:${TV_PORT:-5555}"
adb connect "$ANDROID_SERIAL" >/dev/null

was_disabled=$(sed 's/^package://' "$B/packages-disabled.txt" | tr -d '\r' | sort)
now_disabled=$(adb shell pm list packages -d | sed 's/^package://' | tr -d '\r' | sort)
for p in $(comm -13 <(echo "$was_disabled") <(echo "$now_disabled")); do
  echo "enable $p"
  adb shell pm enable "$p"   # one pm call per adb shell, chained calls can stop silently
done

home=$(tail -n 1 "$B/home-activity.txt" | tr -d '\r')
echo "home -> $home"
adb shell cmd package set-home-activity --user 0 "$home"
adb shell settings put global window_animation_scale 1.0
adb shell settings put global transition_animation_scale 1.0
adb shell settings put global animator_duration_scale 1.0
adb shell input keyevent KEYCODE_HOME
echo "disabled now:"; adb shell pm list packages -d
