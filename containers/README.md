# Building docker containers

## dbserver

cd to the containers/dbserver directory

`cp ../../*.sql .` These files are in .gitignore so you can leave them there. This is required because Dockerfiles can't have relative paths with ".." in them.

To build a version with test data use `docker build -t rc2/database .`. 

## appserver

cd to the containers/appserver directory.

Build with `docker build -t rc2/appserver .`

If you need to force it to refresh the jar from github, use `docker build --build-arg FORCE_DLOAD=1 -t rc2/appserver .`

to build appserver, run appserver image and then:

```
mkdir rc2
cd rc2
git clone https://github.com/rc2server/appServerSwift appserver
git clone https://github.com/rc2server/appModelSwift appmodel
git clone https://github.com/mlilback/Freddy.git
git clone https://github.com/mlilback/MJLLogger.git
cd appserver
swift package edit Rc2Model --path ../appmodel
swift package edit MJLLogger --path ../MJLLogger/
swift package edit Freddy --path ../Freddy/
swift package edit BlueSignals
(cd Packages/BlueSignals; git pull origin master; git checkout HEAD)
swift build
```

for  now, you have to `find . -name libpq-fe.h` and edit that file so that both include statements are prefixed with `postgresql/`. I'll make a fork to fix that later.

## compute

cd to the containers/compute directory.

Build with `docker build -t rc2/compute .`

If you need to force it to refresh the compute tarball from github, use `docker build --build-arg FORCE_DLOAD=1 -t rc2/compute .`

# Running with Docker

All must be tagged with appropriate version information that is matched in the imageInfo.json file referenced by the client application.
