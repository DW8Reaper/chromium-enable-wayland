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
