#!/bin/sh

# Make sure the docker network is created first
docker network create footloose-cluster 2>/dev/null

# Make sure we have an up-to-date image for the footloose nodes
# docker pull quay.io/footloose/ubuntu20.04
docker pull jakolehm/footloose-ubuntu20.04

# Create docker containers
footloose create -c footloose.yaml

# set up k3s on node0 as the master
# https://computingforgeeks.com/install-kubernetes-on-ubuntu-using-k3s/
footloose ssh root@node0 -- "apt update"
footloose ssh root@node0 -- "apt install apt-transport-https ca-certificates curl software-properties-common ufw -y"
footloose ssh root@node0 -- "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
footloose ssh root@node0 -- "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\""
footloose ssh root@node0 -- "apt install docker-ce -y"
footloose ssh root@node0 -- "systemctl start docker"
footloose ssh root@node0 -- "systemctl enable docker"
footloose ssh root@node0 -- "curl -sfL https://get.k3s.io | sh -s - --docker"

# Allow ports on firewall
footloose ssh root@node0 -- "ufw allow 6443/tcp"
footloose ssh root@node0 -- "ufw allow 443/tcp"

# get the token from node0
export k3stoken=$(footloose ssh root@node0 -- cat /var/lib/rancher/k3s/server/node-token)

# set up k3s on node1 with the token from node0
footloose ssh root@node1 -- "apt update"
footloose ssh root@node1 -- "apt install apt-transport-https ca-certificates curl software-properties-common ufw -y"
footloose ssh root@node1 -- "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
footloose ssh root@node1 -- "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\""
footloose ssh root@node1 -- "apt install docker-ce -y"
footloose ssh root@node1 -- "systemctl start docker"
footloose ssh root@node1 -- "systemctl enable docker"
footloose ssh root@node1 -- "curl -sfL http://get.k3s.io | K3S_URL=https://node0:6443 K3S_TOKEN=$k3stoken sh -s - --docker"

# set up k3s on node2 with the token from node0
footloose ssh root@node2 -- "apt update"
footloose ssh root@node2 -- "apt install apt-transport-https ca-certificates curl software-properties-common ufw -y"
footloose ssh root@node2 -- "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -"
footloose ssh root@node2 -- "add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\""
footloose ssh root@node2 -- "apt install docker-ce -y"
footloose ssh root@node2 -- "systemctl start docker"
footloose ssh root@node2 -- "systemctl enable docker"
footloose ssh root@node2 -- "curl -sfL http://get.k3s.io | K3S_URL=https://node0:6443 K3S_TOKEN=$k3stoken sh -s - --docker"

echo "Done, you can use \"footloose ssh root@node0 \" to SSH to the master node."
