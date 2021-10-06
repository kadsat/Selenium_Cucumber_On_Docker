# Selenium_Cucumber_On_Docker
project to run selenium cucumber scripts on aws using ECS/docker
need to run the following commands on the ec2 machine to install Docker and Docker-Compose
----------- Docker Installation -----------------------
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
---> Docker Auto start
sudo chkconfig docker on
---> Git installation
sudo yum install -y git
---> Reboot machine
sudo reboot

----------- Docker Compose Installation -----------------------
---> Installing latest version of docker-compose
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose

sudo chmod +x /usr/local/bin/docker-compose

docker-compose version
