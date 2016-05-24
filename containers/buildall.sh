#!/bin/bash

function last_modified {
	ZZ=`docker inspect --format='{{.Created}}'  --type=image rc2/$1`
	LM=`date -d"$ZZ" +%s`
}

NOW=`date +%s`
declare -a imagenames=(dbserver appserver compute)


#rebuild and stop/rm any containers that were updated
for tag in "${imagenames[@]}"
do
	
(cd $tag; docker build --build-arg deploytype=test -t rc2/$tag .)
last_modified $tag
if [ $LM -gt $NOW ] && [ docker ps |grep "$tag$" > /dev/null ]; then
	echo "removing $tag";
	docker stop $tag >/dev/null;
	docker rm $tag >/dev/null;
fi
done

#restart/run containers
for tag in "${imagenames[@]}"
do
	if docker ps | grep "$tag\$" > /dev/null ; then
		echo "restart $tag";
		docker stop $tag >/dev/null;
		docker start $tag >/dev/null;
	elif docker ps --all --filter name=$tag | grep "$tag\$" > /dev/null ; then
		echo "start $tag";
		docker start $tag >/dev/null;
	else
		echo "run $tag";
		if [ $tag = "dbserver" ]; then
			docker run -d -P -h rc2db --net=rc2_nw --name=dbserver  rc2/dbserver;
		elif [ $tag = "appserver" ]; then
			docker run -d -p 0.0.0.0:8088:8088 -h rc2app --net=rc2_nw --name=appserver  rc2/appserver
		else
			docker run -d -p 0.0.0.0:7714:7714 -h rc2compute --net=rc2_nw --name=compute rc2/compute
		fi
	fi
done

