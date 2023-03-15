#!/bin/bash

# Calculate approximate progress steps
total_steps=8
current_step=0

# Function to update and display the progress percentage
update_progress() {
    current_step=$((current_step + 1))
    progress_percentage=$((current_step * 100 / total_steps))
    echo -ne "Progress: $progress_percentage%\\r"
}

# Run the script in a subshell
(
    # Update package list and install mdadm
    sudo apt-get update >/dev/null 2>&1
    sudo apt-get install -y mdadm >/dev/null 2>&1
    update_progress

    # Auto-detect available disks excluding /dev/sda
    disks=$(lsblk -d -n -o NAME | awk '{ print "/dev/"$1 }' | grep -v "md" | grep -v "sda")
    update_progress

    # Wipe all detected disks except /dev/sda using wipefs
    for disk in $disks; do
        sudo wipefs -af "$disk" >/dev/null 2>&1
    done
    update_progress

    # Check disk count
    if [ "$(echo "$disks" | wc -l)" -lt 2 ]; then
        echo "Not enough disks detected for RAID. Exiting."
        exit 1
    fi

    raid_level=0  # Set the desired RAID level

    sudo mdadm --create --verbose /dev/md0 --level="$raid_level" --raid-devices=$(echo "$disks" | wc -l) $disks >/dev/null 2>&1
    update_progress

    # Format the RAID array
    sudo mkfs.ext4 -F /dev/md0 >/dev/null 2>&1
    update_progress

    # Mount the RAID array
    sudo mount /dev/md0 /home >/dev/null 2>&1
    update_progress

    # Update mdadm.conf
    sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf >/dev/null 2>&1
    update_progress

    # Update initramfs
    sudo update-initramfs -u >/dev/null 2>&1
    update_progress

    # Add the RAID array to /etc/fstab
    echo '/dev/md0 /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab >/dev/null 2>&1
)

# Notify when the script is finished
echo -e "\nThe script is finished."
sudo df -h /home
