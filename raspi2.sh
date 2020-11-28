#!/bin/bash
# --------------------------------------------------------------------------
# Start-script for qem-system-arm configured for raspi2.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-qemu-helper
#
# --------------------------------------------------------------------------

EXTRA_ARGS="bcm2708_fb.fbwidth=1280 bcm2708_fb.fbheight=1024 dwc_otg.fiq_fsm_enable=0"

osimg="$1"
if [ -z "$osimg" ]; then
  echo -e "usage: $0 image" >&2
  exit 3
fi
workdir="$(dirname $osimg)"
osimg="$(basename $osimg)"
shift 1

# Aufruf: 1. Block: Hardware
#         2. Block: Kernel, Kommandozeile, dtb
#         3. Block: allgemeine QEmu-Optionen

qemu-system-arm \
  -machine raspi2 \
  -device usb-mouse \
  -device usb-kbd \
  -drive file="$workdir/$osimg",if=sd \
  -netdev user,id=net0,hostfwd=tcp::8022-:22 \
  -device usb-net,netdev=net0 \
\
  -kernel "$workdir/kernel7.img" \
  -append "$(cat $workdir/cmdline.txt) $EXTRA_ARGS" \
  -dtb "$workdir/bcm2709-rpi-2-b.dtb" \
\
  -no-reboot \
  -daemonize \
\
  "${@}"
