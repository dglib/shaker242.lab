# Installing Red Hat Virturalization Host 4.3
Using a USB key with the .iso burned to it, install rhvh on the internal SD Card.

### Burning .iso steps
1. insert usb key
2. list usb keys using ``` diskutil list ```
3. unmount / don't eject usb ``` umount /dev/diskX ```
4. burn iso ``` dd if=/path/to/.iso of=/dev/diskX bs=1m ```

## Using the USB key install your system

## Let's setup RHVH 4.3
1. visit cockpit https://ip.of.your.host:9090
2. register and enable repos via terminal
  a. ``` subscription-manager register --auto-attach ```
  b. ``` subscription-manager repos --enable=rhel-7-server-rhvh-4-rpms ```
3. update host ``` yum update -y ```