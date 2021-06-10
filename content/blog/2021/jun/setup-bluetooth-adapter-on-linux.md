---
title: "Setup Bluetooth Adapter on Linux"
date: 2021-06-09T06:52:16+07:00
draft: false
tags:
    - linux
    - bluetooth
    - firmware
    - driver
---

I have a desktop with Linux installed on it and i would like to add bluetooth adapter for it. This is my Linux version
```
➜ uname -v -r   
5.8.0-55-generic #62~20.04.1-Ubuntu SMP Wed Jun 2 08:55:04 UTC 2021
```

So i decided to bought 
this "ORICO BTA508 USB Bluetooth 5.0 Dongle BTA 508 BTA-508 Adapter - Hitam" from [Tokopedia](https://www.tokopedia.com/clickandgo/orico-bta508-usb-bluetooth-5-0-dongle-bta-508-bta-508-adapter-hitam). But, the only official driver/firmware is for Windows. 

Then, how about Linux ? To solve this question, we need to know which chip the bluetooth uses and install a custom firmware/driver. 

Use this command to check what chips the bluetooth adapter use
```
dmesg | grep -i Bluetooth
```

The output should looks like this

```
[    1.810236] usb 1-4.2: Product: Bluetooth Radio
...
[    3.546498] Bluetooth: hci0: RTL: loading rtl_bt/rtl8761b_fw.bin
[    3.551034] Bluetooth: hci0: RTL: loading rtl_bt/rtl8761b_config.bin
...
```

This line `hci0: RTL: loading rtl_bt/rtl8761b_fw.bin` shows us, that the chip is `rtl8761b` and it need `rtl8761b_fw` firmware/driver.
So i google `rtl8761b_fw` and found an article from [raspberry forum](https://www.raspberrypi.org/forums/viewtopic.php?t=294634) with the same question.

But, to be sure i look up to it once again and found this arch linux [post](https://aur.archlinux.org/packages/rtl8761b-fw/). After i read from arch linux post, i decided to follow it. So, i download the driver from the [source](https://mpow.s3-us-west-1.amazonaws.com/mpow_BH519A_driver+for+Linux.7z) mention in the article and follow the steps from the raspberry forum article as follows:

1. Extract the driver
2. Copy the drivers
```
sudo cp -iv 20201202_LINUX_BT_DRIVER/rtkbt-firmware/lib/firmware/rtlbt/rtl8761b_fw /lib/firmware/rtl_bt/rtl8761b_fw.bin

sudo cp -iv 20201202_LINUX_BT_DRIVER/rtkbt-firmware/lib/firmware/rtlbt/rtl8761b_config /lib/firmware/rtl_bt/rtl8761b_config.bin
```
3. Reboot

Thats it, when i check on bluetooth manager, it works
