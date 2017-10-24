#!/bin/bash

ROOT="/rc2"
PGDATA="/rc2/pgdata"

mkdir -p $PGDATA
/usr/lib/postgresql/9.6/bin/initdb -D $PGDATA
service postgresql start
psql --command "CREATE USER rc2; CREATE EXTENSION IF NOT EXISTS pgcrypto;"
createdb -O rc2 rc2
cd /usr/share/postgresql/9.6
echo "create extension pgcrypto" | psql  rc2
psql -U rc2 rc2 < /rc2/rc2.sql
echo "select rc2CreateUser('local', 'Local', 'Account', 'singlesignin@rc2.io', 'local');" | psql -U rc2 rc2
service postgresql stop
