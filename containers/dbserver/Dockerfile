FROM ubuntu:bionic

LABEL maintainer="Mark Lilback <mark@lilback.com>"
LABEL io.rc2.type=dbserver

ARG DEBIAN_FRONTEND=noninteractive
ARG pgversion=11

ENV pgversion=${pgversion}
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN apt-get update && apt-get install -y gnupg \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8 E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/pgdg.list  \
    && echo "deb http://cran.rstudio.com/bin/linux/ubuntu bionic-cran35/" > /etc/apt/sources.list.d/R.list \
    && apt-get update \
    && apt-get install -y \
        software-properties-common \
        postgresql-${pgversion} \
        postgresql-client-${pgversion} \
        postgresql-contrib-${pgversion} \
        libpq-dev \
    && mkdir -p /rc2/pgdata; chown -R postgres /rc2; chmod 700 /rc2 /rc2/pgdata \
    && locale-gen en_US.UTF-8 \
    && pg_dropcluster ${pgversion} main \
    && pg_createcluster -d /rc2/pgdata --locale=en_US.UTF-8 ${pgversion} main && rm -rf /rc2/pgdata/* \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY *.conf /etc/postgresql/${pgversion}/main/
COPY rc2.sql /rc2/rc2.sql
COPY runpg.sh /var/lib/postgresql/runpg.sh

USER postgres

RUN sed -i "s/!!PGVERSION!!/${pgversion}/" /etc/postgresql/${pgversion}/main/postgresql.conf && \
    /var/lib/postgresql/runpg.sh -V ${pgversion} -c

EXPOSE 5432

CMD ["var/lib/postgresql/runpg.sh", "-V", "11"]



#### Image Details
# Dev image Size:   448  MB
# Ubuntu:Bionic:    63.3 MB
# Phase1 reduction reduced the image size to 405 MB.  Committed.
# Phase2 addition of  apt-get clean && rm -rf /var/lib/apt/lists/* reduced
#   the image size to 369 MB.
# Question:  Does the last run statement need to be run? Could entrypoint be used?
# QuickAnswer: I don't think it is necessary here.