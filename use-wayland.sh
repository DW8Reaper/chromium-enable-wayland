#!/bin/bash
# Script to add wayland arguments to chromium and electron apps like VSCODE. The script needs to be run anytime you update these
# apps since the update will replace the .desktop file until such time as the application in question supports wayland by default.
#
# To test if it is working use xeyes and see if the eyes move when the mouse if over the app as suggested by:
#    https://medium.com/@bugaevc/how-to-easily-determine-if-an-app-runs-on-xwayland-or-on-wayland-natively-8191b506ab9a

# This config variable (the provided values are examples) is a variant of a CSV file, each line contains the path the to .desktop
# file to update as the path and the name of the executable file inside the .desktop file. The executable name is used as
# a pattern match to know where to insert the arguments
config="
#####################################################################################################################################
Desktop File Path                                                                                 , Executable Name
#####################################################################################################################################
/usr/share/applications/code.desktop                                                                              , /usr/share/code/code
$HOME/.local/share/flatpak/exports/share/applications/com.brave.Browser.desktop                                   , com.brave.Browser
$HOME/.local/share/flatpak/exports/share/applications/com.slack.Slack.desktop                                     , com.slack.Slack
$HOME/.local/share/flatpak/exports/share/applications/com.mattermost.Desktop.desktop                              , com.mattermost.Desktop
$HOME/.local/share/flatpak/exports/share/applications/io.github.ungoogled_software.ungoogled_chromium.desktop     , io.github.ungoogled_software.ungoogled_chromium
$HOME/.local/share/flatpak/exports/share/applications/com.logseq.Logseq.desktop                                   , com.logseq.Logseq
"

# For each line in the config string process the .desktop file
while IFS=',' read -r path executable is_electron; do
  # Skip empty lines or lines starting with #
  if [[ -z "$path" || "$path" =~ ^# ]]; then
    continue
  fi
  # Skip header line
  ((line_num++))
  if [[ $line_num -eq 1 ]]; then
    continue
  fi

  # Remove whitespace
  path=$(echo "$path" | xargs)
  executable=$(echo "$executable" | xargs)

  # process each file and add wayland args to it
  echo
  echo -e "Processing \033[0;34m$path\033[0m"

  if [ -e "$path" ]; then
    # Check if the file was already updated
    already_updated_pattern="^Exec.*--ozone-platform=wayland"
    if grep -q -E "$already_updated_pattern" "$path"; then
      echo -e "    \033[0;33mSKIPPED\033[0m already up to date nothing"
    else
      # Add args to use wayland, may need to use sudo if the file is not editable by the current user
      if [ -w "$path" ]; then
        sed -i "/^Exec=/s|\($executable\)|${executable} --enable-features=UseOzonePlatform --ozone-platform=wayland |" "$path"
      else
        sudo sed -i "/^Exec=/s|\($executable\)|${executable} --enable-features=UseOzonePlatform --ozone-platform=wayland |" "$path"
      fi

      if [ $? != 0 ]; then
        echo -e "    \033[0;31mFAILED\033[0m could not update"
      else
        echo -e "    \033[0;32mSUCCESS\033[0m added args for wayland, updated the following lines:"
        grep -n -E "$already_updated_pattern" "$path" | sed -r 's/\w*([[:digit:]]+:)(.*)/      \1  \2/'
      fi
    fi
  else
    echo -e "    \033[0;31mFAILED\033[0m file not found"
  fi

done <<<"$config"
