FROM ubuntu:latest

RUN mkdir -p /var/work

WORKDIR /var/work
ADD . /var/work

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install python -y
RUN apt-get install wget -y
RUN curl https://sdk.cloud.google.com | bash

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

ENTRYPOINT ["tail", "-f", "/dev/null"]
