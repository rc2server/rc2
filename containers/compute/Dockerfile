FROM library/ubuntu:bionic
MAINTAINER Mark Lilback <mark@lilback.com>

RUN apt-get update && apt-get install -y wget default-jre gnupg

# base install
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 E298A3A825C0D65DFD57CBB651716619E084DAB9 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9 \
	&& apt-get update \
	&& apt-get install -y curl vim \
		 software-properties-common software-properties-common postgresql-client-9.6 \
		libpq-dev clang libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev \
		alien build-essential git libtiff5-dev libbz2-dev uuid-dev \
		libssl-dev libreadline-dev libgoogle-glog-dev 
#	&& apt-get clean

RUN mkdir /rc2 && wget --max-redirect 4 --quiet -O - https://swift.org/builds/swift-5.0.3-release/ubuntu1804/swift-5.0.3-RELEASE/swift-5.0.3-RELEASE-ubuntu18.04.tar.gz | tar --strip 1 -zx 
ENV LD_LIBRARY_PATH=/usr/lib/swift/linux

RUN apt-get install -y xorg-dev libcairo2-dev pandoc perl gfortran

RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english

# R deepends on the tzdata package, which prompts for the user's location. The first stops this, but sets tz to UTC. 
ENV DEBIAN_FRONTEND=noninteractive 
#ENV TZ=America/New_York

RUN apt-get install -y r-base-dev \
	&& mkdir -p /rc2compute/userlib \
	&& echo 'R_LIBS_USER=/rc2compute/userlib' >> /etc/R/Renviron.site \
	&& echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site \
	&& Rscript -e 'install.packages(c("knitr","rmarkdown","Rcpp","inline"), "/usr/local/lib/R/site-library")'

ARG FORCE_DLOAD=0
#RUN wget --max-redirect 4 -O - --quiet https://github.com/rc2server/compute/releases/latest |\
#	egrep -o "/rc2server/compute/releases/download/v[0-9.]*/rc2compute.tar.gz" | \
#	wget --quiet --base=https://github.com/ -i - -O /rc2compute.tar.gz && ls -l /rc2compute.tar.gz \
#	&& tar zxf rc2compute.tar.gz && rm rc2compute.tar.gz && ls -l /rc2compute/
COPY rc2compute.tar.gz /
RUN tar zxf rc2compute.tar.gz && rm rc2compute.tar.gz && ls -l /rc2compute/

RUN (cd /rc2compute/RInside && R CMD INSTALL -l /usr/local/lib/R/site-library .) \
	&& (cd /rc2compute/rc2 && R CMD INSTALL -l /usr/local/lib/R/site-library .) \
	&& mkdir -p /usr/local/lib/R/library/RInside/libs/ && cd /usr/local/lib/R/library/RInside/libs/ && \
	ln -s /usr/local/lib/R/site-library/RInside/libs/RInside.so RInside.so

EXPOSE 7714

CMD ["/rc2compute/rserver"]

LABEL io.rc2.type=compute
