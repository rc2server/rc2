FROM ubuntu:bionic
MAINTAINER Mark Lilback <mark@lilback.com>

LABEL maintainer="Mark Lilback <mark@lilback.com>"
LABEL io.rc2.type=compute

ARG DEBIAN_FRONTEND=noninteractive
ARG FORCE_DLOAD=0
ARG pgversion=9.6
ARG swiftversion=5.1
ARG ubuntuversion=18.04

ENV LD_LIBRARY_PATH=/usr/lib/swift/linux
ENV pgversion=${pgversion}
ENV swiftversion=${swiftversion}

ADD rc2compute.tar.gz /

# base install
RUN apt-get update && apt-get install -y wget software-properties-common curl wget vim && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 E298A3A825C0D65DFD57CBB651716619E084DAB9 && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list  && \
    echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list && \
	apt-get update && \
	apt-get install -y postgresql-client-${pgversion} libpq-dev clang \
	    libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev alien build-essential git \
	    libtiff5-dev libbz2-dev uuid-dev default-jre libssl-dev libreadline-dev libgoogle-glog-dev \
	    xorg-dev libcairo2-dev pandoc perl gfortran && \
	apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra && \
    mkdir /rc2 && \
    wget --max-redirect 4 --quiet -O - https://swift.org/builds/swift-${swiftversion}-release/ubuntu1804/swift-${swiftversion}-RELEASE/swift-${swiftversion}-RELEASE-ubuntu${ubuntuversion}.tar.gz | tar --strip 1 -zx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y r-base-dev && \
	mkdir -p /rc2compute/userlib && \
	echo 'R_LIBS_USER=/rc2compute/userlib' >> /etc/R/Renviron.site && \
	echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site && \
	Rscript -e 'install.packages(c("RSQLite", "knitr","rmarkdown","Rcpp","inline", "tidyverse", "evaluate"), "/usr/local/lib/R/site-library", quiet=TRUE, type="source")' && \
    (cd /rc2compute/RInside && R CMD INSTALL -l /usr/local/lib/R/site-library .) && \
	(cd /rc2compute/rc2 && R CMD INSTALL -l /usr/local/lib/R/site-library .) && \
	mkdir -p /usr/local/lib/R/library/RInside/libs/ && cd /usr/local/lib/R/library/RInside/libs/ && \
	ln -s /usr/local/lib/R/site-library/RInside/libs/RInside.so RInside.so && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

EXPOSE 7714

CMD ["/rc2compute/rserver"]


# R deepends on the tzdata package, which prompts for the user's location. The first stops this, but sets tz to UTC.
#ENV TZ=America/New_York
#RUN wget --max-redirect 4 -O - --quiet https://github.com/rc2server/compute/releases/latest |\
#	egrep -o "/rc2server/compute/releases/download/v[0-9.]*/rc2compute.tar.gz" | \
#	wget --quiet --base=https://github.com/ -i - -O /rc2compute.tar.gz && ls -l /rc2compute.tar.gz \
#	&& tar zxf rc2compute.tar.gz && rm rc2compute.tar.gz && ls -l /rc2compute/


#### Image Details
# Dev image Size:   4.1  GB
# Phase1 reduction did not reduce the image size.  Something made it larger 4.24 GB.
# Still large.  Must have been changing default-jre to default-jdk.
