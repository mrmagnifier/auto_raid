#!/bin/bash

# Update package list and install mdadm and pv
sudo apt-get update
sudo apt-get install -y mdadm pv

# Auto-detect available disks excluding /dev/sda
disks=$(lsblk -d -n -o NAME | awk '{ print "/dev/"$1 }' | grep -v "md" | grep -v "sda")

total_steps=8
current_step=0

# Function to display progress bar
display_progress_bar() {
  current_step=$((current_step + 1))
  printf "\rProgress: %3d%%" $((current_step * 100 / total_steps))
  pv -q -L 1 -s 1 >/dev/null
}

# Wipe all detected disks except /dev/sda using wipefs
for disk in $disks; do
    sudo wipefs -af "$disk"
    display_progress_bar
done

# Create RAID array
if [ "$(echo "$disks" | wc -l)" -lt 2 ]; then
    echo "Not enough disks detected for RAID. Exiting."
    exit 1
fi

raid_level=0  # Set the desired RAID level

sudo mdadm --create --verbose /dev/md0 --level="$raid_level" --raid-devices=$(echo "$disks" | wc -l) $disks
display_progress_bar

# Format the RAID array
sudo mkfs.ext4 -F /dev/md0
display_progress_bar

# Mount the RAID array
sudo mount /dev/md0 /home
display_progress_bar

# Update mdadm.conf
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
display_progress_bar

# Update initramfs
sudo update-initramfs -u
display_progress_bar

# Add the RAID array to /etc/fstab
echo '/dev/md0 /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
display_progress_bar

# Wipe History
history -c
history -w


# Output of home
echo -e "\Software Raid is ready"
sudo df -h /home
