FROM library/ubuntu:bionic
MAINTAINER Mark Lilback <mark@lilback.com>

RUN apt-get update && apt-get install -y wget default-jre gnupg

# base install
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 E298A3A825C0D65DFD57CBB651716619E084DAB9 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update \
	&& apt-get install -y curl wget vim \
		software-properties-common postgresql-client-9.6 \
		libpq-dev clang libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev \
		alien build-essential git libtiff5-dev libbz2-dev uuid-dev \
		libssl-dev libreadline-dev libgoogle-glog-dev \
	&& apt-get clean

RUN mkdir /rc2 && wget --max-redirect 4 --quiet -O - https://swift.org/builds/swift-5.0.3-release/ubuntu1804/swift-5.0.3-RELEASE/swift-5.0.3-RELEASE-ubuntu18.04.tar.gz | tar --strip 1 -zx 
ENV LD_LIBRARY_PATH=/usr/lib/swift/linux

#RUN locale-gen en_US.UTF-8

# to blow the cache for all following lines, use --build-arg xdate=$(date +%s)
ARG xdate="43"

USER root

COPY appserver config.json /rc2/
RUN mkdir /rc2/logs
RUN git clone https://github.com/rc2server/rc2 /rc2/rc2root

EXPOSE 8088

CMD ["/rc2/appserver", "-D", "/rc2"]

LABEL io.rc2.type=appserver
