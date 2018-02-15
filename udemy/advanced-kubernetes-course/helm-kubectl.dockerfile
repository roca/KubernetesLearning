FROM dtzar/helm-kubectl

RUN mkdir -p /var/d120udemy/advanced-kubernetes-course
WORKDIR /var/udemy/advanced-kubernetes-course
ADD . /var/udemy/advanced-kubernetes-course


EXPOSE 9000
ENTRYPOINT ["tail", "-f", "/dev/null"]