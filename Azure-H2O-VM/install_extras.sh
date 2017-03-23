#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e
u="$SUDO_USER"

echo "Changing to tools folder ..."
cd /dsvm/tools/
wait 

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

echo "Creating Flatfile with info of all Vms in cluster .."
flatfileName=flatfile.txt
rm -f ${flatfileName}
i=0
for i in $(seq 4 $((4+$1-1)))
do
    privateIp="10.0.0.$i"
    echo "${privateIp}:54321" >> ${flatfileName}
done

echo "Installing H2O for R"
R --slave -e 'install.packages("statmod")'
wait
R --slave -e 'install.packages("h2o", type="source", repos=(c("https://s3.amazonaws.com/h2o-release/h2o/'${h2oBranch}'/'${h2oBuild}'/R")))'

echo "Setting up the right softlinks for pip 2.7 and pip3 for 3.5..."
ln -s /anaconda/bin/pip /usr/bin/pip #for python 2.7
ln -s /anaconda/envs/py35/bin/pip /usr/bin/pip3 #for python 3.5

echo "Installing H2O for Python..."
pip install https://s3.amazonaws.com/h2o-release/h2o/${h2oBranch}/${h2oBuild}/Python/h2o-${h2oVersion}-py2.py3-none-any.whl
pip3 install https://s3.amazonaws.com/h2o-release/h2o/${h2oBranch}/${h2oBuild}/Python/h2o-${h2oVersion}-py2.py3-none-any.whl


echo "Downloading cool notebooks.."
cd /home/$2/notebooks
curl --silent -o H2O_pydemo_tutorial_breast_cancer_classification.ipynb "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-py/demos/H2O_tutorial_breast_cancer_classification.ipynb"
curl --silent -o H2O_rdemo_tutorial_eeg_eyestate.ipynb "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-r/demos/rdemo.tutorial.eeg.eyestate.ipynb"
curl --silent -o H2O_pydemo_tutorial_eeg_eyestate.ipynb  "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-py/demos/H2O_tutorial_eeg_eyestate.ipynb"

echo "Install RStudio" 
wget https://download2.rstudio.org/rstudio-server-rhel-1.0.44-x86_64.rpm
yum install -y --nogpgcheck rstudio-server-rhel-1.0.44-x86_64.rpm


echo "Remove unsopported apps "
# XGBOOST
pip install --upgrade xgboost
pip uninstall xgboost -y
pip3 uninstall xgboost -y
#PostgresSQL 
yum remove postgres\* -y
# R XGBOOST
R -e "remove.packages(\"xgboost\")"

# Remove notebooks

rm -rf /home/$2/notebooks/DocumentDBSample.ipynb
rm -rf /home/$2/notebooks/IrisClassifierPyMLWebService.ipynb
rm -rf /home/$2/notebooks/SQLDW_Explorations.ipynb
rm -rf /home/$2/notebooks/LoadDataIntoDW.ipynb


# CNTK / Vw 
#cd /dsvm/tools/
rm -rf /dsvm/tools/cntk
rm -rf /dsvm/tools/CNTK-2016-02-08-Linux-64bit-CPU-Only/
rm -rf /dsvm/tools/VowpalWabbit/
rm -rf /dsvm/tools/xgboost
rm -rf /usr/eclipse

#unsopported tools 
yum remove vim.tiny
yum remove emacs -y
yum remove gedit -y 

echo "Running h2o.jar"
# Use 90% of RAM for H2O.
memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$[ $memTotalKb / 1024 ]
tmp=$[ $memTotalMb * 90 ]
xmxMb=$[ $tmp / 100 ]

nohup java -Xmx${xmxMb}m -jar /dsvm/tools/h2o.jar -flatfile /dsvm/tools/flatfile.txt 1> /dev/null 2> h2o.err &


echo "Success!!"
