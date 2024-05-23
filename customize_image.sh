#!/bin/bash

# Function to display usage
usage() {
  echo "Usage: $0 <path-to-debian-cloud-init-image>"
  exit 1
}

# Check if a parameter is provided
if [ -z "$1" ]; then
  echo "Error: No image path provided."
  usage
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: The file '$1' does not exist."
  usage
fi

BASE_IMAGE_PATH=$1
# Define the path to your Debian cloud-init image
TIMESTAMP=$(date +%Y%m%d%H%M%S)
NEW_IMAGE_PATH="${BASE_IMAGE_PATH%.qcow2}-$TIMESTAMP.qcow2"

# Copy the base image to create a new image
cp "$BASE_IMAGE_PATH" "$NEW_IMAGE_PATH"

# Install required packages
virt-customize -a $IMAGE_PATH --install git,curl,ssh-import-id,qemu-guest-agent,build-essential

# Create the cloud-init configuration
cat << 'EOF' > /tmp/cloud-init.cfg
#cloud-config
runcmd:
  - [ "su", "-", "YOUR_USERNAME", "-c", "ssh-import-id-gh qnlbnsl" ]
  - [ "su", "-", "YOUR_USERNAME", "-c", "git clone https://github.com/qnlbnsl/dotfiles.git ~/.dotfiles" ]
EOF

# Replace YOUR_USERNAME with the actual username created by cloud-init
sed -i 's/YOUR_USERNAME/qnlbnsl/' /tmp/cloud-init.cfg

# Copy the cloud-init configuration into the image
virt-customize -a $IMAGE_PATH --upload /tmp/cloud-init.cfg:/etc/cloud/cloud.cfg.d/99_custom_runcmd.cfg

echo "Customization of $IMAGE_PATH is complete."
