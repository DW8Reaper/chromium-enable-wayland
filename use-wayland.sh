#!/bin/bash
# Script to add wayland arguments to chromium and electron apps like VSCODE. The script needs to be run anytime you update these
# apps since the update will replace the .desktop file until such time as the application in question supports wayland by default.

source apps.conf

# Process a desktop file
#   $1 is the path to the desktop file
#   $2 is the executable name used to know where to insert arguments
function process_desktop_file() {
  path="$1"
  path_backup="$1.bak"
  executable="$2"

  if [ -e "$path" ]; then
    # Check if the file was already updated
    already_updated_pattern="^Exec.*--ozone-platform=wayland"
    if grep -q -E "$already_updated_pattern" "$path"; then
      echo -e "    \033[0;33mSKIPPED\033[0m already up to date"
    else
      # create backup
      echo -e "    creating backup file \033[0;90m$path_backup\033[0m"
      cp "$path" "$path_backup"

      # Add args to use wayland, may need to use sudo if the file is not editable by the current user
      if [ -w "$path" ]; then
        sed -i "/^Exec=/s|$executable|${executable} --enable-features=UseOzonePlatform --ozone-platform=wayland |" "$path"
      else
        sudo sed -i "/^Exec=/s|$executable|${executable} --enable-features=UseOzonePlatform --ozone-platform=wayland |" "$path"
      fi

      if [ $? != 0 ]; then
        echo -e "    \033[0;31mFAILED\033[0m could not update"
      else
        echo -e "    \033[0;32mSUCCESS\033[0m added args for wayland, updated the following lines:"
        grep -E "$already_updated_pattern" "$path" | sed -r 's/(.*)/      \1/'
      fi
    fi
  else
    echo -e "    \033[0;31mFAILED\033[0m file not found"
  fi
}

# Determine the installation type for a flatpak
#  $1 - name of the flatpak
#  returns - --system for global install, --users for users install and empty for not found
function flatpak_install_type() {
  if flatpak info "$name" --user &>/dev/null; then
    echo "--user"
  elif flatpak info "$name" --system &>/dev/null; then
    echo "--system"
  else
    echo -e "    \033[0;31mFAILED\033[0m flatpak not installed"
  fi
}

# Determine if a flatpak needs its sockets overridden
#   $1 - type of installation --system or --user
#   $2 - flatpak name
function flatpak_needs_override() {
  flatpak info "$2" $1 --show-permissions | grep -q -E '^sockets=.*x11'
}

# for testing uncomment the following lines to clear an array and effectively skip that section
# FLATPAKS=()
# DESKTOP_FLATPAKS=()
# DESKTOP_FILES=()

# Process FLATPAKS which contains flatpak apps where we override flatpak settings to only use wayland
printf "\n\n\033[0;34mFlatpak permission overrides\033[0m"
for name in "${FLATPAKS[@]}"; do
  # remove whitespace
  name=$(echo "$name" | xargs)

  type=$(flatpak_install_type "$name")
  echo
  echo -e "  Processing flatpak application \033[0;34m$name\033[0m installed as \033[0;34m$type\033[0m"

  if [ -z "$type" ]; then
    echo -e "    \033[0;31mFAILED\033[0m flatpak not installed"
  elif flatpak_needs_override "$type" "$name"; then
    flatpak override $type --socket=wayland --nosocket=x11 --nosocket=fallback-x11 "$name"
    echo -e "    \033[0;32mSUCCESS\033[0m updated flatpak sockets to wayland"
    updated=$(flatpak info "$name" $type --show-permissions | grep -E '^sockets=')
    echo "      $updated"
  else
    echo -e "    \033[0;33mSKIPPED\033[0m already updated"
  fi

done

# Process DESKTOP_FLATPAKS which contains flatpak apps that must have their .desktop files adjusted
printf "\n\n\033[0;34mFlatpak .desktop files\033[0m"
for name in "${DESKTOP_FLATPAKS[@]}"; do
  # remove whitespace
  name=$(echo "$name" | xargs)

  type=$(flatpak_install_type "$name")
  echo
  echo -e "  Processing .desktop for flatpak \033[0;34m$name\033[0m installed as \033[0;34m$type\033[0m"

  if [ -z "$type" ]; then
    echo -e "    \033[0;31mFAILED\033[0m flatpak not installed"
  elif [[ "$type" == "--system" ]]; then
    process_desktop_file "/var/lib/flatpak/exports/share/applications/$name.desktop" "$name"
  else
    process_desktop_file "$HOME/.local/share/flatpak/exports/share/applications/$name.desktop" "$name"
  fi

done

# For each line in the DESKTOP_FILES array split the command and desktop file location and update it
printf "\n\n\033[0;34mCustom .desktop files\033[0m"
for entry in "${DESKTOP_FILES[@]}"; do
  IFS=':' read -r path executable is_electron <<<"$entry"

  # Remove whitespace
  path=$(echo "$path" | xargs)
  executable=$(echo "$executable" | xargs)

  # process each file and add wayland args to it
  echo
  echo -e "  Processing .desktop file \033[0;34m$path\033[0m"

  process_desktop_file "$path" "$executable"
done
