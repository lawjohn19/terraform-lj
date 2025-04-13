#!/bin/bash

# This script installs Jenkins on a Debian-based system (like Ubuntu).
sudo apt update -y

# Install Java 21 (Adoptium)
sudo apt install -y wget apt-transport-https gpg 

# Add the Adoptium repository
sudo wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# Update the package list again to include the Adoptium packages
sudo apt install -y default-jre

# Install Jenkins keyring and add the Jenkins repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

#update repo again
sudo apt update -y

# Install Jenkinks
sudo apt install -y jenkins

# Start Jenkins and enable it to start on boot
sudo systemctl start jenkins

# enable jenkins to start on boot
sudo systemctl enable jenkins