sudo apt-get install -y golang-go

# wget https://golang.org/dl/go1.15.2.linux-amd64.tar.gz
# sudo tar -C /usr/local -xzf go1.15.2.linux-amd64.tar.gz

# wget https://dl.google.com/go/go1.15.2.linux-arm64.tar.gz
# sudo tar -C /usr/local -xzf go1.15.2.linux-arm64.tar.gz
# rm go1.15.2.linux-arm64.tar.gz

# cat <<EOF >> /home/vagrant/.profile
# export PATH=${PATH}:/usr/local/go/bin:${HOME}/go/bin
# EOF

# sudo apt-get install libopencv-dev

# go get -u -d gocv.io/x/gocv
# make deps
# make download
# make build

cat <<EOF >> /home/vagrant/.profile
export GOPATH="/go"
export GOARCH="arm"
export GOOS="linux"
export GOARM=5
EOF

