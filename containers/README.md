<style type="css">
p > code { text-indent: -12px; padding-left: 12px; }
</style>
# Building docker containers

## dbserver

cd to the containers/dbserver directory

`cp ../../*.sql .` These files are in .gitignore so you can leave them there. This is required because Dockerfiles can't have relative paths with ".." in them.

Build with

```docker build -t rc2server/database:{version} -t rc2server/database:latest .``` 

## appserver

cd to the containers/appserver directory.

A compiled version of appserver needs to be added to this directory.

Build with `

``docker build -t rc2server/appserver:${version} -t rc2server/appserver:latest .```


## compute

cd to the containers/compute directory.

A generated version of rc2compute.tar.gz needs to be in this directory.

Build with 

```docker build -t rc2server/compute:{version} -t rc2server/compute:latest .```

