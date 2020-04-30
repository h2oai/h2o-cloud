#!/bin/bash -e

wget https://zlib.net/fossils/zlib-1.2.9.tar.gz
tar -xvf zlib-1.2.9.tar.gz
cd zlib-1.2.9
echo "Build zlib"
./configure; make; make install
echo "Create Link"
ln -s -f /usr/local/lib/libz.so.1.2.9 /opt/h2oai/dai/lib/libz.so.1