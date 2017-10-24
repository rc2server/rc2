FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

# base install
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.mirrors.hoobly.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update \
	&& apt-get install -y wget curl default-jre \
		supervisor python-software-properties software-properties-common postgresql-9.6 postgresql-client-9.6 \
		postgresql-contrib-9.6 libpq-dev clang libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev \
		alien build-essential xorg-dev libtiff5-dev libcairo2-dev libbz2-dev \
		libssl-dev gfortran libreadline-dev pandoc wget perl libgoogle-glog-dev \
	&& apt-get clean

# separate tex install
RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english && apt-get clean

# install R and packages
RUN apt-get install -y r-base-dev \
	&& mkdir -p /rc2compute/userlib \
	&& echo 'R_LIBS_USER=/rc2compute/userlib' >> /etc/R/Renviron.site \
	&& echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site \
	&& Rscript -e 'install.packages(c("knitr","rmarkdown","Rcpp","inline"), "/usr/local/lib/R/site-library")' && apt-get clean

ARG FORCE_DLOAD=0
RUN wget --max-redirect 4 -O - --quiet https://github.com/rc2server/compute/releases/latest |\
	egrep -o "/rc2server/compute/releases/download/v[0-9.]*/rc2compute.tar.gz" | \
	wget --quiet --base=https://github.com/ -i - -O /rc2compute.tar.gz && ls -l /rc2compute.tar.gz \
	&& tar zxf rc2compute.tar.gz && rm rc2compute.tar.gz && ls -l /rc2compute/

RUN (cd /rc2compute/RInside && R CMD INSTALL -l /usr/local/lib/R/site-library .) \
	&& (cd /rc2compute/rc2 && R CMD INSTALL -l /usr/local/lib/R/site-library .) \
	&& mkdir -p /usr/local/lib/R/library/RInside/libs/ && cd /usr/local/lib/R/library/RInside/libs/ && \
	ln -s /usr/local/lib/R/site-library/RInside/libs/RInside.so RInside.so

RUN mkdir /rc2 && wget --max-redirect 4 --quiet -O - https://swift.org/builds/swift-4.0-release/ubuntu1604/swift-4.0-RELEASE/swift-4.0-RELEASE-ubuntu16.04.tar.gz | tar --strip 1 -zx 
ENV LD_LIBRARY_PATH=/usr/lib/swift/linux

RUN mkdir -p /rc2/pgdata; chown -R postgres /rc2; chmod 700 /rc2 /rc2/pgdata
RUN locale-gen en_US.UTF-8
RUN pg_dropcluster 9.6 main
RUN pg_createcluster -d /rc2/pgdata --locale=en_US.UTF-8 9.6 main && rm -rf /rc2/pgdata/*

USER postgres
COPY pgconf/* /etc/postgresql/9.6/main/
COPY rc2.sql buildpg.sh /rc2/
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN /rc2/buildpg.sh

USER root

COPY appserver config.json /rc2/
ADD supervisord.conf /etc/
RUN mkdir /rc2/logs

EXPOSE 8088

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

LABEL io.rc2.type=combined
