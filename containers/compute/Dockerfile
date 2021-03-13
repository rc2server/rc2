FROM library/ubuntu:bionic-20210118
MAINTAINER Mark Lilback <mark@lilback.com>

COPY postgresKey.asc /tmp/

RUN apt-get update \
	&& apt-get install -y wget default-jre gnupg \
	&& apt-key add /tmp/postgresKey.asc \
	&& apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
	&& echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
	&& echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends curl vim \
		 software-properties-common software-properties-common postgresql-client-13 \
		libpq-dev clang libicu-dev libcurl4-openssl-dev libxml2 libminizip-dev \
		alien build-essential git libtiff5-dev libbz2-dev uuid-dev \
		libssl-dev libreadline-dev libgoogle-glog-dev \
	&& apt-get clean

RUN apt-get install -y --no-install-recommends xorg-dev libcairo2-dev pandoc perl gfortran

RUN apt-get install -y --no-install-recommends texlive texinfo texlive-fonts-extra texlive-lang-english

# R deepends on the tzdata package, which prompts for the user's location. The first stops this, but sets tz to UTC. 
ENV DEBIAN_FRONTEND=noninteractive 
#ENV TZ=America/New_York

RUN apt-get install -y r-base-dev \
	&& mkdir -p /rc2compute/userlib \
	&& echo 'R_LIBS_USER=/rc2compute/userlib' >> /etc/R/Renviron.site \
	&& echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /usr/lib/R/etc/Rprofile.site \
	&& Rscript -e 'install.packages(c("RSQLite", "knitr","rmarkdown","Rcpp","inline", "tidyverse", "evaluate"), "/usr/local/lib/R/site-library", quiet=TRUE, type="source")'

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

ADD start.sh /rc2compute/start.sh

RUN mkdir -p /cores && chmod 777 /cores

EXPOSE 7714

CMD ["/rc2compute/start.sh"]

LABEL io.rc2.type=compute
