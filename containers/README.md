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

2. from the containers directory, run `docker-compose up`. Type ctrl-c to stop the servers.
