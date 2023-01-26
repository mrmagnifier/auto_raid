{\rtf1\ansi\ansicpg1252\cocoartf2707
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fnil\fcharset0 HelveticaNeue;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww11520\viewh8400\viewkind0
\deftab560
\pard\pardeftab560\slleading20\partightenfactor0

\f0\fs26 \cf0 #!/bin/bash\
\
# Install mdadm tool\
apt-get install -y mdadm\
\
# Create RAID 0 array\
mdadm --create /dev/md0 --level=0 --raid-devices=12 /dev/sd[b-m]\
\
# Get RAID details and add it to the mdadm.conf\
mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf\
\
# Format the new RAID 0 array as ext4 filesystem\
mkfs.ext4 /dev/md0\
\
# Mount the RAID 0 array\
mount /dev/md0 /home\
\
# Update the initramfs\
sudo update-initramfs -u\
\
# Add an entry to the system's fstab file for mounted boot\
echo "/dev/md0 /home ext4 defaults,nofail,discard 0 0" | sudo tee -a /etc/fstab}