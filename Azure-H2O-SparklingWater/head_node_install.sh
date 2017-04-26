#!/bin/bash
# ARGS: $1=username $2=SparkVersion
set -e

echo "Cleaning ..."
rm -rf /home/h2o
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

# Adjust based on the build of H2O you want to download. 
spark-submit --version &>temp.outfile
SPARK_VER=$(cat temp.outfile|grep "  version"|sed 's/^.*\(version \)//g' | cut -c 1-3)
rm temp.outfile

if [ $SPARK_VER == "2.1" ]; then
version=2.1
h2oBuild=3
SparklingBranch=rel-${version}
else
version=2.0
h2oBuild=5
SparklingBranch=rel-${version}
fi


wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/${h2oBuild}/sparkling-water-${version}.${h2oBuild}.zip &
wait

unzip -o sparkling-water-${version}.${h2oBuild}.zip 1> /dev/null &
wait

echo "Rename jar and Egg files"
mv /home/h2o/sparkling-water-${version}.${h2oBuild}/assembly/build/libs/*.jar /home/h2o/sparkling-water-${version}.${h2oBuild}/assembly/build/libs/sparkling-water-assembly-all.jar
mv /home/h2o/sparkling-water-${version}.${h2oBuild}/py/build/dist/*.egg /home/h2o/sparkling-water-${version}.${h2oBuild}/py/build/dist/pySparkling-${version}.egg

echo "Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/h2o/sparkling-water-${version}.${h2oBuild}"
export MASTER="yarn-client"
export PYTHON_EGG_CACHE="~/"

echo "Copying Sparkling folder to default storage account ... "
hdfs dfs -mkdir -p "/H2O-Sparkling-Water-files"

hdfs dfs -put -f /home/h2o/sparkling-water-${version}.${h2oBuild}/assembly/build/libs/*.jar /H2O-Sparkling-Water-files/
hdfs dfs -put -f /home/h2o/sparkling-water-${version}.${h2oBuild}/py/build/dist/*.egg /H2O-Sparkling-Water-files/

echo "Copying Notebook Examples to default Storage account Jupyter home folder ... "
curl --silent -o Sentiment_analysis_with_Sparkling_Water.ipynb "https://h2ostore.blob.core.windows.net/examples/Notebooks/Sentiment_analysis_with_Sparkling_Water.ipynb"
curl --silent -o ChicagoCrimeDemo.ipynb  "https://h2ostore.blob.core.windows.net/examples/Notebooks/ChicagoCrimeDemo.ipynb"
curl --silent -o Quickstart_Sparkling_Water.ipynb "https://h2ostore.blob.core.windows.net/examples/Notebooks/Quickstart_Sparkling_Water.ipynb"


echo "Get ClusterName, UserID and EdgeNode DNS"
USERID=$(echo -e "import hdinsight_common.Constants as Constants\nprint Constants.AMBARI_WATCHDOG_USERNAME" | python)

echo "USERID=$USERID"

PASSWD=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nimport hdinsight_common.Constants as Constants\nimport base64\nbase64pwd = ClusterManifestParser.parse_local_manifest().ambari_users.usersmap[Constants.AMBARI_WATCHDOG_USERNAME].password\nprint base64.b64decode(base64pwd)" | python)


fullHostName=$(hostname -f)
    echo "fullHostName=$fullHostName"
    CLUSTERNAME=$(sed -n -e 's/.*\.\(.*\)-ssh.*/\1/p' <<< $fullHostName)
    if [ -z "$CLUSTERNAME" ]; then
        CLUSTERNAME=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nprint ClusterManifestParser.parse_local_manifest().deployment.cluster_name" | python)
        if [ $? -ne 0 ]; then
            echo "[ERROR] Cannot determine cluster name. Exiting!"
            exit 133
        fi
    fi
echo "Cluster Name=$CLUSTERNAME"

curl -o parse_dns.py "https://raw.githubusercontent.com/h2oai/h2o-cloud/master/Azure-H2O-SparklingWater/parse_dns.py"
curl -u $USERID:$PASSWD https://${CLUSTERNAME}.azurehdinsight.net/api/v1/clusters/${CLUSTERNAME}/hosts | python  parse_dns.py 1> tmpfile.txt
EDGENODE_DNS=$(cat tmpfile.txt)
rm tmpfile.txt

EDGENODE_HOSTS="https://$CLUSTERNAME-h2o.apps.azurehdinsight.net:443"


echo $EDGENODE_DNS
sed -i.backup -E  "s/@@IPADDRESS@@/$EDGENODE_HOSTS/" *.ipynb 
sed -i.backup -E  "s,@@FLOWURL@@,$EDGENODE_DNS," *.ipynb


hdfs dfs -mkdir -p "/HdiNotebooks/H2O-PySparkling-Examples"
hdfs dfs -put -f *.ipynb /HdiNotebooks/H2O-PySparkling-Examples/
hdfs dfs -put -f Quickstart_Sparkling_Water.ipynb /HdiNotebooks/

echo "Success"
