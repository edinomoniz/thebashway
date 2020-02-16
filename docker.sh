docker pull debian:10
docker run -it -p 9000:9000 --name sectiGoHook debian:10 /bin/bash

apt-get update
apt-get -y upgrade

wget https://dl.google.com/go/go1.13.3.linux-amd64.tar.gz
tar -xvf go1.13.3.linux-amd64.tar.gz
mv go /usr/local

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
