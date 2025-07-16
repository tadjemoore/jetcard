#!/bin/sh

set -e

# ============================================================================
# Set variables for installation
# ============================================================================
. ./config.sh


# ============================================================================
# Record the time this script starts
# ============================================================================
date


# ============================================================================
# Get the full dir name of this script
# ============================================================================
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echo "DIR: $DIR"


# ============================================================================
# Keep updating the existing sudo time stamp
# ============================================================================
sudo -v
while true; do sudo -n true; sleep 120; kill -0 "$$" || exit; done 2>/dev/null &


# ============================================================================
# Legacy
# ============================================================================
# Fix NTP server
# ============================================================================
# echo "\e[104m Fix NTP server \e[0m"
# FILE="/etc/systemd/timesyncd.conf"
# sudo -S bash -c "echo 'NTP=0.arch.pool.ntp.org 1.arch.pool.ntp.org 2.arch.pool.ntp.org 3.arch.pool.ntp.org' >> $FILE"
# sudo -S bash -c "echo 'FallbackNTP=0.pool.ntp.org 1.pool.ntp.org 0.us.pool.ntp.org' >> $FILE"
# cat $FILE
# sudo -S systemctl restart systemd-timesyncd.service


# ============================================================================
# Legacy
# nv-l4t-usb-device-mode.sh doesn't exist
# ============================================================================
# Fix USB device mode
# ============================================================================
# echo "\e[104m Fix USB device mode \e[0m"
# DIR="/opt/nvidia/l4t-usb-device-mode/"
# sudo -S cp $DIR/nv-l4t-usb-device-mode.sh $DIR/nv-l4t-usb-device-mode.sh.orig
# sudo -S cp $DIR/nv-l4t-usb-device-mode-stop.sh $DIR/nv-l4t-usb-device-mode-stop.sh.orig
# cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
# cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=
# sudo -S sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode.sh
# sudo -S sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode.sh
# sudo -S sed -i 's|${script_dir}/dhcpd.leases|/run/dhcpd.leases|g' $DIR/nv-l4t-usb-device-mode-stop.sh
# sudo -S sed -i 's|${script_dir}/dhcpd.pid|/run/dhcpd.pid|g' $DIR/nv-l4t-usb-device-mode-stop.sh
# cat $DIR/nv-l4t-usb-device-mode.sh | grep dhcpd_.*=
# cat $DIR/nv-l4t-usb-device-mode-stop.sh | grep dhcpd_.*=


# ============================================================================
# Enable i2c permissions
# ============================================================================
echo "\e[104m Fix Enable i2c permissions \e[0m"
sudo -S usermod -aG i2c $USER


# ============================================================================
# Legacy
# /opt/nvidia/jetson-gpio doesn't exist
# ============================================================================
# Setup Jetson.GPIO
# ============================================================================
# echo "\e[104m Setup Jetson.GPIO \e[0m"
# sudo -S groupadd -f -r gpio
# sudo -S usermod -a -G gpio $USER
# sudo -S cp /opt/nvidia/jetson-gpio/etc/99-gpio.rules /etc/udev/rules.d/
# sudo -S udevadm control --reload-rules
# sudo -S udevadm trigger


# ============================================================================
# Install pip and some python dependencies
# ============================================================================
echo "\e[104m Install pip and some python dependencies \e[0m"
sudo apt-get update
sudo apt install -y python3-pip python3-setuptools python3-pil python3-smbus python3-matplotlib cmake curl
sudo -H pip3 install --upgrade pip


# ============================================================================
# Install jtop
# ============================================================================
echo "\e[100m Install jtop \e[0m"
sudo -H pip3 install jetson-stats 


# ============================================================================
# Install the pre-built PyTorch pip wheel 
# ============================================================================
echo "\e[45m Install the pre-built PyTorch pip wheel  \e[0m"
sudo apt-get install -y python3-pip libopenblas-base libopenmpi-dev
sudo -H pip3 install Cython numpy==1.19.5

cd $HOME
# Check if the PyTorch wheel exists 
if [ -f $PYTORCH_WHEEL ]; then
    echo "PyTorch wheel already exists: $PYTORCH_WHEEL"
else
    echo "Downloading PyTorch wheel from $PYTORCH_WHEEL_URL"
    sudo wget -N $PYTORCH_WHEEL_URL -O $PYTORCH_WHEEL
fi
sudo -H pip3 install $PYTORCH_WHEEL


