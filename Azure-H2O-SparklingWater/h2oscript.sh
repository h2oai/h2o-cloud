#!/bin/bash
# ARGS: $1=username $2=SparkVersion
set -e

echo -e "\n Cleaning ..."
rm -rf /home/h2o
echo -e "\n Making h2o folder"
mkdir -p /home/h2o
echo -e "\n Changing to h2o folder ..."
cd /home/h2o/
wait 

#Libraries needed on the worker roles in order to get pysparkling working
#/usr/bin/anaconda/bin/pip install -U requests
pip install -U tabulate
pip install -U future
pip install -U six


#Scikit Learn on the nodes
/usr/bin/anaconda/bin/pip install -U scikit-learn

echo "\n Get ClusterName, UserID and EdgeNode DNS"
USERID=$(echo -e "import hdinsight_common.Constants as Constants\nprint Constants.AMBARI_WATCHDOG_USERNAME" | python)

echo "USERID=$USERID"

PASSWD=$(echo -e "import hdinsight_common.ClusterManifestParser as ClusterManifestParser\nimport hdinsight_common.Constants as Constants\nimport base64\nbase64pwd = ClusterManifestParser.parse_local_manifest().ambari_users.usersmap[Constants.AMBARI_WATCHDOG_USERNAME].password\nprint base64.b64decode(base64pwd)" | python)

checkHostNameAndSetClusterName() {
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
}

ParseEdgeNodeDNS(){
	curl -o parse_dns.py "https://raw.githubusercontent.com/h2oai/h2o-cloud/master/Azure-H2O-SparklingWater/bin/parse_dns.py"
	echo https://${CLUSTERNAME}.azurehdinsight.net/api/v1/clusters/${CLUSTERNAME}/hosts
	curl -u $USERID:$PASSWD https://${CLUSTERNAME}.azurehdinsight.net/api/v1/clusters/${CLUSTERNAME}/hosts | python  parse_dns.py 1> tmpfile.txt
	EDGENODE_DNS=$(cat tmpfile.txt)
	rm tmpfile.txt
}

ParseSparkVersion(){
	curl -o parse_sparkver.py "https://raw.githubusercontent.com/h2oai/h2o-cloud/master/Azure-H2O-SparklingWater/bin/parse_sparkversion.py"
	echo -e https://${CLUSTERNAME}.azurehdinsight.net/api/v1/clusters/${CLUSTERNAME}/stack_versions/1/repository_versions/1
	curl -u $USERID:$PASSWD https://${CLUSTERNAME}.azurehdinsight.net/api/v1/clusters/${CLUSTERNAME}/stack_versions/1/repository_versions/1 | python parse_sparkver.py 1> tmpfile.txt
	INSTALLED_SPARK=$(cat tmpfile.txt)
	rm tmpfile.txt

	echo -e "\n SPARK VERSION=$INSTALLED_SPARK"

	# Adjust based on the build of H2O you want to download. 

	if [ $INSTALLED_SPARK == "2.0" ]; then
	pip install h2o_pysparkling_2.2 
	version=2.0
	h2oBuild=23
	SparklingBranch=rel-${version}
	else
	pip install h2o_pysparkling_2.1 
	version=2.1
	h2oBuild=22
	SparklingBranch=rel-${version}
	fi

}

checkHostNameAndSetClusterName
ParseEdgeNodeDNS
ParseSparkVersion

echo -e "\n Installing sparkling water version $version build $h2oBuild "

wget http://h2o-release.s3.amazonaws.com/sparkling-water/${SparklingBranch}/${h2oBuild}/sparkling-water-${version}.${h2oBuild}.zip &
wait

unzip -o sparkling-water-${version}.${h2oBuild}.zip 1> /dev/null &
wait

echo -e "\n Rename jar and Egg files"
mkdir -p /home/h2o/pyfiles
mv /home/h2o/sparkling-water-${version}.${h2oBuild}/assembly/build/libs/*.jar /home/h2o/pyfiles/sparkling-water-assembly-all.jar
mv /home/h2o/sparkling-water-${version}.${h2oBuild}/py/build/dist/*.zip /home/h2o/pyfiles/pySparkling.zip


echo -e "\n Creating SPARKLING_HOME env ..."
export SPARKLING_HOME="/home/h2o/sparkling-water-${version}.${h2oBuild}"
export MASTER="yarn-client"
export PYTHON_EGG_CACHE="~/"

python pythonfile.py

echo "\n Success"
