FROM library/ubuntu:bionic
LABEL org.opencontainers.image.authors="mark@lilback.com"

RUN apt-get update && apt-get install -y wget default-jre apt-transport-https

#add keys and repositories for postgres, R, and docker
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list \
	&& echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list \
	&& apt-get update

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

#install Rinside with our patch to enable callbacks
ADD rinside.patch /tmp/rinside.patch
RUN cd /tmp && \
	wget https://cran.r-project.org/src/contrib/RInside_0.2.13.tar.gz && \
	tar zxf RInside_0.2.13.tar.gz && \
	cd RInside && \
	patch -p1 < /tmp/rinside.patch && \
	R CMD INSTALL . && \
	cd /tmp && rm -rf rinside.patch RInside RInside*.tar.gz && \
	cd /usr/local/lib/R/site-library/RInside/libs && \
	ln -s RInside.so libRInside.so

RUN apt-get install -y docker-engine

COPY postgresql.conf pg_hba.conf /etc/postgresql/9.4/main/
COPY docker-default /etc/default/docker
COPY docker.conf /etc/systemd/system/docker.service.d/docker.conf

RUN locale-gen en_US.UTF-8

#keep it alive forever so we can use "docker exec -it container_name bash" to connect to it
CMD exec /bin/bash -c "trap : TERM INT; sleep infinity & wait"
