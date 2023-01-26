import os

# Launch script
if __name__ == "__main__":

    # Launch Script
    os.system("Start")

    # How many disks does the server contain?
    num_disks = input("Enter the number of disks in the server (2-24): ")
    while int(num_disks) < 2 or int(num_disks) > 24:
        num_disks = input("Invalid input. Enter the number of disks in the server (2-24): ")

    # Which RAID is needed?
    raid_type = input("Enter the RAID type (RAID 0, RAID 1, RAID 10, or RAID 5): ").lower()
    while raid_type not in ["raid 0", "raid 1", "raid 10", "raid 5"]:
        raid_type = input("Invalid input. Enter the RAID type (RAID 0, RAID 1, RAID 10, or RAID 5): ").lower()

    # Please put in the name of the mount point
    mount_point = input("Enter the mount point (default: home): ") or "home"

    # Please confirm with ‘’y’’ to proceed
    confirm = input("Enter 'y' to proceed: ").lower()
    if confirm != "y":
        exit()

    # Trigger automatic SW Raid w/ *NEEDED AMOUNT* disks
    os.system("sudo apt-get update")
    os.system("sudo apt-get install -y mdadm")
    os.system(f"sudo mdadm --create /dev/md0 --level 0 --raid-devices {num_disks} /dev/sd[b-m]")
    os.system("sudo mkfs.ext4 /dev/md0")
    os.system(f"sudo mount /dev/md0 /{mount_point}")
    os.system("sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf")
    os.system("sudo update-initramfs -u")
    os.system(f"echo '/dev/md0 /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab)

    # Configured storage *amount*
    os.system(f''df -h /{mount_point})