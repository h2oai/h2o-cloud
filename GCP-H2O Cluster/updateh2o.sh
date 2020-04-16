#!/bin/bash

# Update H2O
wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O /opt/h2oai/latest

LATEST_VERSION=`cat /opt/h2oai/latest`
INSTALLED_VERSION=`cat /opt/h2oai/installed`

echo $LATEST_VERSION
echo $INSTALLED_VERSION

# Check latest vs installed 
if [[ "$LATEST_VERSION" != "$INSTALLED_VERSION" ]]; then
    echo "Updating H2O"

    wget $LATEST_VERSION -O /opt/h2o-latest.zip
    rm /opt/h2o.jar
    rm -r /opt/h2o-3*

    unzip -d /opt /opt/h2o-latest.zip

    rm /opt/h2o-latest.zip
    cd /opt
    cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'`
    cp h2o.jar /opt

    R CMD INSTALL `find . -name "h2o*.tar.gz"`
    /usr/bin/pip3 install --upgrade --force-reinstall pip==9.0.3
    /usr/bin/pip3 install `find . -name "*.whl"`


else
    echo "Latest version already installed"
fi

mv /opt/h2oai/latest  /opt/h2oai/installed 