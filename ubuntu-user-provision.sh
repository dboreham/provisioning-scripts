new_user=david
adduser --disabled-password --gecos "" ${new_user}
usermod -aG sudo ${new_user}
cp -a ~/.ssh/ /home/${new_user}
chown -R ${new_user}:${new_user} /home/${new_user}/.ssh
echo ${new_user}' ALL=(ALL) NOPASSWD:ALL' | EDITOR='tee -a' visudo
