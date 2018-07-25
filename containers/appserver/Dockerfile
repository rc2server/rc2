FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

# base install
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.mirrors.hoobly.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update \
	&& apt-get install -y wget curl vim \
		 python-software-properties software-properties-common postgresql-client-9.6 \
		libpq-dev clang libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev \
		alien build-essential git libtiff5-dev libbz2-dev uuid-dev \
		libssl-dev libreadline-dev libgoogle-glog-dev \
	&& apt-get clean
# removed supervisor postgresql-9.6 postgresql-contrib-9.6  xorg-dev gfortran pandoc libcairo2-dev default-jre perl

RUN mkdir /rc2 && wget --max-redirect 4 --quiet -O - https://swift.org/builds/swift-4.2-branch/ubuntu1604/swift-4.2-DEVELOPMENT-SNAPSHOT-2018-05-31-a/swift-4.2-DEVELOPMENT-SNAPSHOT-2018-05-31-a-ubuntu16.04.tar.gz | tar --strip 1 -zx 
ENV LD_LIBRARY_PATH=/usr/lib/swift/linux

#RUN locale-gen en_US.UTF-8

USER root

COPY appserver config.json /rc2/
RUN mkdir /rc2/logs
RUN git clone https://github.com/rc2server/rc2 /rc2/rc2root

EXPOSE 8088

CMD ["/rc2/appserver", "-D", "/rc2"]

LABEL io.rc2.type=appserver
