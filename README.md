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

## Usage
* Download the required files from OEM Partners(https://oem-share.canonical.com/partners/sutton/share/), such as:
  * `userguides/canonical_noble_sutton-hotfix-packages_20250627-527.tar.zst`
  * `releases/noble/oem-24.04d/20260316-67/sutton-noble-oem-24.04d-20260316-67.iso`
```
./setup.sh lenovo
./lenovo-inject.sh canonical_noble_sutton-hotfix-packages_20250627-527.tar.zst sutton-noble-oem-24.04d-20260316-67.iso
```
