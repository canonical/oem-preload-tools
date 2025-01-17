# Ubuntu OEM Preload Tools

## What is this?

A set of tools to help with handling Ubuntu OEM preload images.

## What does it do?

* Inject vendor specific files into the Ubuntu OEM image, such as:
  * User Guide packages
  * Wallpaper packages
  * Vendor specific packages
  * Sideload packages (Supported from 24.04 only)

## Contents

* `setup.sh` - initialize the required environment for the tools
* `vendor-inject.sh` - inject vendor specific files into the Ubuntu OEM image
                       or into USB stick
