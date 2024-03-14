#!/bin/bash
# vim: ts=4 sw=4 noet
# This script is used to setup the required environment for the vendor tools
#
# Usage: 
#  ./setup.sh <vendor>

VENDOR=$1
if [ -z "$VENDOR" ]; then
    echo "Usage: $0 <vendor>"
    echo "       e.g. $0 lenovo"
    echo "       e.g. $0 hp"
    exit 1
fi
# Check the link if exists
if [ ! -L "$VENDOR-inject.sh" ]; then
	ln -s vendor-inject.sh "$VENDOR-inject.sh"
fi

if [ ! -f "livefs-editor/livefs_edit/__main__.py" ]; then
	git submodule update --init
fi

# Check if the xorriso and squashfs-tools are installed
if ! command -v xorriso > /dev/null; then
	echo "Installing xorriso"
	sudo apt install -y xorriso squashfs-tools liblz4-tool
fi

# Check if the 'OEM custom' is in the livefs-editor, if not, apply patch for it
if ! grep -q "OEM custom" livefs-editor/livefs_edit/context.py; then
	patch -d livefs-editor/ -p1 < livefs-editor.patch
fi
