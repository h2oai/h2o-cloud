#!/bin/bash

# Install prerequisite packages
apt-get -y update
apt-get install -y \
  curl \
  wget \
  unzip \
  apt-utils \
  software-properties-common \
  python-software-properties

echo "deb http://cran.rstudio.com/bin/linux/ubuntu xenial/" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keyserver.ubuntu.com --recv-key E084DAB9
gpg -a --export E084DAB9 | apt-key add -
add-apt-repository -y ppa:webupd8team/java
apt-get update -q
echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections

apt-get -y install \
  python3-setuptools \
  python3-pip \
  gdebi \
  python3-pandas \
  python3-numpy \
  python3-matplotlib \
  libxml2-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libgtk2.0-0 \
  iputils-ping \
  cloud-utils \
  apache2-utils

apt-get install -y \
  r-base \
  r-base-dev

wget https://cran.cnr.berkeley.edu/src/contrib/data.table_1.10.4.tar.gz
wget https://cran.cnr.berkeley.edu/src/contrib/lazyeval_0.2.0.tar.gz
wget https://cran.cnr.berkeley.edu/src/contrib/Rcpp_0.12.10.tar.gz
wget https://cran.cnr.berkeley.edu/src/contrib/tibble_1.3.0.tar.gz
wget https://cran.cnr.berkeley.edu/src/contrib/hms_0.3.tar.gz
wget https://cran.cnr.berkeley.edu/src/contrib/feather_0.3.1.tar.gz

R CMD INSTALL \
  data.table_1.10.4.tar.gz \
  lazyeval_0.2.0.tar.gz \
  Rcpp_0.12.10.tar.gz \
  tibble_1.3.0.tar.gz \
  hms_0.3.tar.gz \
  feather_0.3.1.tar.gz

rm -rf *.tar.gz && \

R -e 'chooseCRANmirror(graphics=FALSE, ind=54);install.packages(c("R.utils",  "RCurl", "jsonlite", "statmod", "devtools", "roxygen2", "testthat", "Rcpp", "fpc", "RUnit", "ade4", "glmnet", "gbm", "ROCR", "e1071", "ggplot2", "LiblineaR"))'

# Install RStudio
wget https://download2.rstudio.org/rstudio-server-1.0.143-amd64.deb
gdebi --non-interactive rstudio-server-1.0.143-amd64.deb
rm rstudio-server-1.0.143-amd64.deb

# Install Oracle Java 8
apt-get install -y --allow-unauthenticated oracle-java8-installer
apt-get clean

rm -rf /var/cache/apt/*

# Install H2o
wget http://h2o-release.s3.amazonaws.com/h2o/latest_stable -O latest
wget --no-check-certificate -i latest -O /opt/h2o-latest.zip
unzip -d /opt /opt/h2o-latest.zip

rm /opt/h2o-latest.zip
cd /opt
cd `find . -name 'h2o.jar' | sed 's/.\///;s/\/h2o.jar//g'`
cp h2o.jar /opt

R CMD INSTALL `find . -name "h2o*.tar.gz"`
/usr/bin/pip3 install --upgrade --force-reinstall pip==9.0.3
/usr/bin/pip3 install `find . -name "*.whl"`

mkdir /data
mkdir /opt/h2oai


# Setup Firewall
ufw allow OpenSSH
ufw allow in on ens4 to any port 54321 proto tcp
ufw allow in on ens4 to any port 54322 proto tcp
ufw enable
