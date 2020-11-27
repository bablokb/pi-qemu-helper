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
    sudo ./extract_kernel.sh 2020-08-20-raspios-buster-armhf-lite.img
    sudo chown -R myuid:mygroupid .
    
    # first boot: resizes second partition and changes /boot/cmdline.txt
    ./raspi2.sh 2020-08-20-raspios-buster-armhf-lite.img
    
    # extract cmdline.txt again (needed once after first boot)
    ./extract_kernel.sh 2020-08-20-raspios-buster-armhf-lite.img
    sudo chown -R myuid:mygroupid .
    
    # create qcow2 image for deltas (optional, but recommended)
    qemu_img create -b 2020-08-20-raspios-buster-armhf-lite.img 2020-08-20-delta.qcow2
    
    # use delta image in future boots
    ./raspi2.sh 2020-08-20-delta.qcow2
 

extract_kernel.sh
-----------------

This script extracts the commandline, kernels and dtbs for the
/raspi2/ and /raspi0/ virtual boards. This script has to be run as root.

This is necessary because QEmu needs these files outside of the image.

Since the first boot changes the file `cmdline.txt` within the image,
the extraction has to take place two times, once before the first boot
and once after the first boot.


raspi2.sh
---------

This starts the emulator with the hardware configured for the
`raspi2`-board. The script required an image as the first parameter.
You can add additional QEmu-options starting from the second option,
e.g.

    ./raspi2.sh 2020-08-20-delta.qcow2 -snapshot

will start the emulator in snapshot mode (i.e. all changes during the
session are discarded afterwards).

