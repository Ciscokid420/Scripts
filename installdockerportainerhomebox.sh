#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Set the Linux Mint version codename variable
MINT_CODENAME=$(lsb_release -cs)

# Set the IP address variable to the system's IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

# Update package list and install dependencies
apt update
apt -y install apt-transport-https ca-certificates curl software-properties-common

# Remove existing Docker packages
apt -y remove docker docker-engine docker.io containerd runc

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list again
apt update

# Install Docker
apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Activate the Docker group membership
echo "adding new group"
groupadd docker

# Add your user to the Docker group
echo "adding user to docker"
usermod -aG docker $USER

echo "DOCKER IS INSTALLED AND SUDO IS NO LONGER NEEDED."

#Install portainer
echo "Installing Portainer"
docker volume create portainer_data
docker run -d -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data --name portainer --restart always portainer/portainer-ce

echo "PORTAINER IS NOW INSTALLED ALONGSIDE DOCKER. Please log into portainer to set up the conatiner manager @ localhost:9000"

echo "getting github repo for homebox"
git clone https://github.com/hay-kot/homebox.git
echo "running docker compose up for homebox"
cd homebox
docker compose up 
