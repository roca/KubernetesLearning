FROM gcr.io/spinnaker-marketplace/halyard:stable


ENV ADDRESS=index.docker.io
ENV REPOSITORIES="library/alpine library/ubuntu library/centos library/nginx rcampbell/spinnaker-node-demo"

RUN mkdir -p /var/d120udemy/advanced-kubernetes-course
WORKDIR /var/udemy/advanced-kubernetes-course
ADD . /var/udemy/advanced-kubernetes-course

EXPOSE 8064
EXPOSE 8084
EXPOSE 9000

ENTRYPOINT ["tail", "-f", "/dev/null"]