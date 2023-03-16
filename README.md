`v1`

Automatic SW Raid

A tool for everyone to use: automatic SW Raid. You can make it by this command:

`wget -O - https://raw.githubusercontent.com/mrmagnifier/auto_raid/main/setup_raid.0 | bash`

If you want to have RAID: `0`, `1`, `5`, `6`, or `10`, change the last number of the link to the RAID number.

____

The tasks that are run by the script:

- Updating package list and installing mdadm
- Auto-detecting available disks
- Checking for existing md devices
- Unmounting and stopping existing md devices
- Wiping detected disks
- Checking if there are enough disks for the desired RAID level
- Creating RAID array
- Formatting the RAID array
- Mounting the RAID array
- Updating mdadm.conf
- Updating initramfs
- Adding RAID array to /etc/fstab
