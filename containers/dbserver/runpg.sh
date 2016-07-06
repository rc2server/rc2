#!/bin/bash

PGVersion=$1

if [ -z "$PGVersion" ]; then
	echo "postgres version not specified"
	exit 1
fi

PGDATA="/rc2/pgdata"

#eventually we'll need to check schema version number via metadata table
if ! [ -e "$PGDATA/pgdata" ]; then
#	mkdir -p $PGDATA
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
fi


/usr/bin/pg_ctlcluster ${PGVersion} main start --foreground
