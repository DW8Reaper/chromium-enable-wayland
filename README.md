# chromium-enable-wayland

Script to enable Wayland for Chromium and Electron apps by updating their .desktop file or disabling the X11 socket
in the Flatpak permissions. I could not find a reliable .config/some-config-file mechanism that always worked so I resorted this script to easy update the .desktop files anytime I had a new app or installed updates which replace the .desktop.

When updating a .desktop file the script will first copy the original file to the same location with a .desktop.bak extension. In the case for flatpak permissions there is already the ability to reset to original provided by flatpak so
there is no attempt to perform any kind of backup of the original settings. It is helpful to use an application like
Flatseal to view/update/reset these settins.

To use the script:

- Update the apps.conf file to list all the applications and .desktop files you want to update. The default list contains som example apps and you must update it suite your needs
- run `use-wayland.sh` anytime you have updated an app to re-update all as needed

## Testing

To test if it is working use xeyes and see if the eyes move when the mouse if over the app as suggested
by: <https://medium.com/@bugaevc/how-to-easily-determine-if-an-app-runs-on-xwayland-or-on-wayland-natively-8191b506ab9a>

## Suggested Configs

The following section provides suggestions for where to configure applications, these options were typically tested to work on PopOS 24.04 but any updates to an application may change how it works so you maybe need to still do some trial and errorh

This is not an exhausted list just specific apps that have been tested

### Flatpak socket override

The following apps work when added to `FLATPAKS` in `app.conf` and overriding their flatpak sockets:

- Joplin: `net.cozic.joplin_desktop`
- Portal for Teams: `com.github.IsmaelMartinez.teams_for_linux`
- Slack: `com.slack.Slack`

### Flatpak .desktop override

The following have their .desktop file updated and work when added to `DESKTOP_FLATPAKS` in `app.conf`:

- Brave Browser: `com.brave.Browser.desktop`
- Discord: `com.discordapp.Discord`
- Google Chrome: `com.google.Chrome`
- LogSeq: `com.logseq.Logseq`
- Mattermost: `com.mattermost.Desktop`
- Signal: `org.signal.Signal`
- Ungoogled Chrome: `io.github.ungoogled_software.ungoogled_chromium`
- Visual Studio Code: `com.visualstudio.code`

### Custom .desktop override

Generally customer .desktop files and applications stored from your system repository are best suited to the `DESKTOP_FILES`
list in `app.conf`.
