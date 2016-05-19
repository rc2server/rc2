FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

ARG pgversion=9.4

RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y python-software-properties software-properties-common postgresql-${pgversion} postgresql-client-${pgversion} postgresql-contrib-${pgversion}

USER postgres
COPY pg_hba.conf /etc/postgresql/${pgversion}/main/pg_hba.conf
COPY rc2.sql /tmp/rc2.sql
COPY testData.sql /tmp/testData.sql
COPY buildpg.sh /tmp/buildpg.sh

ARG deploytype="deploy"
RUN /tmp/buildpg.sh $pgversion $deploytype

EXPOSE 5432

CMD ["var/lib/postgresql/runpg.sh"]
