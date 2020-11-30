Helper scripts for QEmu emulation for the Rasperry Pi family of virtual boards
==============================================================================

This is a collection of a number of helper-scripts for emulating
Raspberry Pi boards within QEmu.

Note: to run these scripts, you need a Linux host. I have no idea if they work
with the Linux-emulation on Win10 or within an Apple iShell. Feedback
and comments on this issue are welcome.

The scripts were developed and tested with QEmu 5.2-rc2.


Typical Usage
-------------

    # with original image
    sudo extract_kernel.sh 2020-08-20-raspios-buster-armhf-lite.img

    # resize image (SD card size has to be a power of 2 for QEmu)
    qemu-img resize 2020-08-20-raspios-buster-armhf-lite.img 4G

    # first boot: resizes second partition and changes /boot/cmdline.txt
    raspi2.sh 2020-08-20-raspios-buster-armhf-lite.img

    # extract cmdline.txt again (needed once after first boot)
    extract_kernel.sh 2020-08-20-raspios-buster-armhf-lite.img

    # create qcow2 image for deltas (optional, but recommended)
    qemu_img create -f qcow2 -b 2020-08-20-raspios-buster-armhf-lite.img delta.qcow2
    
    # use delta image in future boots
    raspi2.sh delta.qcow2
 

extract_kernel.sh
-----------------

This script extracts the commandline, kernels and dtbs for the
*raspi0*,  *raspi2* and *raspi3* virtual boards. This script has to be run as root.

This is necessary because QEmu needs these files *outside* of the image.

Since the first boot changes the file `cmdline.txt` *within* the image,
the extraction has to take place two times, once before the first boot
and once after the first boot.


raspi_.sh
---------

This is the generic start-script for all raspi-boards. Used by the other
scripts, but can also be called directly.


raspi0.sh, raspi2.sh, raspi3.sh
-------------------------------

This starts the emulator with the hardware configured for the
respective board. The script requires an image as the first parameter.
You can add additional QEmu-options starting from the second option,
e.g.

    raspi2.sh 2020-08-20-delta.qcow2 -snapshot

will start the emulator in snapshot mode (i.e. all changes during the
session are discarded afterwards).


Random Notes
------------

To add an USB-disk (stick), do the following:

    qemu-img create -f qcow2 virt_disk.qcow2 16G
    raspi2.sh delta.qcow2 \
            -drive file=virt_disk.qcow2,if=none,node-name=my_disk \
            -device usb-storage,drive=my_disk

This will show up as `/dev/sda` in the guest. Don't expect great performance,
USB-storage seems to use the USB 1.1 interface.

The Pi-Zero kernel currently boots directly into a kernel panic.

After successful shutdown, all kernels end with a kernel panic, which can be
safely ignored.
