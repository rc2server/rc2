#!/bin/bash

CREATEONLY=0
OPTIND=1
while getopts "V:c" opt; do
	case "$opt" in
		c)
			CREATEONLY=1
			;;
		V)
			PGVersion=$OPTARG
			;;
	esac
done
shift "$((OPTIND-1))" #shift off the args that were parsed

#PGVersion=$1

if [ -z "$PGVersion" ]; then
	echo "postgres version not specified"
	exit 1
fi

ROOT="/rc2"
PGDATA="/rc2/pgdata"

#eventually we'll need to check schema version number via metadata table
if ! [ -e "$ROOT/rc2.inited" ]; then
	echo "rc2.inited does not exist. creating database"
	mkdir -p $PGDATA
	touch /rc2/rc2.inited
	/usr/lib/postgresql/9.4/bin/initdb -D $PGDATA
	service postgresql start
	psql --command "CREATE USER rc2; CREATE EXTENSION IF NOT EXISTS pgcrypto;"
	createdb -O rc2 rc2
#	cd `pg_config --sharedir`
	cd /usr/share/postgresql/9.4
	echo "create extension pgcrypto" | psql  rc2
	psql -U rc2 rc2 < /tmp/rc2.sql
	echo "select rc2CreateUser('local', 'Local', 'Account', 'singlesignin@rc2.io', 'local');" | psql -U rc2 rc2
	service postgresql stop
else
	echo "$PGDATA/base exists"
fi

if [ "$CREATEONLY" -eq "0" ]; then 
	exec /usr/bin/pg_ctlcluster ${PGVersion} main start --foreground
fi

