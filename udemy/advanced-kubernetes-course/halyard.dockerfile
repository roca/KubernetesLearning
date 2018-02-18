# FROM gcr.io/spinnaker-marketplace/halyard:stable
FROM ubuntu:14.04

RUN apt-get update
RUN apt-get install curl -y
RUN apt-get install software-properties-common -y
RUN apt-get install python-software-properties -y

ENV ADDRESS=index.docker.io
ENV REPOSITORIES="library/alpine library/ubuntu library/centos library/nginx rcampbell/spinnaker-node-demo"

EXPOSE 8064
EXPOSE 8084
EXPOSE 9000

RUN mkdir -p /var/d120udemy/advanced-kubernetes-course

WORKDIR /var/udemy/advanced-kubernetes-course
ADD . /var/udemy/advanced-kubernetes-course

RUN curl -O  https://raw.githubusercontent.com/spinnaker/halyard/master/install/debian/InstallHalyard.sh
RUN adduser --disabled-password --gecos "" admin
RUN bash InstallHalyard.sh --user admin

ENTRYPOINT ["tail", "-f", "/dev/null"]