sudo apt-get remove docker docker-engine docker.io containerd runc

# sudo apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     software-properties-common

# curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

# https://download.docker.com/linux/debian/dists/jessie/

# sudo apt-key fingerprint 0EBFCD88


# sudo sudo add-apt-repository \
#    "deb [arch=armhf] https://download.docker.com/linux/debian \
#    $(lsb_release -cs) \
#    stable"

# sudo apt-get update

# sudo apt-get install docker-ce docker-ce-cli containerd.io


sudo groupadd docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker vagrant

