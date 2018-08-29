FROM mysql:5.7

COPY ./.docker/my.cnf /etc/mysql/my.cnf
USER root
RUN chown -R mysql:mysql /var/lib/mysql
RUN chmod -R 777 /var/lib/mysql