cd CustomerCare

# sudo rpm -Uvh https://packages.microsoft.com/config/centos/7/packages-microsoft-prod.rpm
# sudo yum install dotnet-sdk-3.1 -y
# sudo yum install aspnetcore-runtime-3.1 -y
# sudo yum install dotnet-runtime-3.1 -y

dotnet --version
dotnet build

# aws --version
# # pip install awscli
set +x 
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1
set -x

# sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# sudo yum install -y docker-ce-cli

# cat /etc/docker/daemon.json

# cat /etc/redhat-release

# chattr -i /etc/docker/daemon.json
# ps aux

# sudo lsof # | grep /etc/docker/daemon.json

# sudo ls /var/log/

# ---------------------------------------------------
# cat /usr/lib/systemd/system/docker.service
# sudo cat << EOF > /tmp/daemon.json
# {
#   "bip": "10.10.10.1/24",
#   "dns": ["10.99.0.2"],
#   "log-driver": "json-file",
#   "data-root": "/var/jenkins/docker",
#    "insecure-registries": [
#     "nexus.endava.net:5668",
#     "nexus.endava.net:20021",
#     "nexus.endava.net:20030"
#   ]
# }
# EOF

#  sudo journalctl -u docker --no-pager
# ---------------------------------------------------


# sudo sed -i -e 's|/etc/docker/daemon-new.json|/tmp/daemon.json|'  /usr/lib/systemd/system/docker.service

# cat  /usr/lib/systemd/system/docker.service
# sudo systemctl daemon-reload
# sudo service docker start

#cat  /usr/lib/systemd/system/docker.service | grep 'containerd='

# sudo find / | grep docker.service

# sudo tail /var/log/messages -n 1000
# sudo tail /var/log/secure -n 1000

# sudo pidof dockerd

#  sudo journalctl -u docker --no-pager

# # ls -la /etc/docker/daemon.json

# # ps -ejH

 
# sudo service docker status



# cat /etc/docker/daemon.json

# docker -v

# # sudo journalctl -xe --no-pager
# sudo service docker restart
# sudo systemctl status docker.service

# sudo docker ps -a

aws --region us-east-1 eks get-token --cluster-name eks

sudo docker build -f API/Dockerfile -t behemoth:latest .
docker tag behemoth:latest 555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:latest
docker tag behemoth:latest 555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:v${BUILD_NUMBER}

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 555256523315.dkr.ecr.us-east-1.amazonaws.com

docker push 555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:v${BUILD_NUMBER}
docker push 555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:latest

curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl

# aws s3 cp s3://endava-devops-intern-bg/kubeconfig.txt kubeconfig

# aws eks --region us-east-1 update-kubeconfig --name eks

# kubectl version --client
#./kubectl --kubeconfig=kubeconfig set image deployment/customer-care-deployment customer-care-beh=555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:latest -n behemoth
./kubectl set image deployment/customer-care-deployment customer-care-beh=555256523315.dkr.ecr.us-east-1.amazonaws.com/behemoth:v${BUILD_NUMBER} -n behemoth