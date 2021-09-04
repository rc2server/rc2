#!/usr/bin/env bash

set -e

psql -U postgres <<-EOSQL
	CREATE USER rc2;
	CREATE DATABASE rc2 OWNER rc2;
	\c rc2
	DROP SCHEMA public;
	CREATE SCHEMA public AUTHORIZATION rc2;
	GRANT CREATE, USAGE ON SCHEMA public TO PUBLIC;
EOSQL
