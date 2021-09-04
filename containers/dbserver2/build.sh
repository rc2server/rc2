#!/usr/bin/env bash

SQL_PATH="../../rc2.sql"
VTAG=$1

if [[ -z $VTAG ]]; then
	read -e -p "version tag to use [default: latest]: " answer
	VTAG="${answer-latest}"
fi

if [[ ! -f $SQL_PATH ]]; then
	echo "Failed to find ${SQL_PATH}"
	exit 1
fi

cp $SQL_PATH init-scripts/rc2.pgsql

docker build -t rc2server/dbserver2:$VTAG .
