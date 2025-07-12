# chromium-enable-wayland

Script to enable Wayland for Chromium and Electron apps by updating their .desktop file. I could not find a reliable
.config/some-config-file mechanism that always worked so I resorted this script to easy update the .desktop files
anytime I had a new app or installed updates which replace the .desktop.

To use the script:

- FIRST edit `use-wayland.sh` and update the `config` variable to list the .desktop files and the executable names to update. The default content contains examples of some .desktop files I regularly update
- run `use-wayland.sh` anytime you have updated an app to re-update all as needed
