#!/bin/sh

#load config
. "$(dirname "$0")"/config.sh

#create work dirs
[ ! -e "$LOGS" ] && mkdir -p "$LOGS" >/dev/null 2>&1
[ ! -e "$LIB" ] && mkdir -p "$LIB" >/dev/null 2>&1
[ ! -e "$SD" ] && mkdir -p "$SD" >/dev/null 2>&1

if [ ! -e "$USERCONFIG" ]; then
  if [ -e "$CONFIGFILE" ]; then
    cp "$CONFIGFILE" "$USERCONFIG"
  else
    echo '# Add your rclone remote:folder/on/remote pairs to this file' > "$USERCONFIG"
    echo '# Remove the # from the following line to uninstall KoboCloud' >> "$USERCONFIG"
    echo '#UNINSTALL' >> "$USERCONFIG"
  fi
fi

#bind mount to subfolder of SD card on reboot
if ! mountpoint -q "$SD"; then
  mount --bind "$LIB" "$SD"
  echo 'sd add /dev/mmcblk1p1' >> /tmp/nickel-hardware-status
fi
