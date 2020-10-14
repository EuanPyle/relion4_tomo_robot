#!/usr/bin/env bash

# Install autoalign_dynamo for use on the current system
# Make sure this file is executable (chmod +x install.sh)

# Ask user where to install
echo "Where would you like to install autoalign_dynamo?"
DEFAULT_INSTALL_DIR="/opt/autoalign_dynamo"
echo -ne "Install location (absolute path) (\e[36m${DEFAULT_INSTALL_DIR}\e[0m): "
read install_dir

# Check installation directory input
# Add working directory if absolute path not given
[ -z "$install_dir" ] && install_dir=$DEFAULT_INSTALL_DIR
[[ ! $install_dir == /* ]] && install_dir=${PWD}/$install_dir

# File Locations
WORKING_DIR=$PWD
ASSETS_DIR=${WORKING_DIR}/assets
AUTOALIGN_DIR=${WORKING_DIR}/autoalign
ACTIVATION_SCRIPT_EXAMPLE=${ASSETS_DIR}/autoalign_activate_example.m
ACTIVATION_SCRIPT=${AUTOALIGN_DIR}/autoalign_activate.m

# Prepare installation in autoalign directory
# Put true install location in autoalign_activate script
sed "s|XXX_INSTALL_LOC_XXX|${install_dir}|g" ${ACTIVATION_SCRIPT_EXAMPLE} > ${ACTIVATION_SCRIPT}

# Add executable permissions to tiltalign_wrapper.sh and get_tasolution.py
tiltalign_wrapper=${AUTOALIGN_DIR}/tiltalign_wrapper.sh
get_tasolution=${AUTOALIGN_DIR}/get_tasolution.py

for script in $tiltalign_wrapper $get_tasolution;
do
if [ ! -x $script ]
then
    chmod +x $script
fi
done

# Copy prepared autoalign directory to true install location
mkdir -p $install_dir
\cp -rf $AUTOALIGN_DIR/* $install_dir/ && echo -e "Successfully installed autoalign_dynamo in \e[36m${install_dir}\e[0m"
\rm $ACTIVATION_SCRIPT


