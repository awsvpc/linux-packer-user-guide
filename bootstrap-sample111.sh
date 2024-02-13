#!/bin/bash

# 1. Create a new EC2 Amazon Linux 2
# 2. Run: bash -c "$(curl -fsSL https://gist.github.com/lgothelipe/f7f39af4d7105844465575769b1acc5e/raw/devops.sh)" -- zsh
# 3. Git config 

timezone="Australia/Melbourne"
terraform="1.6.6-1"
nvm="v0.39.7"
node="18"
kubectl="1.28.5/2024-01-04" # https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

#Install git and docker
sudo yum -y update && sudo yum install -y git docker
sudo systemctl start docker.service
sudo systemctl enable docker.service

#Timezone
sudo timedatectl set-timezone $timezone

#Install docker compose
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) 
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose
sudo usermod -aG docker $USER

#Bash configuration "Oh my bash"
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" --unattended
sudo sed -i 's/OSH_THEME=\"font\"/OSH_THEME=\"sexy\"/g' ~/.bashrc

#Zsh
zsh_shell=$1
sudo yum install -y zsh
bash -c "$(curl https://gist.githubusercontent.com/lgothelipe/a67162ccc23aaa38220785561be60cab/raw/prezto.sh) prezto.sh"
sed -i 's/sorin/steeef/g' ~/.zpreztorc
if [ $zsh_shell == zsh];
then sudo sed -i 's/ec2-user\:\/bin\/bash/ec2-user\:\/bin\/zsh/g' /etc/passwd
fi
# https://gist.github.com/arvind-iyer/a71e7a07dd99ffccae368a5f99b640d9

#install Terraform
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform-$terraform.x86_64
terraform -install-autocomplete
# terraform -v 

#aws cli 2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install -i /usr/local/aws-cli -b /usr/local/bin
rm -rf aws awscliv2.zip

#AWS Session Manager plugin
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/linux_64bit/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
sudo yum install -y session-manager-plugin.rpm
rm -rf session-manager-plugin.rpm

#nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$nvm/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install $node
nvm use $node
#nvm list

#kubectl
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/$kubectl/bin/linux/amd64/kubectl 
chmod +x ./kubectl 
sudo mv kubectl /usr/bin/kubectl
#kubectl version

#helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

#python3
sudo yum install -y python3 python3-devel python3-pip

#boto3
pip3 install boto3

#alias
echo "\nalias python="python3"" | sudo tee -a /home/ec2-user/.zshrc
echo "\nalias pip="pip3""       | sudo tee -a /home/ec2-user/.zshrc

#vscode cli
# curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz
# tar -xf vscode_cli.tar.gz
# rm -rf vscode_cli.tar.gz
# sudo chmod +x code
# sudo mv code /usr/bin/code-cli

#swap memory
sudo dd if=/dev/zero of=/swapfile count=2048 bs=1MiB
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s
echo "/swapfile swap swap defaults 0 0" | sudo tee -a /etc/fstab
#cat /etc/fstab

sudo shutdown -r now
