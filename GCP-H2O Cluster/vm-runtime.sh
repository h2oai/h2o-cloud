#!/bin/bash

H2OAI_USER=ubuntu
NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
LOCALITY=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone)
INSTANCE_ID=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/id)
IP=$(dig +short myip.opendns.com @resolver1.opendns.com)

# Create keystore
if [ ! -f /opt/h2oai/h2o.jks ]
then
  keytool -genkey -alias h2oserver \
    -keyalg RSA -keystore /opt/h2oai/h2o.jks \
    -dname "CN=h2o, OU=h2o, O=h2o, L=MountainView, S=California, C=US" \
    -storepass h2oh2o -keypass h2oh2o

  echo "Created KeyStore "
else
  echo "KeyStore Already Exist"
fi

# Create user password
if [ ! -f /opt/h2oai/realm.properties ]
then
    psw=$(echo -n "$INSTANCE_ID" | md5sum | )
    echo "h2oai: MD5:$pwd" > /opt/h2oai/realm.properties
  echo "Created Password for User h2oai"
else
  echo "Password and Username Already Exist"
fi

# Create Flatfile
if [ ! -f /opt/h2oai/flatfile.txt ]
then
  touch /opt/h2oai/flatfile.txt
  flatfile="/opt/flatfile.txt"

  hosts=$(curl -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/servers")
  hosts=`echo $hosts | sed -e 's/|/,/g'`
  hosts=${hosts::-1}
  IFS=',' read -r -a array <<< "$hosts"

  for i in "${array[@]}"
  do
    gcloud compute instances list | awk -v pat="$i" '$1 ~ pat { print $4":54321" }' >> /opt/h2oai/flatfile.txt
  done
else
  echo "flatfile.txt already exists"
fi

sleep 15
