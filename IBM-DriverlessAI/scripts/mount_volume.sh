#!/bin/bash -xe
# This script mounts a block storage volume by first formatting the storage device
# then mounting it
mkfs.ext4 /dev/vdd
mkdir -p /mnt/dai-tmp
mount /dev/vdd /mnt/dai-tmp
echo "data_directory = \"/mnt/dai-tmp\"" >> /etc/dai/config.toml