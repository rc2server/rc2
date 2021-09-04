FROM postgres:13
LABEL org.opencontainers.image.authors="mark@lilback.com"

RUN localedef -f UTF-8 -i en_US en_US.UTF-8

ENV POSTGRES_PASSWORD foobar
ENV POSTGRES_HOST_AUTH_METHOD=trust

COPY init-scripts/* /docker-entrypoint-initdb.d/

VOLUME /var/lib/postgresql/data
