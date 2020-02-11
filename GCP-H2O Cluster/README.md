## Google Cloud Launcher  Scripts

Contents:

  * rc.local
  * startup.sh
  * vm-build-script.sh
  * vm-runtime.sh

rc.local - needs to be copied to /etc/rc.local. Manages startup of the vm + cluster.

startup.sh - handles starting H2O. copy to /opt/h2oai/scripts

updateh2o.sh - checks latest version available for h2o. Update if needed. copy to /opt/h2oai/scripts

vm-build-script.sh - configures vm with all settings necessary for deployment

   * installs java
   * installs python and R dependencies   

vm-runtime.sh - handles creating credentials and necessary files prior to launch.

   * creates KeyStore
   * creates vm specific username and password based off vm metadata
   * creates flatfile require for h2o-3 vm clustering.


To build image 

```
gcloud compute images create "<image-name>" \
 --project "h2o-public" \
 --source-disk projects/h2o-gce/zones/<zone>/disks/<disk-name>  \
 --description " <Description> "
 
 ```
