# Building docker containers

## dbserver

cd to the containers/dbserver directory

`cp ../../*.sql .` These files are in .gitignore so you can leave them there.

To build a version with test data use `docker build --build-arg deploytype=test -t rc2/database:0.1 `. To build one for deployment, leave out the build-arg argument.

## appserver

cd to the containers/appserver directory.

cp the `build/libs/rc2drop-all-1.0-SNAPSHOT-all.jar` file from the rc2rest project to `rc2drop.jar`. Download the latest linux x64 jdk 8 tarball to `jdk-8.tar.gz'. 

Build with `docker build -t rc2/appserver:0.1 .`


# Running with Docker

1. Build both images

2. create a network: `docker network create --driver bridge rc2_nw`

3. start db container: `docker run -d -P -h rc2db --net=rc2_nw --name=dbserver  rc2/database:0.1`

4. start app container: `docker run -d -p 0.0.0.0:8088:8088 -h rc2app --net=rc2_nw --name=appserver  rc2/appserver:0.1`

5. should be able to connect with a client to port 8080 on the host system via http. Change the port mapping if necessary.
