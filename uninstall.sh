#!/bin/sh

set -e


# ============================================================================
# Record the time this script starts
# ============================================================================
date


# ============================================================================
# Set variables for installation
# ============================================================================
. ./config.sh

# ============================================================================
# Uninstall remaining dependencies for projects
# ============================================================================
echo "\e[104m Uninstall remaining dependencies for projects \e[0m"
sudo apt-get remove -y --purge python-setuptools


# ============================================================================
# Uninstall jetcard jupyter service
# ============================================================================
if systemctl list-unit-files | grep -q jetcard_jupyter.service; then
    echo "\e[44m Uninstall jetcard jupyter service \e[0m"
    sudo systemctl stop jetcard_jupyter
    sudo systemctl disable jetcard_jupyter
    sudo rm /etc/systemd/system/jetcard_jupyter.service
else
    echo "jetcard_jupyter service not found, skipping uninstallation."
fi


# ============================================================================
# Uninstall jetcard display service
# ============================================================================
if systemctl list-unit-files | grep -q jetcard_display.service; then
    echo "\e[44m Uninstall jetcard display service \e[0m"
    sudo systemctl stop jetcard_display
    sudo systemctl disable jetcard_display
    sudo rm /etc/systemd/system/jetcard_display.service
else
    echo "jetcard_display service not found, skipping uninstallation."
fi


# ============================================================================
# Uninstall jetcard
# ============================================================================
echo "\e[44m Uninstall jetcard \e[0m"
sudo -H pip3 uninstall -y flask
sudo -H pip3 uninstall -y jetcard


# ============================================================================
# Uninstall other misc packages for point_detector
# ============================================================================
echo "\e[44m Uninstall other misc packages for point_detector \e[0m"
# remove after tensorflow
#sudo -H pip3 uninstall tensorboard
sudo -H pip3 uninstall -y segmentation-models-pytorch


# ============================================================================
# Uninstall other misc packages for trt_pose
# ============================================================================
echo "\e[44m Uninstall other misc packages for trt_pose \e[0m"
# Used by pretrainedmodels
#sudo -H pip3 uninstall tqdm 

# Used many other places
# Used by object-detection
#sudo -H pip3 uninstall cython 

sudo -H pip3 uninstall -y pycocotools

# Used by 20+ packages
#sudo apt-get remove --purge python3-matplotlib

# Required by 10 packages
#sudo -H pip3 uninstall traitlets

sudo -H pip3 uninstall -y scikit-learn


# ============================================================================
# Uninstall jetracer
# ============================================================================
echo "\e[44m Uninstall jetracer \e[0m"
sudo -H pip3 uninstall -y jetracer
if [ -d "$HOME/jetracer" ]; then
    echo "Removing $HOME/jetracer"
    sudo rm -rf "$HOME/jetracer"
else
    echo "No directory found at $HOME/jetracer"
fi


# ============================================================================
# Uninstall torch2trt
# ============================================================================
echo "\e[44m Uninstall torch2trt \e[0m"
sudo -H pip3 uninstall -y torch2trt
if [ -d "$HOME/torch2trt" ]; then
    echo "Removing $HOME/torch2trt"
    sudo rm -rf "$HOME/torch2trt"
else
    echo "No directory found at $HOME/torch2trt"
fi


# ============================================================================
# Uninstall jetcam
# ============================================================================
echo "\e[44m Uninstall jetcam \e[0m"
sudo -H pip3 uninstall -y jetcam
if [ -d "$HOME/jetcam" ]; then
    echo "Removing $HOME/jetcam"
    sudo rm -rf "$HOME/jetcam"
else
    echo "No directory found at $HOME/jetcam"
fi


# ============================================================================
# Uninstall version of traitlets with dlink.link() feature
# (added after 4.3.3 and commits after the one below only support Python 3.7+) 
# ============================================================================
# echo "\e[44m Uninstall traitlets \e[0m"
# sudo -H python3 -m pip uninstall git+https://github.com/ipython/traitlets@dead2b8cdde5913572254cf6dc70b5a6065b86f8


# ============================================================================
# Uninstall jupyter_clickable_image_widget
# ============================================================================
echo "\e[42m Uninstall jupyter_clickable_image_widget \e[0m"
sudo -H pip3 uninstall -y jupyter_clickable_image_widget
if [ -d "$HOME/jupyter_clickable_image_widget" ]; then
    echo "Removing $HOME/jupyter_clickable_image_widget"
    sudo rm -rf "$HOME/jupyter_clickable_image_widget"
else
    echo "No directory found at $HOME/jupyter_clickable_image_widget"
fi


# ============================================================================
# Uninstall JupyterLab (lock to 2.2.6, latest as of Sept 2020)
# ============================================================================
echo "\e[48;5;172m Uninstall Jupyter Lab 2.2.6 \e[0m"
sudo -H pip3 uninstall -y jupyter jupyterlab==2.2.6 --verbose


# ============================================================================
# Uninstall traitlets (master, to support the unlink() method)
# ============================================================================
echo "\e[48;5;172m Uninstall traitlets \e[0m"
#sudo -H python3 -m pip install git+https://github.com/ipython/traitlets@master
sudo -H python3 -m pip uninstall -y traitlets


# ============================================================================
# Uninstall TensorFlow models repository
# ============================================================================
echo "\e[48;5;172m Uninstall TensorFlow models repository \e[0m"
sudo -H python3 -m pip uninstall -y slim
# This may just be the removal of a directory
echo "\e[48;5;172m Uninstall TensorFlow models repository \e[0m"
if [ -d "$HOME/TF-Models" ]; then
    echo "Removing $HOME/TF-Models"
    sudo rm -rf "$HOME/TF-Models"
else
    echo "No directory found at $HOME/TF-Models"
fi


# ============================================================================
# Uninstall the pre-built TensorFlow pip wheel
# ============================================================================
echo "\e[48;5;202m Uninstall the pre-built TensorFlow pip wheel \e[0m"
# sudo apt-get install -y python3-pip pkg-config
# sudo apt-get install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran

# sudo -H pip3 install --verbose 'protobuf<4' 'Cython<3'
# sudo -H pip3 install -U pip testresources setuptools==58.3.0
sudo -H pip3 uninstall -y --verbose $TENSOR_WHEEL
sudo -H pip3 uninstall -y h5py==3.1.0


# ============================================================================
# Uninstall pip dependencies for pytorch-ssd
# ============================================================================
echo "\e[45m Uninstall dependencies for pytorch-ssd \e[0m"
#sudo -H pip3 install --verbose --upgrade Cython && \
sudo -H pip3 uninstall -y --verbose boto3 pandas


# ============================================================================
# Uninstall torchvision package
# ============================================================================
echo "\e[45m Uninstall torchvision package \e[0m"

sudo -H pip3 uninstall -y torchvision
sudo -H pip3 uninstall -y pillow==$PILLOW_VERSION

#sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev

sudo rm -rf "$HOME/torchvision"


# ============================================================================
# Uninstall the pre-built PyTorch pip wheel 
# ============================================================================
echo "\e[45m Uninstall the pre-built PyTorch pip wheel  \e[0m"
cd
sudo -H pip3 uninstall -y $PYTORCH_WHEEL

sudo rm -rf "$HOME/$PYTORCH_WHEEL"
#sudo -H pip3 uninstall Cython
#sudo apt-get uninstall -y python3-pip libopenblas-base libopenmpi-dev 


# ============================================================================
# uninstall jtop
# ============================================================================
echo "\e[100m Uninstall jtop \e[0m"
sudo -H pip3 uninstall -y jetson-stats


# ============================================================================
# record the time this script ends
# ============================================================================
date