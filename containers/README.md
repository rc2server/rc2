<style type="css">
p > code { text-indent: -12px; padding-left: 12px; }
</style>
# Building docker containers

## Workflow:


### `dbserver`
Enter the `../rc2/containers/dbserver` directory.  A dependency from a parent directory needs to be copied.
```
    cd /<your-path>/rc2/containers/dbserver
    cp ../../*.sql .
```

`testData.sql` and `rc2.sql` are in `.gitignore` so you can leave them there. This is required because Dockerfiles can't have relative paths with `..` in them.

Build with:

<!-- ```docker build -t rc2server/database:${version} -t rc2server/database:latest .``` -->
```docker build --tag rc2server/database:latest .``` 

## `appserver`
Change to the `../rc2/containers/appserver` directory.
```
    cd /<your-path>/rc2/containers/appserver
```
A compiled version of appserver needs to be added to this directory.

Build with:

<!-- ```docker build -t rc2server/appserver:${version} -t rc2server/appserver:latest .``` -->

```docker build --tag rc2server/appserver:latest .```

## `compute`

Change to the `../rc2/containers/compute` directory.
```
    cd /<your-path>/rc2/containers/compute
```

A generated version of `rc2compute.tar.gz`, compiled and packaged in the [`rc2server/compute`](https://github.com/rc2server/compute) project  , needs to be in this directory.

Build with:

<!-- ```docker build -t rc2server/compute:${version} -t rc2server/compute:latest .``` -->


```docker build --tag rc2server/compute:latest .```

