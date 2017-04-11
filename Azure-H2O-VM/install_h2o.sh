#!/bin/bash


h2oLog="/etc/h2o/init.log"
if [ ! -f $h2oLog ]; then
   #Put here your initialization sentences
        mkdir -p /etc/h2o
        cd /etc/h2o

        echo "Installing latest version of h2o" >>$h2oLog

        # Adjust based on the build of H2O you want to download.
        h2oBranch=rel-turing

        echo "Fetching latest build number for branch ${h2oBranch}..."
        curl --silent -o latest https://h2o-release.s3.amazonaws.com/h2o/${h2oBranch}/latest
        h2oBuild=`cat latest`
        wait

        echo "Fetching full version number for build ${h2oBuild}..."
        curl --silent -o project_version https://h2o-release.s3.amazonaws.com/h2o/${h2oBranch}/${h2oBuild}/project_version
        h2oVersion=`cat project_version`
        wait

        echo "Downloading H2O version ${h2oVersion} ..."
        curl --silent -o h2o-${h2oVersion}.zip https://s3.amazonaws.com/h2o-release/h2o/${h2oBranch}/${h2oBuild}/h2o-${h2oVersion}.zip &
        wait

        echo "Unzipping h2o.jar ..."
        unzip -o h2o-${h2oVersion}.zip 1> /dev/null &
        wait

        echo "Copying h2o.jar within node ..."
        cp -f h2o-${h2oVersion}/h2o.jar . &
        wait
        
        echo "Installing H2O for R"
        R --slave -e "IRkernel::installspec(user = FALSE)" >> $h2oLog
        R --slave -e 'install.packages("h2o", type="source", repos=(c("https://s3.amazonaws.com/h2o-release/h2o/'${h2oBranch}'/'${h2oBuild}'/R")))'



        echo "Installing H2O for Python..."        
        /opt/anaconda3/bin/pip install https://s3.amazonaws.com/h2o-release/h2o/${h2oBranch}/${h2oBuild}/Python/h2o-${h2oVersion}-py2.py3-none-any.whl


        echo "Installing H2O for Python 2.7..."
        /opt/anaconda3/envs/py27/bin/pip install https://s3.amazonaws.com/h2o-release/h2o/${h2oBranch}/${h2oBuild}/Python/h2o-${h2oVersion}-py2.py3-none-any.whl


        echo "Success!! " >> $h2oLog

   #the next line creates an empty file so it won't run the next boot
   touch $h2oLog
else
   echo "Do nothing" >> $h2oLog
fi
