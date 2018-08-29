FROM java:8-jdk

ENV APP_HOME /var/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME/

EXPOSE 8085

#ENTRYPOINT ["tail -f /dev/null"]