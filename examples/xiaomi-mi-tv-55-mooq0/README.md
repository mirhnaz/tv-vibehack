# Xiaomi Mi TV 55 (MiTV-MOOQ0)

Android TV 10, MediaTek/MStar m7632, India firmware QTG3.200305.006.3270. Set up as a "dumb TV +
YouTube": 58 packages disabled (nothing uninstalled), tv-vibehack launcher as home.

All commands assume `TV_HOST=192.168.29.61` and the native `adb` (android-tools).

## Undo everything
    TV_HOST=192.168.29.61 tools/restore-from-backup.sh backup/20261019-075620

Re-enables every package that wasn't disabled at backup time and makes the Google TV launcher home
again. The backup folder (package lists, getprop, all settings) is git-ignored and stays local.

## Re-enable one app
    adb -s 192.168.29.61:5555 shell pm enable <package>

Package names and what they are: `debloat.txt`. Common ones: Netflix `com.netflix.ninja`,
USB Media Player `com.xiaomi.mitv.mediaexplorer`, firmware updates `com.xiaomi.mitv.updateservice`,
Chromecast `com.google.android.apps.mediashell`, voice `com.google.android.katniss`.

## Change the dock or rebuild the launcher
Edit `launcher/app/src/main/res/values/config.xml` (`dock_apps`, in order), then:

    TV_HOST=192.168.29.61 launcher/build-and-install-linux.sh

Needs JDK 17+ and the Android SDK in `~/Android/Sdk` (platform 34, build-tools 34).

## Notes from this firmware
- Live TV (`com.mediatek.wwtv.tvcenter`) must stay: it is also the window that shows HDMI inputs.
  It's hidden from the grid and the Inputs menu instead.
- `com.mediatek.wwtv.setupwizard` is the whole first-boot setup (region, terms), not just the
  channel scan, so it stays.
- The Live TV window blocks `screencap` (empty file); press Home before taking screenshots.
- After power-on the TV returns to the last source; press Home to get to the launcher.
- Screensaver is set to the launcher's clock (`com.gathin.tvhome/.ClockDream`) because Mi Dream is off.
- Window/transition animations are at 0.5x; launcher and YouTube are AOT-compiled (`compile -m speed`).
