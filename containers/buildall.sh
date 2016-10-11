#!/bin/bash

IMGVERSION=0.4
REPO=rc2server
saveImages=''

while getops 's' flag; do
	case "${flag}" in
		s) saveImages='true';;
	esac
done

cp ../rc2.sql dbserver/

docker rmi dbserver 2>/dev/null
(cd dbserver; docker build -t ${REPO}/dbserver:${IMGVERSION} .)
(cd appserver; wget -O rc2drop.jar http://192.168.1.5/rc2drop.jar; docker build -t ${REPO}/appserver:${IMGVERSION} .)
(cd compute; wget -O rc2compute.tar.gz http://192.168.1.5/rc2compute.tar.gz ; docker build -t ${REPO}/compute:${IMGVERSION} .)

echo "build complete"

if [ saveImages -eq 'true' ]; then
#	docker save rc2/dbserver:${IMGVERSION}
fi
