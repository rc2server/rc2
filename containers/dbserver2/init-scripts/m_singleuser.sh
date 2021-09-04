#!/usr/bin/env bash

set -e

psql -U rc2 rc2 <<-EOSQL
	select rc2CreateUser('local', 'Local', 'Account', 'singlesignin@rc2.io', 'local');
EOSQL
