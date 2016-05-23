FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

ADD jdk-8u92-linux-x64.tar.gz /usr/local
RUN	cd /usr/local && ln -s jdk1.8.0_92 java && mkdir /rc2

RUN update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/bin/java" 2000 \
	&& update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/bin/javac" 2000 \
	&& update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/bin/javaws" 2000

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 && \
	echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
	echo "deb http://cran.mirrors.hoobly.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/R.list && \
	apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 && \
	apt-get update

RUN apt-get update && \
	apt-get install -y alien build-essential xorg-dev \
		libtiff5-dev libcairo2-dev libbz2-dev libcurl4-openssl-dev \
		libssl-dev gfortran libreadline-dev pandoc
RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english

RUN apt-get install -y wget perl

RUN apt-get install -y r-base-dev

RUN echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site && \
	Rscript -e 'install.packages(c("knitr","rmarkdown","Rcpp"))'
	
RUN apt-get install -y postgresql-client-9.4 libgoogle-glog-dev

ADD rc2compute.tar.gz /

RUN cd /rc2compute/RInside && R CMD INSTALL .
RUN cd /rc2compute/rc2 && R CMD INSTALL .

RUN mkdir -p /usr/local/lib/R/library/RInside/libs/ && cd /usr/local/lib/R/library/RInside/libs/ && \
	ln -s /usr/local/lib/R/site-library/RInside/libs/RInside.so RInside.so

EXPOSE 7714

CMD ["/rc2compute/rserver"]




