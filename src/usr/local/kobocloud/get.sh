#!/bin/sh
#Kobocloud getter

TEST=$1

#load config
. "$(dirname "$0")"/config.sh

#check if Kobocloud contains the line "UNINSTALL"
if grep -q '^UNINSTALL$' "$USERCONFIG"; then
    echo "Uninstalling KoboCloud!"
    "$KC_HOME"/uninstall.sh
    exit 0
fi

if grep -q "^REMOVE_DELETED$" "$USERCONFIG"; then
   echo "$LIB/filesList.log" > "$LIB/filesList.log"
fi


if [ "$TEST" = "" ]; then
    #check internet connection
    echo "$($DATE_TIME) waiting for internet connection"
    r=1;i=0
    while [ $r != 0 ]; do
        if [ $i -gt 60 ]; then
            ping -c 1 -w 3 aws.amazon.com >/dev/null 2>&1
            echo "$($DATE_TIME) error! no connection detected" 
            exit 1
        fi
        ping -c 1 -w 3 aws.amazon.com >/dev/null 2>&1
        r=$?
        if [ $r != 0 ]; then
            sleep 1
        fi
        i=$((i+1))
    done
fi

# check for qbdb
if [ "$PLATFORM" = "Kobo" ]; then
    if [ -f "/usr/bin/qndb" ]; then
        echo "NickelDBus found"
    else
        echo "NickelDBus not found: installing it!"
        wget "https://github.com/shermp/NickelDBus/releases/download/0.2.0/KoboRoot.tgz" -O - | tar xz -C /
    fi

    if [ -f "$RCLONE" ]; then
        echo "rclone found"
    else
        echo "rclone not found: installing it!"
        mkdir -p "$RCLONEDIR"
        rcloneTemp="$RCLONEDIR/rclone.tmp.zip"
        rm -f "$rcloneTemp"
        wget "https://github.com/rclone/rclone/releases/download/v1.64.0/rclone-v1.64.0-linux-arm-v7.zip" -O "$rcloneTemp"
        unzip -p "$rcloneTemp" rclone-v1.64.0-linux-arm-v7/rclone > "$RCLONE"
        rm -f "$rcloneTemp"
    fi
fi

#list file in lib dir before sync
lib_list_before="$(ls -lnR --full-time "$LIB")"
echo "$lib_list_before"

while read -r url || [ -n "$url" ]; do
    if echo "$url" | grep -q '^#'; then
        continue
    elif echo "$url" | grep -q "^REMOVE_DELETED$"; then
        echo "Will delete files no longer present on remote"
    elif [ -n "$url" ]; then
        echo "Getting $url"    
        command=""
        if grep -q '^REMOVE_DELETED$' "$USERCONFIG"; then    
            # Remove deleted, do a sync.
            command="sync"
        else
            # Don't remove deleted, do a copy.
            command="copy"
        fi

        remote=$(echo "$url" | cut -d: -f1)
        dir="$LIB/$remote/"
        mkdir -p "$dir"
        $RCLONE $command --no-check-certificate -v --config "$RCLONECONFIG" "$url" "$dir"
    fi
done < "$USERCONFIG"

#list file in lib dir after sync
lib_list_after=$(ls -lnR --full-time "$LIB")
echo "$lib_list_after"

#compare filelist before and after
if [ "$lib_list_after" = "$lib_list_before" ]; then
    echo "No Library Change. skipping rescan"
else
    echo "Library has changed, rescan needed"

    if [ "$TEST" = "" ]; then
        # Use NickelDBus for library refresh
        /usr/bin/qndb -t 3000 -s pfmDoneProcessing -m pfmRescanBooksFull
    fi
fi

rm "$LOGS"/index >/dev/null 2>&1
echo "$($DATE_TIME) done"
