FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

RUN apt-get update && apt-get install -y wget default-jre 
ARG FORCE_DLOAD=0
RUN mkdir /rc2 && wget --max-redirect 4 -O - --quiet https://github.com/rc2server/appserver/releases/latest | egrep -o "/rc2server/appserver/releases/download/v[0-9.]*/rc2drop.jar" | wget --quiet --base=https://github.com/ -i - -O /rc2/rc2drop.jar && ls -l /rc2/rc2drop.jar
ADD *.yml /rc2/

EXPOSE 8080

CMD ["/usr/bin/java", "-jar", "/rc2/rc2drop.jar", "server", "/rc2/docker.yml"]

LABEL io.rc2.type=appserver
