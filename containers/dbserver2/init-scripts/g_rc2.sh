#!/usr/bin/env bash

set -e

psql -U rc2 rc2 <<-EOSQL
	CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
	CREATE EXTENSION IF NOT EXISTS ltree WITH SCHEMA public;
EOSQL

psql -U rc2 rc2 < /docker-entrypoint-initdb.d/rc2.pgsql
