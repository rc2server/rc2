#!/bin/bash

docker rm dev1; docker stop dev1
docker run -d --name dev1 -v /Users:/Users -v /var/run/docker.sock:/var/run/docker.sock rc2/dev

