#!/bin/bash
# --------------------------------------------------------------------------
# Generic start-script for qem-system-arm/qemu-system-aarch64
# for the raspi-family of boards.
#
# Author: Bernhard Bablok
# License: GPL3
#
# Website: https://github.com/bablokb/pi-qemu-helper
#
# --------------------------------------------------------------------------

# --- some constants   -----------------------------------------------------

EXTRA_ARGS="dwc_otg.fiq_fsm_enable=0"

declare -A kernel dtb qemu

kernel['raspi0']="kernel.img"
kernel['raspi2']="kernel7.img"
kernel['raspi3']="kernel8.img"

dtb['raspi0']="bcm2708-rpi-zero.dtb"
dtb['raspi2']="bcm2709-rpi-2-b.dtb"
dtb['raspi3']="bcm2710-rpi-3-b.dtb"

qemu['raspi0']="qemu-system-arm"
qemu['raspi2']="qemu-system-arm"
qemu['raspi3']="qemu-system-aarch64"


# set defaults   --------------------------------------------------------------

setDefaults() {
  screen_size=1024x768
  verbose=0
}

# --- help   -----------------------------------------------------------------

usage() {
  local pgm=`basename $0`
  echo -e "\n$pgm: emulate Raspberry Pi board with QEmu\n\
  \nusage: `basename $0` [options] image [qemu-options]\n\
  Possible options:\n\n\
    -b board       board to emulate (raspi0, raspi2, raspi3)
    -S size        screen-size (default: $screen_size)
    -v             verbose operation
    -h             show this help
"
  exit 3
}

# --- parse arguments and set variables   ------------------------------------

parseArguments() {
  while getopts ":b:S:vh" opt; do
    case $opt in
      b) board="$OPTARG";;
      S) screen_size="$OPTARG";;
      v) verbose=1;;
      h) usage;;
      ?) echo "error: illegal option: $OPTARG"
           usage;;
    esac
  done

  shift $((OPTIND-1))
  osimg="$1"
  shift
  qemu_extra=("$@")
}

# --- check arguments   ------------------------------------------------------

checkArguments() {
  if [ -z "$osimg" ]; then
    echo "error: no board specified!" >&2
    usage
  fi
  local workdir="$(dirname $osimg)"
  local osimg="$(basename $osimg)"

  if [ -z "$board" ]; then
    echo "error: no board specified!" >&2
    usage
  fi
  if [ -z "${kernel[$board]}" ]; then
    echo "error: board $board is unsupported!" >&2
    usage
  fi

  # build paths
  img_file="$workdir/$osimg"
  kernel_file="$workdir/${kernel[$board]}"
  cmdline_file="$workdir/cmdline.txt"
  dtb_file="$workdir/${dtb[$board]}"

  # args for screen resolution
  local width="${screen_size%x*}"
  local height="${screen_size#*x}"
  screen_args="bcm2708_fb.fbwidth=$width bcm2708_fb.fbheight=$height"
}

# --- main program   ---------------------------------------------------------

setDefaults
parseArguments "$@"
checkArguments

if [ $verbose -eq 1 ]; then
  echo -e "info: starting ${qemu[$board]} with \n\
      board:       $board \n\
      image:       $img_file \n\
      kernel:      $kernel_file \n\
      dtb:         $dtb_file \n\
      commandline: $(cat $cmdline_file) $screen_args $EXTRA_ARGS"
fi

"${qemu[$board]}" \
  -machine "$board" \
  -device usb-mouse \
  -device usb-kbd \
  -drive file="$img_file",if=sd \
  -netdev user,id=net0,hostfwd=tcp::8022-:22 \
  -device usb-net,netdev=net0 \
\
  -kernel "$kernel_file" \
  -append "$(cat $cmdline_file) $screen_args $EXTRA_ARGS" \
  -dtb "$dtb_file" \
\
  -no-reboot \
  -daemonize \
\
  "${qemu_extra[@]}"