# ============================================================================
# Install torchvision package
# ============================================================================
echo "\e[45m Install torchvision package \e[0m"
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev
sudo -H pip3 install pillow==$PILLOW_VERSION
# Ninja is causing the install to fail even though it want's to use it so speed up the make
# sudo apt-get install ninja-build

cd $HOME
# Clone torchvision from the official PyTorch repository
# Use the version that matches the PyTorch wheel

if [ -d "torchvision" ]; then
    echo "torchvision directory already exists"
    sudo rm -rf torchvision
    echo "Removing existing torchvision directory"
fi
git clone --branch $TORCHVISION_VERSION https://github.com/pytorch/vision torchvision --depth 1
cd torchvision
python3 setup.py install --user
cd  ../


# ============================================================================
# pip dependencies for pytorch-ssd
# ============================================================================
echo "\e[45m Install dependencies for pytorch-ssd \e[0m"
sudo -H pip3 install --verbose --upgrade Cython && \
sudo -H pip3 install --verbose boto3 pandas


# ============================================================================
# Install the pre-built TensorFlow pip wheel
# ============================================================================
echo "\e[48;5;202m Install the pre-built TensorFlow pip wheel \e[0m"
# this needs to check if it exists
# https://sourceware.org/legacy-ml/libc-alpha/2017-08/msg00010.html
if [ -f /usr/include/xlocale.h ]; then
    echo "xlocale.h already exists"
else
    echo "Creating symlink for xlocale.h"
    sudo ln -s /usr/include/locale.h /usr/include/xlocale.h
fi

sudo apt-get update
sudo apt-get install -y python3-pip pkg-config
sudo apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran
sudo -H pip3 install --verbose 'protobuf<4' 'Cython<3'
sudo -H pip3 install -U pip testresources setuptools==58.3.0 
#sudo -H pip3 install -U numpy==1.19.4 future==0.18.2 mock==3.0.5 h5py==2.10.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast==0.2.2 futures protobuf pybind11
#sudo -H pip3 install -U numpy>=1.4.5 h5py==3.1.0 keras_preprocessing==1.1.1 keras_applications==1.0.8 gast<0.5.0 and >=0.2.1 protobuf >=3.9.2
sudo -H pip3 install -U h5py==3.1.0

cd $HOME
sudo wget --no-check-certificate -N $TENSOR_WHEEL_URL -O $TENSOR_WHEEL
sudo -H pip3 install --verbose $TENSOR_WHEEL


