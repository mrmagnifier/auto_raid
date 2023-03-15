#!/bin/bash

# Define a simple progress bar function
progress_bar() {
    bar="##################################################"
    bar_length=${#bar}
    i=0
    while [ $i -le $bar_length ]; do
        printf "|%-${bar_length}s|\r" "${bar:0:$i}"
        sleep 1
        i=$((i + 1))
    done
    echo
}

# Update package list and install mdadm
sudo apt-get update
sudo apt-get install -y mdadm

# Auto-detect available disks excluding /dev/sda
disks=$(lsblk -d -n -o NAME | awk '{ print "/dev/"$1 }' | grep -v "md" | grep -v "sda")

# Wipe all detected disks except /dev/sda using wipefs
echo "Wiping disks..."
for disk in $disks; do
    sudo wipefs -af "$disk" &
    progress_bar
done

# Create RAID array
if [ "$(echo "$disks" | wc -l)" -lt 2 ]; then
    echo "Not enough disks detected for RAID. Exiting."
    exit 1
fi

raid_level=1  # Set the desired RAID level
echo "Creating RAID array..."
sudo mdadm --create --verbose /dev/md0 --level="$raid_level" --raid-devices=$(echo "$disks" | wc -l) $disks

# Format the RAID array
echo "Formatting RAID array..."
sudo mkfs.ext4 -F /dev/md0

# Mount the RAID array
echo "Mounting RAID array..."
sudo mount /dev/md0 /home

# Update mdadm.conf
echo "Updating mdadm.conf..."
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf

# Update initramfs
echo "Updating initramfs..."
sudo update-initramfs -u

# Add the RAID array to /etc/fstab
echo "Updating /etc/fstab..."
echo '/dev/md0 /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab

# Display disk space usage
echo "Script finished. Displaying disk space usage:"
df -h
