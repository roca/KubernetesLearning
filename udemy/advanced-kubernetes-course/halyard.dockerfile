# FROM gcr.io/spinnaker-marketplace/halyard:stable
FROM ubuntu:xenial

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install software-properties-common -y
RUN apt-get install python-software-properties -y

ENV ADDRESS=index.docker.io
ENV REPOSITORIES="library/alpine library/ubuntu library/centos library/nginx rcampbell/spinnaker-node-demo"

ARG AWS_ACCESS_KEY_ID
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ARG AWS_SECRET_ACCESS_KEY 
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

EXPOSE 8064
EXPOSE 8084
EXPOSE 9000

RUN mkdir -p /var/d120udemy/advanced-kubernetes-course

WORKDIR /var/udemy/advanced-kubernetes-course
ADD . /var/udemy/advanced-kubernetes-course

RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

RUN curl -O  https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
RUN adduser --disabled-password --gecos "" admin
RUN bash InstallHalyard.sh --user admin

ENTRYPOINT ["tail", "-f", "/dev/null"]