# ============================================================================
# Install TensorFlow models repository
# ============================================================================
echo "\e[48;5;202m Install TensorFlow models repository \e[0m"
cd $HOME
# Clone the TensorFlow models repository if it doesn't exist
url="https://github.com/tensorflow/models"
tf_models_dir="TF-models"
if [ ! -d "$tf_models_dir" ] ; then
    git clone $url $tf_models_dir
    cd "$tf_models_dir"/research
    git checkout 5f4d34fc
    wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-aarch_64.zip
    # wget -O protobuf.zip https://github.com/protocolbuffers/protobuf/releases/download/v3.7.1/protoc-3.7.1-linux-x86_64.zip
    unzip protobuf.zip
    ./bin/protoc object_detection/protos/*.proto --python_out=.
    sudo -H python3 setup.py install
    cd slim
    sudo -H python3 setup.py install
fi


# ============================================================================
# Install traitlets (master, to support the unlink() method)
# ============================================================================
echo "\e[48;5;172m Install traitlets base \e[0m"
#sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@master
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8


# ============================================================================
# Install JupyterLab (lock to 2.2.6, latest as of Sept 2020)
# ============================================================================
echo "\e[48;5;172m Install Jupyter Lab 2.2.6 \e[0m"
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs libffi-dev libssl1.0-dev 
sudo -H pip3 install jupyter jupyterlab==2.2.6 --verbose
sudo -H jupyter labextension install @jupyter-widgets/jupyterlab-manager
jupyter lab --generate-config
python3 -c "from notebook.auth.security import set_password; set_password('$password', '$HOME/.jupyter/jupyter_notebook_config.json')"


# ============================================================================
# Install jupyter_clickable_image_widget
# ============================================================================
echo "\e[42m Install jupyter_clickable_image_widget \e[0m"
cd $HOME
git clone --branch v0.1 https://github.com/jaybdub/jupyter_clickable_image_widget --depth 1
cd jupyter_clickable_image_widget
sudo -H pip3 install -e .
sudo -H jupyter labextension install js
sudo -H jupyter lab build


# ============================================================================
# fix for permission error
# ============================================================================
sudo chown -R jetson:jetson /usr/local/share/jupyter/lab/settings/build_config.json


# ============================================================================
# install version of traitlets with dlink.link() feature
# (added after 4.3.3 and commits after the one below only support Python 3.7+) 
# ============================================================================
echo "\e[48;5;172m Install traitlets update \e[0m"
sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8
sudo -H jupyter lab build


# ============================================================================
# INSTALL jetcam
# ============================================================================
echo "\e[48;5;172m Install jetcam \e[0m"
cd $HOME
git clone https://github.com/NVIDIA-AI-IOT/jetcam
cd jetcam
sudo -H python3 setup.py install


# ============================================================================
# INSTALL torch2trt
# ============================================================================
echo "\e[48;5;172m Install torch2trt \e[0m"
cd $HOME
git clone https://github.com/NVIDIA-AI-IOT/torch2trt 
cd torch2trt 
sudo -H python3 setup.py install --plugins


# ============================================================================
# INSTALL jetracer
# ============================================================================
echo "\e[48;5;172m Install jetracer \e[0m"
cd $HOME
git clone https://github.com/tadjemoore/jetracer
cd jetracer
sudo -H python3 setup.py install


# ============================================================================
# Install other misc packages for trt_pose
# ============================================================================
echo "\e[48;5;172m Install other misc packages for trt_pose \e[0m"
sudo -H pip3 install tqdm cython pycocotools 
sudo apt-get install python3-matplotlib
sudo -H pip3 install traitlets
sudo -H pip3 install -U scikit-learn


# ============================================================================
# Install other misc packages for point_detector
# ============================================================================
echo "\e[48;5;172m Install other misc packages for point_detector \e[0m"
sudo -H pip3 install tensorboard
sudo -H pip3 install segmentation-models-pytorch


# ============================================================================
# Install jetcard
# ============================================================================
echo "\e[44m Install jetcard \e[0m"
cd $DIR
pwd
sudo apt-get install python3-pip python3-setuptools python3-pil python3-smbus
sudo -H pip3 install flask
sudo -H python3 setup.py install


# ============================================================================
# Install jetcard display service
# ============================================================================
echo "\e[44m Install jetcard display service \e[0m"
python3 -m jetcard.create_display_service
sudo mv jetcard_display.service /etc/systemd/system/jetcard_display.service
sudo systemctl enable jetcard_display
sudo systemctl start jetcard_display


# ============================================================================
# Install jetcard jupyter service
# ============================================================================
echo "\e[44m Install jetcard jupyter service \e[0m"
python3 -m jetcard.create_jupyter_service
sudo mv jetcard_jupyter.service /etc/systemd/system/jetcard_jupyter.service
sudo systemctl enable jetcard_jupyter
sudo systemctl start jetcard_jupyter


# ============================================================================
# Install remaining dependencies for projects
# ============================================================================
echo "\e[104m Install remaining dependencies for projects \e[0m"
sudo apt-get install python-setuptools

# ============================================================================
# Make swapfile
# ============================================================================
echo "\e[46m Make swapfile \e[0m"
cd $HOME
if [ ! -f /var/swapfile ]; then
    sudo fallocate -l 4G /var/swapfile
    sudo chmod 600 /var/swapfile
    sudo mkswap /var/swapfile
    sudo swapon /var/swapfile
    sudo bash -c 'echo "/var/swapfile swap swap defaults 0 0" >> /etc/fstab'
else
    echo "Swapfile already exists"
fi


# ============================================================================
# Add a script to profiles so OPENBLAS_CORETYPE is always set
# ============================================================================
echo "\e[46m Add a script to profiles so OPENBLAS_CORETYPE is always set \e[0m"
if [ -f /etc/profile.d/nano.sh ]; then
    if grep -q 'export OPENBLAS_CORETYPE=ARMV8' /etc/profile.d/nano.sh; then
        echo "/etc/profile.d/nano.sh already contains OPENBLAS_CORETYPE"
    else
        echo 'export OPENBLAS_CORETYPE=ARMV8' | sudo tee -a /etc/profile.d/nano.sh > /dev/null
    fi
else
    echo 'export OPENBLAS_CORETYPE=ARMV8' | sudo tee /etc/profile.d/nano.sh > /dev/null
fi
sudo chmod 644 /etc/profile.d/nano.sh


echo "\e[42m All done! \e[0m"

# ============================================================================
# record the time this script ends
# ============================================================================
date