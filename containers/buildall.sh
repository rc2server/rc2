#!/bin/bash

cp ../rc2.sql dbserver/

docker rmi dbserver 2>/dev/null
(cd dbserver; docker build -t rc2/dbserver .)
(cd appserver; wget http://192.168.1.5/rc2drop.jar; docker build -t rc2/appserver .)
(cd compute; wget http://192.168.1.5/rc2compute.tar.gz ; docker build -t rc2/compute .)

echo "build complete"

