# Azure ARM Template to deploy a Cluster of H2OVM


This template can also be extended to create a H2O cluster by setting the the <b>vmCount</b> parameter to specify the number of nodes in the cluster. Default is 1 for a single VM.

This template will automatically:  Run the h2o.jar and create the cluster flatfile.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fh2oai%2Fh2o-cloud%2Fmaster%2FAzure-H2O-VM%2FmainTemplate.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>


Once the deployment finishes creating, you can:

1) Connect to <b>Jupyter Notebook</b> by going to *https://\<VM DNS name or IP Address of DSVM-0 node\>:8000/*</br>
2) Connect to <b> H2O Flow</b> by going to *http://\<VM DNS name or IP Address of DSVM-0 node\>:54321/*

This template lets you select from DS_v2 VM types (<a href="https://azure.microsoft.com/en-us/documentation/articles/storage-premium-storage/" target="_blank">Premiun Storage SSD drives</a>) for CPU and I/O intensive workloads.


<b>Important Notes </b>:<br>
- OS Disk by default is small (approx 30GB), this means that you have around 16GB of free space to start with. This is the same for all VM sizes. It is recommended that you add a SSD data disk to the driver node (DSVM-0) by following these instructions: https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-linux-classic-attach-disk/
- Pick a VM size that provides RAM of at least 4x the size of your dataset. Azure VM sizes: https://azure.microsoft.com/en-us/pricing/details/virtual-machines/
- Be aware that Azure subscriptions by default allow only 20 cores. If you get a Validation error on template deployment, this might be the cause. To increase the cores limit, follow these steps: https://blogs.msdn.microsoft.com/girishp/2015/09/20/increasing-core-quota-limits-in-azure/
- For H2O, Java heap size is set to the 90% of RAM available. If you need to use less heap size on the driver node (H2O-0), you must stop H2O and launch it again with less heap memory, by doing this

	> killall -q -v java <br>
	> nohup java -Xmx[WHAT-YOU-WANT]m -jar /etc/h2o/h2o.jar -flatfile /etc/h2o/flatfile.txt 1> /dev/null 2> h2o.err &

You will also need to run this command with [sudo] once the VM is restarted.


### Jupyter Notebook 

The Anaconda distribution also comes with a Jupyter notebook, an environment to share code and analysis. The Jupyter Notebook is accessed through JupyterHub. You log in using your local Linux username and password.

The Jupyter notebook server has been pre-configured with Python 2, Python 3 and R kernels. There is a desktop icon named "Jupyter Notebook to launch the browser to access the Notebook server. If you are on the VM via SSH or X2go client you can also visit [https://localhost:8000/](https://localhost:8000/) to access the Jupyter notebook server.

-->Continue if you get any certificate warnings. 

You can access the Jupyter notebook server from any host. Just type in *https://\<VM DNS name or IP Address\>:8000/* 

-->Port 8000 is opened in the firewall by default when the VM is provisioned.

We have packaged a few sample notebooks - one in Python and one in R. You can see the link to the samples on the notebook home page after you authenticate to the Jupyter notebook using your local Linux username and password. You can create a new notebook by selecting **New** and then the appropriate language kernel. If you don't see the **New** button, click on the **Jupyter** icon on the top left to go to the home page of the notebook server. 

### Python
For development using Python, Anaconda Python distribution 2.7 and 3.5 has been installed. This distribution contains the base Python along with about 300 of the most popular math, engineering, and data analytics packages. You can use the default text editors. In addition you can use Spyder a Python IDE that is bundled with Anaconda Python distributions. Spyder needs a graphical desktop or X11 forwarding. A shortcut to Spyder is provided in the graphical desktop. 

Since we have both Python 2.7 and 3.5, you need to specifically activate the desired Python version you want to work on in the current session. The activation process sets the PATH variable to the desired version of Python. 

To activate Python 2.7, run the following from the shell:

	 $ source /anaconda/bin/activate root

Python 2.7 is installed at */anaconda/bin*. 

To activate Python 3.5, run the following from the shell:

	$ source /anaconda/bin/activate py35


Python 3.5 is installed at */anaconda/envs/py35/bin*

Now to invoke python interactive session just type ***python*** in the shell. If you are on a graphical interface or have X11 forwarding set up, you can type ***spyder*** command to launch the Python IDE. 
