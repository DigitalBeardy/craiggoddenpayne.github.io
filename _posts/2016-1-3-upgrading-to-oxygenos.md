---
layout: post
title: Upgrading to OxygenOS
image: /assets/img/2016-1-3-upgrading-to-oxygenos/oxygenos.jpg
readtime: 10 minutes
---

So its been a while since I updated my phone firmware, for some reason on the OnePlusOne if you have a custom firmware, you still get prompted for an update, but it fails to install (most likely because of the custom firmware.


I decided to give OxygenOS a go, which is OnePlusOnes own take on CyanogenMod. Here's how I installed the OS, in case you didn't know already...


The build I used was the official v1 of OxygenOS, which can be downloaded here:
[download](http://oxygenos.oneplus.net/oxygenos_1.0.0.zip)


You have to make sure all the data is backed up before starting, as the flashing process will wipe the data from the drive. The image needs to be flashed manually, there isn't an automated installer.


This tutorial is written for OxygenOS the OnePlus One device, so it shouldn't be tried on any other device, or you could end up with a brick. The good thing is, flashing will not void your OnePlus warranty, but I've read that any damage caused by improper flashing is not covered under warranty.


First of all you need to have fastboot and adb installed (if you have android studio installed, you should already have this, otherwise you can install this pretty cool zip file here that should work.
[fastboot](https://www.androidfilehost.com/?fid=95747613655041220)


Once you have fastboot and adb installed, you need to flash a recovery onto your device. I use TWRP, but you should be able to use any of the others that support the oneplus, such as ClockworkMod.


To install TWRP, download this file:
[TWRP](https://dl.twrp.me/bacon/)


Place the file in the root of your C:\


Using a command window, run the following commands:
if your phone’s bootloader is not already unlocked
```bash
fastboot oem unlock
```

Then install the recovery image using:
```bash
fastboot flash recovery twrp-2.8.7.0-bacon.img
```

Then reboot the phone using:
```bash
fastboot reboot
```

You should now have the recovery installed.


Next is installing the actual OS.


Unzip the zip file you just downloaded. Inside the zip, you will see a file called oxygenos_1.0.0.flashable.zip. Copy this file to the root of your phone.


Next boot into recovery mode. This can be done by holding down both the volume down key and the power button for a few seconds.


Next you need to do a factory reset, which will lose all your data, but not contents of the drive. This can be selected on the TWRP interface


Next install the file you copied over to your phone and click confirm flash. This will flash the operation system onto your device. Next reboot the device,


When the phone next boots up, you should have OxygenOS!