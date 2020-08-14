# Debite
Debite: A full text-based Ninite clone for (latest) Debian

Welcome! This is Debite, a Ninte clone for setting up Debian systems unattended.
Runs via a dialog-based text user interface, or directly via the commandline!

## Installation

None! Just download the script and run it. Anything that it needs will be grabbed automatically.

## Usage

```bash
# Start with the TUI:
sudo ./debite.sh 
# Help:
sudo ./debite.sh -help
# One-lined installations:
sudo ./debite.sh 1 2 3 4  etc etc etc
```
Running with -help will allow you to easily get a list of software. 
By using this, pick associated number in the list and add it to your commnd line to start installing in a one-liner!

## Software/utils list:
```
* 1 Add all extra repositories (Will add non-free and contrib via seperated list files.)
* 2 Console-related tools (Most-used utils that are all pure command line.)
* 3 "LXDE Setup
* 4 LXQt Setup
* 5 GUI-driven software
* 6 nVidia Driver (latest stable)
* 7 Visual Studio Code
* 8 Telegram Desktop
* 9 Wine32+Wine64
* 10 Discord
* 11 Subsonic Music Server
* 12 KVM+Manager
* 13 DeaDBeeF Music Player
* 14 Lutris
* 15 Minecraft Launcher (Official)
* 16 LAMP Stack
* 17 Tor Browser
* 18 Skype For Linux
* 19 Microsoft Teams
* 20 TeamViewer
* 21 Steam
* 22 Google Chrome
* 23 XRDP + Sound support (Might, might not work with your DE)
* 24 "MakeMKV (NOT UNATTENDED DUE TO EULA)
```

### Notes:

Modify as much as you want to your needs, do feel free!
If any issues occour or you spot something else that's wrong or could be imposed, do tell!

