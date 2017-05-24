# Azure ARM Template to deploy Deep Water on Azure DSVM

Missing out-of-the-box examples and data 

Demo: ssh into the machine and run from the shell 
	$ sudo nvidia-docker run -d -p 54321:54321  --net host -v $PWD:/host opsh2oai/h2o-deepwater java -jar /opt/h2o.jar


<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fh2oai%2Fh2o-cloud%2Fmaster%2FAzure-H2O-DeepWater%2FmainTemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

