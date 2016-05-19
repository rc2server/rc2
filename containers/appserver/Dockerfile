FROM library/ubuntu:xenial
MAINTAINER Mark Lilback <mark@lilback.com>

ADD jdk-8u92-linux-x64.tar.gz /usr/local
RUN	cd /usr/local && ln -s jdk1.8.0_92 java && mkdir /rc2
ADD rc2drop.jar *.yml /rc2/

RUN update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/bin/java" 2000 \
	&& update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/bin/javac" 2000 \
	&& update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/bin/javaws" 2000

EXPOSE 8080

CMD ["/usr/bin/java", "-jar", "/rc2/rc2drop.jar", "server", "/rc2/docker.yml"]

	


