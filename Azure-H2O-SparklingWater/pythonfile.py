from pyspark import SparkContext, SparkConf
import pyspark


conf = SparkConf()\
		.setAppName("MyH2OApp")\
		.set("spark.jars","/home/h2o/pyfiles/sparkling-water-assembly-all.jar") \
		.set("spark.submit.pyFiles","/home/h2o/pyfiles/pySparkling.zip") \
		.set("spark.locality.wait","3000")\
		.set("spark.scheduler.minRegisteredResourcesRatio","1")\
		.set("spark.task.maxFailures","1")\
		.set("spark.yarn.am.extraJavaOption","-XX:MaxPermSize=384m")\
		.set("spark.yarn.max.executor.failures","1")\
		.set("maximizeResourceAllocation", "true") 

sc = SparkContext(conf=conf)


import os

os.environ["PYTHON_EGG_CACHE"] = "~/"
import pysparkling, h2o
from h2o.automl import H2OAutoML


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

