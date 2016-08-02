# Dev build

This image is used for development of rc2compute. It creates a container fully ready to develop/debug. 

Build with `docker build -t rc2/dev .`

Checkout the rc2compute project on your host machine. The run via `docker run --privileged=true -it -v $PWD/rc2compute:/rc2compute rc2/dev bash`

With this setup, you can edit the project on your host machine.
