FROM java:8-jdk

RUN apt-get update && apt-get install -y build-essential

RUN wget http://sourceforge.net/projects/netcat/files/netcat/0.7.1/netcat-0.7.1.tar.gz \
&& tar -xzvf netcat-0.7.1.tar.gz \
&& cd ./netcat-0.7.1 \
&& chmod +x ./configure \
&& ./configure \
&& make \
&& make install

ENV APP_HOME /var/app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD . $APP_HOME/

EXPOSE 80
EXPOSE 443
EXPOSE 54663
EXPOSE 54667

#ENTRYPOINT ["tail -f /dev/null"]