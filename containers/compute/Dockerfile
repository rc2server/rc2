FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

RUN apt-get update && apt-get install -y wget default-jre 

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.mirrors.hoobly.com/bin/linux/ubuntu xenial/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update \
	&& apt-get install -y alien build-essential xorg-dev libtiff5-dev libcairo2-dev libbz2-dev libcurl4-openssl-dev \
		libssl-dev gfortran libreadline-dev pandoc wget perl postgresql-client-9.4 libgoogle-glog-dev \
	&& apt-get clean

RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english && apt-get clean

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

EXPOSE 7714

CMD ["/rc2compute/rserver"]

LABEL io.rc2.type=compute
