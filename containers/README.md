# Building docker containers

## dbserver

cd to the containers/dbserver directory

`cp ../../*.sql .` These files are in .gitignore so you can leave them there.

To build a version with test data use `docker build -t rc2/database .`. 

## appserver

cd to the containers/appserver directory.

cp the `build/libs/rc2drop-all-1.0-SNAPSHOT-all.jar` file from the rc2rest project to `rc2drop.jar`. Download jdk-8u92-linux-x64.tar.gz from oracle. 

Build with `docker build -t rc2/appserver .`

## compute

cd to the containers/compute directory.

Download jdk-8u92-linux-x64.tar.gz from oracle. cp the rc2compute.tar.gz file created by the rc2compute project. 

Build with `docker build -t rc2/compute .`

# Running with Docker

1. Build all three images

2. create a network: `docker network create --driver bridge rc2_nw`

3. start db container: `docker run -d -P -h rc2db --net=rc2_nw --name=dbserver  rc2/database:0.1`

4. start app container: `docker run -d -p 0.0.0.0:8088:8088 -h rc2app --net=rc2_nw --name=appserver  rc2/appserver:0.1`

5. start the compute container: `docker run -d -p 0.0.0.0:7714:7714 -h rc2compute --net=rc2_nw --name=compute rc2/compute`

6. should be able to connect with a client to port 8080 on the host system via http. Change the port mapping if necessary.
