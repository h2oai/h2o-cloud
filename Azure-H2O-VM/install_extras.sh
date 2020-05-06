#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e

echo "Changing to h2o folder ..."
cd /etc/h2o/
wait

echo "Updating H2O"
wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O /etc/h2o/latest

LATEST_VERSION=`cat /etc/h2o/latest`

wget $LATEST_VERSION -O /etc/h2o/h2o-latest.zip

unzip -d /etc/h2o /etc/h2o/h2o-latest.zip

rm /etc/h2o/h2o-latest.zip
cd /etc/h2o
cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'`
cp h2o.jar /etc/h2o

echo "Creating Flatfile with info of all Vms in cluster .."
flatfileName=flatfile.txt
rm -f ${flatfileName}
i=0
for i in $(seq 4 $((4+$1-1)))
do
    privateIp="10.0.0.$i"
    echo "${privateIp}:54321" >> ${flatfileName}
done


echo "Setting up the right softlinks for pip 2.7 and pip3 for 3.5..."
ln -s /anaconda/bin/pip /usr/bin/pip #for python 2.7
ln -s /anaconda/envs/py35/bin/pip /usr/bin/pip3 #for python 3.5

echo "Downloading cool notebooks.."
mkdir /home/$2/H2O_Examples
cd /home/$2/H2O_Examples
curl --silent -o H2O_pydemo_tutorial_breast_cancer_classification.ipynb "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-py/demos/H2O_tutorial_breast_cancer_classification.ipynb"
curl --silent -o H2O_rdemo_tutorial_eeg_eyestate.ipynb "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-r/demos/rdemo.tutorial.eeg.eyestate.ipynb"
curl --silent -o H2O_pydemo_tutorial_eeg_eyestate.ipynb  "https://raw.githubusercontent.com/h2oai/h2o-3/master/h2o-py/demos/H2O_tutorial_eeg_eyestate.ipynb"



echo "Running h2o.jar"
# Use 90% of RAM for H2O.
memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$(($memTotalKb / 1024))
tmp=$(($memTotalMb * 90))
xmxMb=$(($tmp / 100))

nohup java -XX:OnOutOfMemoryError="kill -9 %p" -Xmx${xmxMb}m -jar /etc/h2o/h2o.jar -flatfile /etc/h2o/flatfile.txt 1> /dev/null 2> h2o.err &


echo "Success!!"
