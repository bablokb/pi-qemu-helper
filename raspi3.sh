#!/bin/bash
# --------------------------------------------------------------------------
# Start-script for qem-system-aarch64 configured for raspi3.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-qemu-helper
#
# --------------------------------------------------------------------------

# Just call raspi_.sh with standard arguments. Adapt to your needs.

pgmdir=$(dirname "$0")

"$pgmdir"/raspi_.sh -b raspi3b "$@"
