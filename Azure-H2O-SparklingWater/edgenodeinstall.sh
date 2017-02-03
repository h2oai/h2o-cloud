#!/bin/bash


echo " Configure Default Proxy Server"
cd /etc/nginx 
rm nginx.conf
wget https://h2ostore.blob.core.windows.net/marketplacescripts/SparklingWater/nginx.conf
cd /etc/nginx/conf.d/
wget https://h2ostore.blob.core.windows.net/marketplacescripts/SparklingWater/h2o.conf

echo "Starting nginx ..."
nginx 
echo "Now to install Flask"
pip install virtualenv
pip install --upgrade Flask
wget https://h2ostore.blob.core.windows.net/marketplacescripts/SparklingWater/EdgeNodeFlask.py
echo "Set RESTful api"
export FLASK_APP=EdgeNodeFlask.py
echo " Start the FLASK RESTful API"
python EdgeNodeFlask.py &