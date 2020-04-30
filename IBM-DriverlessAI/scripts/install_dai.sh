#!/bin/bash -e

echo "Waiting 180s for cloudinit to complete"
sleep 60

# Install core packages
echo "Install core packages"
sudo apt-get -yqq update && \
sudo apt-get -yqq --no-install-recommends install \
  curl \
  apt-utils \
  apache2-utils \
  wget \
  libblas-dev \
  default-jre \
  clinfo \
  vim \
  unzip \
  tar

#Add nvidia
echo "Add Nvidia"
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/ppc64el/cuda-repo-ubuntu1804_10.0.130-1_ppc64el.deb
sudo dpkg -i cuda-repo-ubuntu1804_10.0.130-1_ppc64el.deb
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/ppc64el/7fa2af80.pub
sudo apt-get update
sudo apt-get install -yqq cuda

echo "Add cudnn"
wget https://h2o-internal-release.s3-us-west-2.amazonaws.com/libcudnn7-dev_7.6.5.32-1%2Bcuda10.0_ppc64el.deb
wget https://h2o-internal-release.s3-us-west-2.amazonaws.com/libcudnn7-doc_7.6.5.32-1%2Bcuda10.0_ppc64el.deb
wget https://h2o-internal-release.s3-us-west-2.amazonaws.com/libcudnn7_7.6.5.32-1%2Bcuda10.0_ppc64el.deb
sudo dpkg -i libcudnn7_7* 
sudo dpkg -i libcudnn7-dev*
sudo dpkg -i libcudnn7-doc*

echo "Install DAI"
#Install DAI
wget --quiet https://s3.amazonaws.com/artifacts.h2o.ai/releases/ai/h2o/dai/rel-1.8.5-64/ppc64le-centos7/dai_1.8.5.1_ppc64el.deb
sudo dpkg -i dai*.deb

#enable DAI
echo "enable DAI"
sudo systemctl enable dai

#cleanup
sudo rm *.deb
