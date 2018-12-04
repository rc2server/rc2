# Rc2

## overview/documentation of rc2 projects

Rc2 is a collaborative computing platform for using R. It encompasses the following projects:

| Repository | Purpose |
| --- | --- |
| rc2root | Top level project with documentation, docker containers, sql scripts |
| [rc2rest](https://github.com/wvuRc2/rc2rest) | Java app server |
| [rc2compute](https://github.com/wvuRc2/rc2compute) | linux/c++ server that manages R sessions |
| [rc2client](https://github.com/wvuRc2/rc2client) | The original Mac and iOS clients written at WVU |
| [rc2web](https://github.com/wvuRc2/rc2web) | Partially implemented HTML client using Aurelia |
| [rc2SwiftClient](https://github.com/mlilback/rc2SwiftClient) | New native client written in Swift |

documentation is in the [wiki](https://github.com/wvuRc2/rc2/wiki)

## creating a database

Once a database is created, the admin needs to execute `CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;`.

## SQL create/dump

To export updated schema, use `pg_dump -cOsx --if-exists --inserts -U rc2 rc2`. Test data is normally added manually. To dump the data for a table, use `pg_dump -U rc2 -t <tablename> -a rc2`.

## GKE todo

* change storage from 5gb to what fits in minimum charge
