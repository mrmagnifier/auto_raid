#!/bin/bash

# Update package list and install mdadm
sudo apt-get update
sudo apt-get install -y mdadm

# Auto-detect available disks excluding /dev/sda
disks=$(lsblk -d -n -o NAME | awk '{ print "/dev/"$1 }' | grep -v "md" | grep -v "sda")

# Wipe all detected disks except /dev/sda using wipefs
for disk in $disks; do
    sudo wipefs -af "$disk"
done

# Create RAID array
if [ "$(echo "$disks" | wc -l)" -lt 2 ]; then
    echo "Not enough disks detected for RAID. Exiting."
    exit 1
fi

raid_level=0  # Set the desired RAID level

sudo mdadm --create --verbose /dev/md0 --level="$raid_level" --raid-devices=$(echo "$disks" | wc -l) $disks

# Format the RAID array
sudo mkfs.ext4 -F /dev/md0

# Mount the RAID array
sudo mount /dev/md0 /home

# Update mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# Update initramfs
sudo update-initramfs -u

# Add the RAID array to /etc/fstab
echo '/dev/md0 /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab

# Wipe History
sudo history -c

# Output of home
sudo df -h /home
