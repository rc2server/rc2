FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

RUN apt-get update && apt-get install -y wget default-jre 

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.mirrors.hoobly.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update

#libgoogle-glog-dev

RUN apt-get install -y alien build-essential xorg-dev cmake git gdb
RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english && apt-get clean
RUN apt-get install -y gfortran perl pandoc vim

RUN apt-get install -y python-software-properties postgresql-9.4 postgresql-contrib-9.4 postgresql-client-9.4 libpq-dev 

RUN apt-get install -y libboost-all.dev uuid-dev libevent-dev libevent-pthreads-2.0.5 libgtest-dev
RUN apt-get install -y libtiff5-dev libcairo2-dev libbz2-dev libcurl4-openssl-dev libssl-dev libreadline-dev 

RUN apt-get install -y r-base-dev \
	&& echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site \
	&& Rscript -e 'install.packages(c("knitr","rmarkdown","Rcpp"))' && apt-get clean

RUN cd /usr/src/gtest && cmake . && make -j4 && cp libgtest.a /usr/lib/ && cp libgtest_main.a /usr/lib/ && make clean

ADD rinside.patch /tmp/rinside.patch
RUN cd /tmp && \
	wget https://cran.r-project.org/src/contrib/RInside_0.2.13.tar.gz && \
	tar zxf RInside_0.2.13.tar.gz && \
	cd RInside && \
	patch -p1 < /tmp/rinside.patch && \
	R CMD INSTALL . && \
	cd /tmp && rm -rf rinside.patch RInside RInside*.tar.gz

RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.4/main/pg_hba.conf && \
	echo "listen_addresses='*'" >> /etc/postgresql/9.4/main/postgresql.conf
