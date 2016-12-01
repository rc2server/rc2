This is the code used to build imageInfo.json, which provides the client app with information on what docker images are needed to operate.

It requires the following CPAN modules:

* Date::Format
* Getopt::Long
* Digest::SHA
* LWP::Simple
* LWP::Protocol::http::SocketUnixAlt
* Cpanel::JSON::XS

Image versions are supplied as command line options, `parser.pl -d 0.4.3 -a 0.4.3 -c 0.4.2.

The generated array contains a version string (serialized date) and an array of images. Each image contains:

* `id`: the Id used by docker
* `name`: the container type (dbserver, appserver, compute)
* `version`: the version string (0.4.3)
* `tag`: the full tag for this image (rc2server/appserver:0.4.3)
* `size`: size in bytes of the image
* `estSize`: the size that needs to be downloaded (removes duplicate layers from other images)

