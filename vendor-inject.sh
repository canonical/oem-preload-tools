#!/bin/bash
# vim: ts=4 sw=4 noet
# This script is used to inject vendor specific files into the Ubuntu OEM image
# Usage: 
#  Call setup.sh first to setup the required environment for the vendor tools
#  ./setup.sh <vendor>
#
#  Run the script with the archive file and the target iso file
#  ./<vendor>-inject.sh ARCHIVE_FILE ISO_FILE
#
#  Or run the script with the archive file and the target USB partition
#  ./<vendor>-inject.sh ARCHIVE_FILE ISO_FILE /media/ubuntu/USB_PARTITION
#
# Maintainer:
#  Bin Li <bin dot li at canonical dot com>

# get the vendor name from $0
VENDOR=$(basename "$0" | sed 's/-.*//')
ARCHIVE=$1
ISO_FILE=$2
USB_PARTITION=$3

if [ "$VENDOR" = "vendor" ]; then
	echo "Please run setup.sh first then use <vendor>-inject.sh"
	exit 1
fi

if [ -z "$ARCHIVE" ] || [ -z "$ISO_FILE" ]; then
    echo "Usage: $0 ARCHIVE_FILE ISO_FILE"
    echo "       $0 ARCHIVE_FILE ISO_FILE USB_PARTITION"
    exit 1
fi

# check ARCHIVE is a full path name or not
if [ "${ARCHIVE:0:1}" != "/" ] && [ "${ARCHIVE:0:1}" != "~" ]; then
	ARCHIVE_FILENAME=${ARCHIVE}
	ARCHIVE=$PWD/$ARCHIVE
else
	ARCHIVE_FILENAME=$(basename "$ARCHIVE")
fi

if [ ! -f "$ARCHIVE" ]; then
    echo "Please download archive.tar.gz from https://oem-share.canonical.com/"
    exit 1
fi
# Generate the OEM facotry image with the archive file
if [ -z "$USB_PARTITION" ]; then
	NEW_ISO_FILE="${ISO_FILE%.iso}-factory.iso"
    sudo PYTHONPATH=./livefs-editor python3 -m livefs_edit \
	    "${ISO_FILE}" \
	    "${NEW_ISO_FILE}" \
	    --cp "${ARCHIVE}" "new/iso/${VENDOR}-oem/${ARCHIVE_FILENAME}"
	if [ -e "${NEW_ISO_FILE}" ]; then
		sudo chown "$USER":"$USER" "${NEW_ISO_FILE}"
	fi
    exit 0
fi

# Make sure the USB partition is not root or home
if [ "$USB_PARTITION" == "/" ] || [ "$USB_PARTITION" == "/home" ]; then
	echo "Please specify a correct USB partition"
	exit 1
fi
# Check permission of USB partition, if not writable, exit
if [ ! -w "$USB_PARTITION" ]; then
    echo "Please mount the USB drive with write permission"
    exit 1
fi
# Check if the USB partition is enough for the iso file
iso_size=$(du -s -B 1M "$ISO_FILE" | awk '{print $1}')
# Get usb_size and used_usb_size in MB in one line
usb_df=$(df -B 1M "$USB_PARTITION")
usb_size=$(echo "$usb_df" | awk 'NR==2{print $2}')
used_usb_size=$(echo "$usb_df" | awk 'NR==2{print $3}')
left_usb_size=$(echo "$usb_df" | awk 'NR==2{print $4}')

if [ "$usb_size" -lt "$iso_size" ] ; then
	echo "The USB partition is not enough for the iso file"
	exit 1
fi
if [ "$left_usb_size" -lt "$iso_size" ] ; then
	echo "NOT enough space, $used_usb_size MB is used in partition $USB_PARTITION, want clean (y/n)?"
	read -r answer
	if [ "$answer" == "y" ] ; then
		sudo rm -rf "$USB_PARTITION"/*
		sudo rm -rf "$USB_PARTITION"/.*
	else
		exit 1
	fi
fi

echo "Mounting the ISO image..."
sudo mkdir -p /tmp/iso
sudo mount -o loop,ro "$ISO_FILE" /tmp/iso
echo "Copying the ISO image to the USB partition..."
rsync -alvq /tmp/iso/ "$USB_PARTITION"/
sudo umount /tmp/iso
mkdir -p "$USB_PARTITION"/"$VENDOR"-oem
rsync -qlvq "$ARCHIVE" "$USB_PARTITION"/"$VENDOR"-oem/
sudo sync
sudo umount "$USB_PARTITION"
echo "Please remove the USB drive and boot from it"
