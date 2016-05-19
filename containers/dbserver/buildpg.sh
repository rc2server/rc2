#!/bin/bash

PGVersion=$1
TARGET=$2

if [ -z "$PGVersion" ]; then
	echo "postgres version not specified"
	exit 1
fi

PCONF="/etc/postgresql/${PGVersion}/main/postgresql.conf"

if ! [ -e "$PCONF" ]; then
	echo "$PCONF not found"
	exit 1
fi

echo "using version $PGVersion"

echo "listen_addresses='*'" >> "$PCONF"

service postgresql start
psql --command "CREATE USER rc2;"
createdb -O rc2 rc2

psql -U rc2 rc2 < /tmp/rc2.sql

if [ "test" = $TARGET ]; then
	echo "adding test data"
	psql -U rc2 rc2 < /tmp/testData.sql
fi

echo "#!/bin/bash" > /var/lib/postgresql/runpg.sh
echo "/usr/bin/pg_ctlcluster ${PGVersion} main start --foreground" >> /var/lib/postgresql/runpg.sh
chmod 755 /var/lib/postgresql/runpg.sh
