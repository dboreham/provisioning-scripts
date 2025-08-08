#!/usr/bin/env bash

# Check if exactly one argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

USERNAME="$1"

# Check if user exists
if ! id "$USERNAME" &>/dev/null; then
    echo "Error: User '$USERNAME' does not exist"
    exit 1
fi

# Check if deny-ssh group exists, create if it doesn't
if ! getent group deny-ssh &>/dev/null; then
    echo "Creating deny-ssh group..."
    sudo groupadd deny-ssh
    echo "deny-ssh group has been created"
fi

# Add user to deny-ssh group
echo "Adding user '$USERNAME' to deny-ssh group..."
sudo usermod -a -G deny-ssh "$USERNAME"

# Check if deny-ssh is configured in sshd_config
if ! grep -q "deny-ssh" /etc/ssh/sshd_config 2>/dev/null; then
    echo ""
    echo "WARNING: 'deny-ssh' not found in /etc/ssh/sshd_config"
    echo "Please add the following line to /etc/ssh/sshd_config:"
    echo "    DenyGroups deny-ssh"
    echo "Then restart the SSH service with: sudo systemctl restart sshd (or ssh on newer Ubuntu)"
    echo ""
fi

# Set user's shell to nologin
echo "Setting user's shell to nologin..."
sudo usermod -s /usr/sbin/nologin "$USERNAME"

# Expire the user account
echo "Expiring user account..."
sudo usermod -e 1 "$USERNAME"

echo "User '$USERNAME' has been disabled:"
echo "  - Added to deny-ssh group"
echo "  - Shell set to /usr/sbin/nologin"
echo "  - Account expired"
