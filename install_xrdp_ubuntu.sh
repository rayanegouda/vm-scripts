#!/bin/bash

# Activer le mode non interactif pour éviter les invites de confirmation
export DEBIAN_FRONTEND=noninteractive

# Installer needrestart pour éviter les interruptions
sudo apt install -y needrestart
echo 'restart auto' | sudo tee /etc/needrestart/needrestart.conf

echo "🔹 Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

echo "🔹 Installation de l'environnement graphique XFCE4..."
sudo apt install -y xrdp xfce4 xfce4-terminal dbus-x11 x11-xserver-utils

echo "🔹 Configuration de XRDP..."
echo "xfce4-session" | sudo tee /etc/skel/.xsession > /dev/null
echo "xfce4-session" | sudo tee ~/.xsession > /dev/null

# Ajouter l'utilisateur XRDP au groupe SSL-cert pour éviter les erreurs de connexion
sudo adduser xrdp ssl-cert

# Modifier startwm.sh pour utiliser XFCE4 avec xRDP
echo -e "#!/bin/bash\nexec startxfce4" | sudo tee /etc/xrdp/startwm.sh > /dev/null

# Appliquer les bonnes permissions
sudo chmod +x /etc/xrdp/startwm.sh

# Activer et redémarrer les services XRDP
sudo systemctl enable xrdp
sudo systemctl restart xrdp xrdp-sesman

# Ouvrir le port 3389 (RDP) dans le firewall UFW
echo "🔹 Configuration du pare-feu UFW..."
sudo ufw allow 3389/tcp
sudo ufw reload

# Mettre le clavier en fr
echo "🔹 Configuration du clavier en fr ...."
echo "setxkbmap fr" | sudo tee ~/.xsessionrc > /dev/null

# Définir un mot de passe pour l'utilisateur Ubuntu (modifiable)
echo "ubuntu:ubuntu" | sudo chpasswd

# Activer l'authentification par mot de passe SSH pour faciliter l'accès
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
