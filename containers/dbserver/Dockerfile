FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

ARG pgversion=9.4

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-${pgversion} postgresql-client-${pgversion} postgresql-contrib-${pgversion} libpq-dev
RUN mkdir -p /rc2/pgdata; chown -R postgres /rc2; chmod 700 /rc2 /rc2/pgdata
RUN locale-gen en_US.UTF-8
RUN pg_dropcluster ${pgversion} main
RUN pg_createcluster -d /rc2/pgdata --locale=en_US.UTF-8 ${pgversion} main && rm -rf /rc2/pgdata/*
#RUN mkdir -p /rc2 && chown postgres:postgres /rc2

USER postgres
COPY *.conf /etc/postgresql/${pgversion}/main/
COPY rc2.sql /tmp/rc2.sql
COPY runpg.sh /var/lib/postgresql/runpg.sh
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
#RUN /var/lib/postgresql/runpg.sh -V ${pgversion} -c
EXPOSE 5432

#VOLUME ["/rc2/pgdata"]
CMD ["var/lib/postgresql/runpg.sh", "-V", "9.4"]

LABEL io.rc2.type=dbserver
