#!/bin/sh

LOGS=/mnt/onboard/.add/kobocloud
LIB=/mnt/onboard/.add/kobocloud/Library
SD=/mnt/sd/kobocloud
USERCONFIG=/mnt/onboard/.add/kobocloud/kobocloudrc
RCLONECONFIG=/mnt/onboard/.add/kobocloud/rclone.conf
DATE_TIME="date +%Y-%m-%d_%H:%M:%S"
RCLONEDIR="/mnt/onboard/.add/kobocloud/bin/"
RCLONE="${RCLONEDIR}rclone"
PLATFORM=Kobo
