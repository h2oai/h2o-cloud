#!/bin/bash

h2oLog="/opt/h2oai/logs/init.log"
if [ ! -f $h2oLog ]; then
   #Put here your initialization sentences
        mkdir -p /opt/h2oai
        cd /opt/h2oai

        echo "Installing latest version of h2o" >>$h2oLog

        wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O /opt/h2oai/latest

        LATEST_VERSION=`cat /opt/h2oai/latest`
        INSTALLED_VERSION=`cat /opt/h2oai/installed`

        echo "Fetching latest build number for branch ${h2oBranch}..."
        wget $LATEST_VERSION -O /opt/h2o-latest.zip    
        wait        

        echo "Unzipping h2o.jar ..."
        unzip -d /opt /opt/h2o-latest.zip 1> /dev/null &
        wait

        echo "Copying h2o.jar within node ..."
        cd /opt
        cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'`
        cp h2o.jar /opt/h2oai/.
        wait
        
        echo "Installing H2O for R"       
        /usr/bin/R -e "IRkernel::installspec(user = FALSE)"  
        /usr/bin/R CMD INSTALL `find . -name "h2o*.tar.gz"`        

        echo "Installing H2O for Python..."        
        /usr/local/bin/pip install install `find . -name "*.whl"`
        /usr/local/bin/pip3 install `find . -name "*.whl"`
        

        echo "Success!! " >> $h2oLog

   #the next line creates an empty file so it won't run the next boot
   touch $h2oLog
else
   echo "Do nothing" >> $h2oLog
fi
