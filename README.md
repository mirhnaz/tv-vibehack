# tv-vibehack

**Your TV, minus the ads.**

Strip the bloatware from any Android TV or Google TV over Wi-Fi, and replace the ad-filled home
screen with a clean launcher that looks like an Apple TV. No root, no cable, nothing uninstalled,
and a one-line restore if you change your mind.

![Before: stock Google TV home with a sponsored ad. After: the tv-vibehack launcher](docs/stock-vs-new-side.jpg)

It started as an afternoon fixing my parents' Mi TV, which showed them an advert before they
could reach Netflix. The whole thing was done with Claude Code talking to the real TV, and the
prompt that did it is in this repo so you can do the same with yours.

---

## Table of contents

- [How it works](#how-it-works)
- [Step by step](#step-by-step)
- [What you get](#what-you-get)
- [Supported TVs](#supported-tvs)
- [Doing it by hand](#doing-it-by-hand)
- [The launcher](#the-launcher)
- [Troubleshooting](#troubleshooting)
- [Questions people ask](#questions-people-ask)
- [Contributing](#contributing)
- [Licence](#licence)

---

## How it works

Android TVs have the same debug bridge as Android phones. Once you switch on USB debugging in the
TV's developer options, the TV listens on your Wi-Fi and asks you once to allow your computer.
After that, everything is standard Android tooling:

1. **Back up** the list of installed packages and settings.
2. **Disable** the manufacturer's telemetry, ad services, content rows and preloaded junk with
   `pm disable-user`. Nothing is uninstalled, so a restore script can undo every step.
3. **Install** a small native launcher and make it the default home screen.

The bloat differs by brand, which is why the prompt asks your coding assistant to discover it
on your TV and ask you before touching anything you might use.

## Step by step

About 30–45 minutes, most of it waiting for downloads. You need:

- an Android TV or Google TV (see [Supported TVs](#supported-tvs)),
- a Mac, Windows or Linux computer on the **same Wi-Fi** as the TV,
- [Claude Code](https://claude.com/claude-code) (or another coding assistant that can run
  commands on your computer).

You don't need a cable, root or any Android experience. Nothing gets uninstalled, and every step
can be undone.

### 1. On the TV: switch on debugging

1. Open **Settings → Device Preferences → About**.
2. Scroll down to **Build** and press OK on it **seven times**, until it says you are a developer.
3. Go back one screen. Open **Developer options** (now at the bottom of Device Preferences) and
   switch on **USB debugging**. If you also see **Network debugging** or **ADB over network**,
   switch that on too. Many TVs, Xiaomi included, don't have it; USB debugging alone is enough.
4. Write down two things:
   - the **model**: Settings → Device Preferences → About → Model (for example `MiTV-MOOQ0`),
   - the **IP address**: Settings → Network & Internet → your Wi-Fi network → IP address
     (for example `192.168.1.50`).

Leave the TV on.

### 2. On the computer: install the tools (once)

**Mac.** Open **Terminal** (press ⌘ Space, type *Terminal*, press Return) and paste these lines
one at a time. The first one installs [Homebrew](https://brew.sh); skip it if you have it, and
follow what it prints at the end (it may ask you to run two lines to add `brew` to your PATH).

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install git openjdk@17 android-commandlinetools
yes | sdkmanager --licenses
sdkmanager "platforms;android-34" "build-tools;34.0.0"
curl -fsSL https://claude.ai/install.sh | bash
```

The last line installs Claude Code; the first time you run `claude` it asks you to sign in.

<details>
<summary><strong>Windows or Linux</strong></summary>

- **Windows**: install [Git](https://git-scm.com), [Python 3](https://www.python.org) and
  [Android Studio](https://developer.android.com/studio) (it brings the JDK and SDK), then
  Claude Code. The assistant uses the `.ps1` scripts; see [Windows](#windows) below.
- **Linux**: install `git`, `adb` (package `android-tools`), a JDK 17 or newer, and the Android
  SDK command-line tools in `~/Android/Sdk` with platform 34 and build-tools 34.0.0. The native
  `adb` works on Linux, so the assistant can skip the Python client and build with
  `launcher/build-and-install-linux.sh`.
</details>

### 3. Download this repo and start the assistant

If someone sent you a link to their copy (a fork) of this repo, use that address instead.

```bash
git clone https://github.com/Gathin23/tv-vibehack.git
cd tv-vibehack
claude
```

### 4. Paste this prompt

Replace the two values in angle brackets with what you wrote down in step 1:

```text
Read PROMPT.md in this folder and do everything it describes on my TV, reusing tools/ and
launcher/ from this repo instead of writing new ones. My TV model is <MODEL> and its IP address
is <IP>. If examples/ has a debloat list for my model or a close one, start from it, but still
check every package on my TV before disabling it.
```

Want the TV as bare as possible, like a plain screen for YouTube and the HDMI inputs? Add this
line at the end:

```text
Afterwards make it as minimal and fast as possible without breaking the system: disable
everything not needed for the apps I keep, HDMI inputs, the remote, Wi-Fi and the Play Store.
```

### 5. Follow along

- **Within the first minute**, the TV shows **"Allow USB debugging?"**. Tick *Always allow from
  this computer* and press **OK**. This is the only time you need to be at the TV with the remote;
  after that the assistant presses buttons and takes screenshots over Wi-Fi.
- The assistant **asks before running commands**. Read what it wants to do and approve it.
- It asks **three or four checklist questions**: which streaming apps you use (the rest get
  disabled), which four apps go in the dock and in what order, and whether to keep the voice
  assistant, Chromecast and firmware updates.
- It then backs up, debloats, builds and installs the launcher, and checks each step with
  screenshots from the TV.

### 6. Check it

When the assistant says it's done: press **Home** on the remote, open YouTube, switch to one of
your HDMI inputs, and press Home again to come back. If anything is missing or broken, tell the
assistant what you see; it can re-enable any app in seconds.

**To undo everything**, ask the assistant to "restore my TV", or run the restore script it wrote
(see [Doing it by hand](#doing-it-by-hand)). To bring back a single app without the computer:
TV Settings → Apps → See all apps → show system apps → the app → **Enable**.

**Afterwards** you can switch USB debugging off again; the new home screen keeps working.

## What you get

A home screen that is yours again:

- **Pitch-black background** and a dock of your four favourite apps at the bottom, in a lighter
  rounded band, exactly where Apple TV puts it.
- **A top shelf** showing the focused app's name in large type, with an ambient glow in a colour
  taken from the app's own artwork.
- **The rest of your apps in a grid** that slides up when you press Down.
- **One floating glass highlight** that springs from tile to tile instead of each tile drawing its
  own border. The focused tile lifts slightly and shows its name.
- **Three frosted buttons**: Inputs (a dropdown of HDMI ports, AV and Live TV), Wi-Fi (showing the
  network you're on) and Settings.
- **A greeting, a large thin clock and the date**, set in
  [Outfit](https://fonts.google.com/specimen/Outfit).
- **A matching Clock screensaver**, optional, that drifts around the screen so nothing burns in.

And a TV that stops working against you: no sponsored rows, no "Discover" nags, no analytics
phoning home, no apps you never asked for.

## Supported TVs

Anything running **Android TV** or **Google TV**: Xiaomi and Redmi, TCL, Hisense, Sony, OnePlus,
Realme, Nvidia Shield and most others.

Not supported: Samsung (Tizen), LG (webOS) and Amazon Fire TV. They run different systems or
won't let a third-party launcher take over Home.

Lists that people have tested and contributed live in [`examples/`](examples/):

| TV | OS |
|---|---|
| Xiaomi Mi TV 4A (MiTV-MOOQ1) | Android TV 10 |
| Xiaomi Mi TV 55 (MiTV-MOOQ0) | Android TV 10 |
| Xiaomi MiTV-AXSO0 | Android TV 9 |
| TCL 55" 4K Google TV, 2023 (G10) | Google TV 12 |
| SANYO ATV R2 | Android TV 9 |
| OnePlus TV (D00) | Google TV 14 |

Your TV not here? The prompt works regardless, it discovers the bloat itself. If you add your
list afterwards, the next person with your model skips that step. See
[Contributing](#contributing).

## Doing it by hand

Everything the assistant does, you can run yourself. The tools need Python 3 and nothing else.

```bash
python3 -m venv tools/venv && tools/venv/bin/pip install -r tools/requirements.txt
export TV_HOST=192.168.1.50                                   # your TV's IP address

tools/venv/bin/python -I tools/tv.py --probe                 # model, Android version, firmware
tools/venv/bin/python -I tools/tv.py 'pm list packages'      # run one shell command on the TV
printf 'cmd1\ncmd2\n' | tools/venv/bin/python -I tools/tv.py --batch   # several, one connection

tools/disable.sh examples/xiaomi-mi-tv-4a/debloat.txt        # apply a debloat list
tools/restore.sh examples/xiaomi-mi-tv-4a/debloat.txt        # undo it and restore the stock launcher
tools/restore-from-backup.sh backup/<date>                   # undo everything since a backup (native adb)
```

| Tool | What it does |
|---|---|
| [`tools/tv.py`](tools/tv.py) | A pure-Python ADB client: shell, batch, push, pull. Works where the stock `adb` binary is blocked. |
| [`tools/b64push.py`](tools/b64push.py) | Uploads larger files such as APKs as base64 chunks and verifies the checksum. |
| [`tools/disable.sh`](tools/disable.sh) / [`tools/restore.sh`](tools/restore.sh) | Apply or undo a debloat list. PowerShell versions sit next to them. |

### Windows

The PowerShell scripts work without WSL or Git Bash. With Android Studio installed nothing else
is needed: the install script uses Android Studio's bundled JDK and the default SDK location.

```powershell
python -m venv tools\venv; tools\venv\Scripts\python.exe -m pip install -r tools\requirements.txt
powershell -ExecutionPolicy Bypass -File launcher\build-and-install.ps1 -TvHost 192.168.1.50
powershell -ExecutionPolicy Bypass -File tools\disable.ps1 -TvHost 192.168.1.50 examples\xiaomi-mi-tv-4a\debloat.txt
powershell -ExecutionPolicy Bypass -File tools\restore.ps1 -TvHost 192.168.1.50 examples\xiaomi-mi-tv-4a\debloat.txt
```

The install script stops before touching the stock launcher if the install or the home-screen
switch fails. Git Bash also works; the `.sh` scripts detect a Windows venv and disable MSYS path
rewriting themselves.

## The launcher

A small native Android TV app (`com.gathin.tvhome`, about 1.6 MB), written in plain Java with
AndroidX RecyclerView and nothing heavier. It is built for sets with 1 GB of RAM: no blur, no
video, no network, no background services.

**Configure** it in [`launcher/app/src/main/res/values/config.xml`](launcher/app/src/main/res/values/config.xml):
the dock order, apps to hide, your TV's Live TV package, and the number of columns.

**Build and install** with one command:

```bash
TV_HOST=192.168.1.50 launcher/build-and-install.sh          # macOS
TV_HOST=192.168.1.50 launcher/build-and-install-linux.sh    # Linux, native adb, SDK in ~/Android/Sdk
```

It needs JDK 17 and the Android SDK (platform 34, build-tools 34.0.0). On macOS:

```bash
brew install openjdk@17 android-commandlinetools
sdkmanager "platforms;android-34" "build-tools;34.0.0"
```

Without Homebrew, the script also finds a JDK 17 known to `/usr/libexec/java_home` and an SDK in
`~/Library/Android/sdk`, Android Studio's default. A release build (`./gradlew assembleRelease`)
is smaller and faster on 1 GB sets; sign it yourself before installing.

**Navigation** is deliberate: Up and Down move exactly one row, Up from the dock goes to the top
buttons, the ends of the button row don't fall through to tiles, and the last focused app is
remembered when you come back, even after the app list changes.

<details>
<summary><strong>Optional: the Clock screensaver</strong></summary>

A large thin clock and the date over an ambient glow, in the launcher's style. Every minute the
clock drifts to a new spot and the glow shifts colour. The system runs it only while the TV is
idle. Turn it on over ADB, or pick "Clock" in the TV's screensaver settings:

```bash
tools/venv/bin/python -I tools/tv.py 'settings put secure screensaver_components com.gathin.tvhome/.ClockDream; settings put secure screensaver_enabled 1'
```

It starts after the TV's "screen off" idle time (`settings get system screen_off_timeout`).
</details>

## Troubleshooting

Things that bit us or contributors, so they don't bite you.

**Connecting**

- **macOS: `adb connect` says "No route to host"** although the port is open. Recent macOS treats
  the Google-signed `adb` as its own app under Local Network privacy and silently blocks it.
  `tools/tv.py` avoids the binary entirely.
- **No "wireless debugging" toggle** on some TVs, Xiaomi among them. USB debugging alone opens
  network ADB on port 5555.
- **Windows PowerShell 5.1 adds a byte-order mark** to text piped into a program, which turned the
  first batch command into gibberish. `tv.py` now strips it, and the `.ps1` scripts pipe clean UTF-8.
- **Git Bash rewrites paths** like `/data/local/tmp` into Windows paths. The scripts set
  `MSYS_NO_PATHCONV=1` for you. Set `JAVA_HOME` and `ANDROID_HOME` before building there.

**Working on the TV**

- **Chained `pm` commands** (`pm disable a; pm disable b`) may silently stop after the first. Run
  one per shell call; `--batch` does exactly that.
- **Large pushes hang** through the Python client. Use `tools/b64push.py` for APKs.
- **Screenshots come out empty** while Live TV or an HDMI input is on screen, seen on TCL. Press
  Home before `screencap`.
- **Disable the stock launcher only after the new one is installed**, or the Home button lands on
  a factory test app.
- **No on-screen keyboard** after switching launchers, seen on Xiaomi: the default input method
  pointed at a Baidu keyboard that isn't installed. Fix:
  `tools/tv.py 'ime set com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME'`
- **Third-party launchers** often charge for basics like a custom wallpaper. That's why this repo
  has its own.

## Questions people ask

**Is this safe? Can it brick the TV?**
No. Nothing is flashed, rooted or deleted. Packages are disabled for the user profile, which
lives in the data partition, not in the system image. The firmware is untouched. If something
goes wrong, `tools/restore.sh` puts everything back, and even without the tools you can re-enable
apps from the TV's own settings.

**What about firmware updates?**
Most lists disable the manufacturer's update service, so updates only arrive when you re-enable
it on purpose. If an update does land, the worst case is that a package comes back enabled and
you re-run the script.

**Won't the apps break as their APIs change?**
The streaming apps still update through the Play Store, which is left alone. The launcher
doesn't talk to them; it lists what's installed and launches it, using Android launcher intents
that have been stable for over a decade.

**How did it get access? Isn't that a security hole?**
Through the Android Debug Bridge, with one explicit "allow this computer" tap on the TV, the same
as developing an Android app. The TV only trusts the key you approved. You can switch USB
debugging off again afterwards and the launcher keeps working.

**Can I just download the launcher APK?**
Build it yourself with the one-line script above; it takes about a minute and you control what
goes on your TV. We don't publish prebuilt binaries.

## Contributing

The most useful contribution is your TV's debloat list, so the next person with that model
doesn't have to rediscover it. Launcher improvements and sharper prompt wording are welcome too.
See [CONTRIBUTING.md](CONTRIBUTING.md) for the format and the testing we ask for.

## Licence

MIT, see [`LICENSE`](LICENSE). The Outfit typeface is under the SIL Open Font License, see
`launcher/FONT-LICENSE-OFL.txt`.
