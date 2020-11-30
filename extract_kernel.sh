#!/bin/bash
# --------------------------------------------------------------------------
# This script extracts cmdline.txt, kernels and DTBs from a RaspiOS-image
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-qemu-helper
#
# --------------------------------------------------------------------------

BOOT_FILES="kernel.img  bcm2708-rpi-zero.dtb \
            kernel7.img bcm2709-rpi-2-b.dtb  \
            kernel8.img bcm2710-rpi-3-b.dtb  \
            cmdline.txt"

# --- write message to stderr   --------------------------------------------

msg() {
  echo -e "$1" >&2
}

# --- check program prereqs and arguments   --------------------------------
checkPrereqs() {
  local p pgms="losetup"

  # check argument
  if [ -z "$1" ]; then
    msg "error: missing argument (path to image)!"
    exit 3
  fi

  # check file
  if [ ! -f "$1" ]; then
    msg "error: image-file $1 does not exist"
    exit 3
  else
    srcImage="$1"
    srcDir=$(dirname "$srcImage")
  fi

  # check mandatory programs
  for p in $pgms; do
    if ! type -p $p > /dev/null; then
      msg "error: you need to install program $p to run this script!"
      exit 3
    fi
  done

  # check uid = 0
  if [ "$UID" != "0" ]; then
    msg "error: you need to be root to run this script!"
    exit 3
  fi
}

# --- main program   -------------------------------------------------------

checkPrereqs "$@"

modprobe loop

msg "info: setting up loop-device for $srcImage"
srcDevice=$(losetup --show -f -P "$srcImage")

msg "info: mounting ${srcDevice}p1"
srcMount=`mktemp -d --tmpdir qemuhelper.XXXXXX`
mount "${srcDevice}p1" "$srcMount"

if [ -f "$srcDir/cmdline.txt" -a ! -f "$srcDir/cmdline.txt.1st" ]; then
  msg "info: moving $srcDir/cmdline.txt to $srcDir/cmdline.txt.1st"
  mv  "$srcDir/cmdline.txt" "$srcDir/cmdline.txt.1st"
fi

msg "info: copying files from boot-partition"
for f in $BOOT_FILES; do
  cp -a "$srcMount/$f" "$srcDir/"
done

msg "info: cleanup of loop-mount"
umount "$srcMount"
losetup -d "$srcDevice"

if [ "$USER" != "root" ]; then
  uid="$USER"
elif [ -n "$SUDO_USER" ]; then
  uid="$SUDO_USER"
fi
gid=$(id -g "$uid")

if [ -z "$uid" ]; then
  msg "info: please change ownership of kernel-files manually"
else
  msg "info: attemting to give ownership back to original user"
  for f in $BOOT_FILES; do
    chown -R "$uid:$gid" "$srcDir/$f"
  done
fi
exit 0
