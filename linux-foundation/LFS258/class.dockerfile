FROM ubuntu:latest

RUN mkdir -p /var/work

WORKDIR /var/work
ADD . /var/work

ENTRYPOINT ["tail", "-f", "/dev/null"]
