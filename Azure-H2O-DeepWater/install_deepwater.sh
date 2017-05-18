#!/bin/bash
# ARGS: $1=scaleNumber $2=username
set -e

#install aws cli to get the jar 
pip install awscli

cd /dsvm/tools/
mkdir h2o-deepwater

#
aws s3 --no-sign-request cp s3://h2o-deepwater/public/nightly/latest/h2o.jar h2o.jar
aws s3 --no-sign-request cp s3://h2o-deepwater/public/nightly/latest/h2o_3.11.0.tar.gz  h2o_3.11.0.tar.gz
aws s3 --no-sign-request cp s3://h2o-deepwater/public/nightly/latest/h2o-3.11.0-py2.py3-none-any.whl h2o-3.11.0-py2.py3-none-any.whl

pip install h2o-3.11.0-py2.py3-none-any.whl
R CMD install h2o_3.11.0.tar.gz


export CUDA_PATH=/usr/local/cuda
export LD_LIBRARY_PATH=$CUDA_PATH/lib64:$LD_LIRBARY_PATH

echo "Downloading DeepWater Examples"
cd /home/$2/notebooks

mkdir deepwater-examples
cd deepwater-examples						#make a directory we want to copy folders to
git init                            			#initialize the empty local repo
git remote add origin -f https://github.com/h2oai/h2o-tutorials.git     #add the remote origin
git config core.sparsecheckout true			#very crucial. this is where we tell git we are checking out specifics
echo "gtc-2017-deep-water/*" >> .git/info/sparse-checkout #recursively checkout examples folder
git pull origin master


echo "Running h2o.jar"
# Use 90% of RAM for H2O.
memTotalKb=`cat /proc/meminfo | grep MemTotal | sed 's/MemTotal:[ \t]*//' | sed 's/ kB//'`
memTotalMb=$(($memTotalKb / 1024)) 
tmp=$(($memTotalMb * 90)) 
xmxMb=$(($tmp / 100)) 

nohup java -Xmx${xmxMb}m -jar /dsvm/tools/h2o-deepwater/h2o.jar  1> /dev/null 2> /dsvm/tools/h2o-deepwater/h2o.err &


echo "Success!!"

