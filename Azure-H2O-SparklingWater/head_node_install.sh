#!/bin/bash
# ARGS: $1=username $2=SparkVersion
set -e

echo " Making h2o folder"

mkdir -p /home/h2o
echo "Changing to h2o folder ..."
cd /home/h2o/
wait 

#Libraries needed on the worker roles in order to get pysparkling working
/usr/bin/anaconda/bin/pip install -U requests
/usr/bin/anaconda/bin/pip install -U tabulate
/usr/bin/anaconda/bin/pip install -U future
/usr/bin/anaconda/bin/pip install -U six

#Scikit Learn on the nodes
/usr/bin/anaconda/bin/pip install -U scikit-learn

# Adjust based on the build of H2O you want to download. (TODO)

version2=2.0
SparklingBranch2=rel-${version2}
h2oBuild2=5

wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch2}/${h2oBuild2}/sparkling-water-${version2}.${h2oBuild2}.zip &
wait

unzip -o sparkling-water-${version2}.${h2oBuild2}.zip 1> /dev/null &
wait

echo "Rename jar and Egg files"
mv /home/h2o/sparkling-water-${version2}.${h2oBuild2}/assembly/build/libs/*.jar /home/h2o/sparkling-water-${version2}.${h2oBuild2}/assembly/build/libs/sparkling-water-assembly-2-0-all.jar
mv /home/h2o/sparkling-water-${version2}.${h2oBuild2}/py/build/dist/*.egg /home/h2o/sparkling-water-${version2}.${h2oBuild2}/py/build/dist/pySparkling-${version2}.egg

echo "Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/h2o/sparkling-water-${version2}.${h2oBuild2}"
export MASTER="yarn-client"
export PYTHON_EGG_CACHE="~/"

echo "Copying Sparkling folder to default storage account ... "
hdfs dfs -mkdir -p "/H2O-Sparkling-Water-files"

hdfs dfs -put -f /home/h2o/sparkling-water-${version2}.${h2oBuild2}/assembly/build/libs/*.jar /H2O-Sparkling-Water-files/
hdfs dfs -put -f /home/h2o/sparkling-water-${version2}.${h2oBuild2}/py/build/dist/*.egg /H2O-Sparkling-Water-files/

echo "Copying Notebook Examples to default Storage account Jupyter home folder ... "
curl --silent -o Sentiment_analysis_with_Sparkling_Water.ipynb "https://h2ostore.blob.core.windows.net/examples/Notebooks/Sentiment_analysis_with_Sparkling_Water.ipynb"
curl --silent -o ChicagoCrimeDemo.ipynb  "https://h2ostore.blob.core.windows.net/examples/Notebooks/ChicagoCrimeDemo.ipynb"
curl --silent -o Quickstart_Sparkling_Water.ipynb "https://h2ostore.blob.core.windows.net/examples/Notebooks/Quickstart_Sparkling_Water.ipynb"

hdfs dfs -copyToLocal /HdiApplications/ScriptActionCfgs/*.cfg cluster.cfg

. cluster.cfg
echo $EDGENODE_HTTPS_ENDPOINTS
sed -i.backup -E  "s/@@IPADDRESS@@/$EDGENODE_HOSTS/" *.ipynb 
sed -i.backup -E  "s,@@FLOWURL@@,$EDGENODE_HTTPS_ENDPOINTS," *.ipynb


hdfs dfs -mkdir -p "/HdiNotebooks/H2O-PySparkling-Examples"
hdfs dfs -put -f *.ipynb /HdiNotebooks/H2O-PySparkling-Examples/
hdfs dfs -put -f Quickstart_Sparkling_Water.ipynb /HdiNotebooks/

echo "Success"
