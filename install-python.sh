#!/bin/sh

set -x
set -e

curl -O http://python.org/ftp/python/2.7.3/Python-2.7.3.tgz
tar xzf Python-2.7.3.tgz
pushd Python-2.7.3
cat >setup.cfg <<EOF
[build_ext]
library_dirs=/usr/lib/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/
EOF
./configure --prefix=$PWD/install
make
make install
virtualenv -p install/bin/python2.7 --distribute rubythumbor
popd

