from pyspark import SparkContext, SparkConf
import pyspark
import pip
import urllib
import zipfile
import subprocess
import conda.cli
import sys


def main():
	url = 'http://h2o-release.s3.amazonaws.com/sparkling-water/rel-2.1/23/sparkling-water-2.1.23.zip'
	urllib.urlretrieve(url, 'sparkling-water.zip')
	zip_ref = zipfile.ZipFile('sparkling-water.zip', 'r')
	zip_ref.extractall()

	sparkling_jar = 'sparkling-water-2.1.23/assembly/build/libs/sparkling-water-assembly_2.11-2.1.23-all.jar'
	pysparkling_file = 'sparkling-water-2.1.23/py/build/dist/h2o_pysparkling_2.1-2.1.23.zip'

	user_folder = '/mnt/resource/hadoop/yarn/local/usercache/livy/'
	pip.main(['install','h2o', '-t', user_folder])
	pip.main(['install','h2o_pysparkling_2.1', '-t', user_folder])

	sys.path.insert(1, user_folder)

	
	import os

	os.environ["PYTHON_EGG_CACHE"] = "~/"
	import h2o, pysparkling
	from h2o.automl import H2OAutoML

	conf = SparkConf()\
			.setAppName("MyH2OApp")\
			.set("spark.jars",sparkling_jar) \
			.set("spark.submit.pyFiles",pysparkling_file) \
			.set("spark.locality.wait","3000")\
			.set("spark.scheduler.minRegisteredResourcesRatio","1")\
			.set("spark.task.maxFailures","1")\
			.set("spark.yarn.am.extraJavaOption","-XX:MaxPermSize=384m")\
			.set("spark.yarn.max.executor.failures","1")\
			.set("maximizeResourceAllocation", "true") 

	sc = SparkContext(conf=conf)

	sc.stop()


	h2o_context = pysparkling.H2OContext.getOrCreate(sc)

	train = h2o.import_file("wasb://h2o-dumydata@primaryblob.blob.core.windows.net/higgs_train_10k.csv")



	# Identify predictors and response
	x = train.columns
	y = "response"
	x.remove(y)


	# Run AutoML for 30 seconds
	aml = H2OAutoML(max_runtime_secs = 3600)
	aml.train(x = x, y = y,
	          training_frame = train)

	# View the AutoML Leaderboard
	lb = aml.leaderboard
	lb

if __name__ == "__main__":
    main()