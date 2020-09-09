FROM java:8-jdk

#RUN apt-get update && apt-get install -y build-essential docker.io

RUN apt-get update
RUN apt-get install -y apt-transport-https ca-certificates curl software-properties-common
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable"
RUN apt-get update && apt-get install -y docker-ce=$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')

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