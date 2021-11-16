#!/usr/bin/env bash

# Install relion_tomo_robot for use on the current system
# Make sure this file is executable (chmod +x install.sh)

# Ask user where to install
echo "Where would you like to install relion_tomo_robot?"
DEFAULT_INSTALL_DIR="/opt/relion_tomo_robot"
echo -ne "Install location (absolute path) (\e[36m${DEFAULT_INSTALL_DIR}\e[0m): "
read install_dir

# Check installation directory input
# Add working directory if absolute path not given
[ -z "$install_dir" ] && install_dir=$DEFAULT_INSTALL_DIR
[[ ! $install_dir == /* ]] && install_dir=${PWD}/$install_dir

# File Locations
WORKING_DIR=$PWD
ASSETS_DIR=${WORKING_DIR}/assets
ROBOT_DIR=${WORKING_DIR}/relion4_tomo_robot
ACTIVATION_SCRIPT_EXAMPLE=${ASSETS_DIR}/robot_activate_example.m
ACTIVATION_SCRIPT=${ROBOT_DIR}/robot_activate.m

# Prepare installation in robot directory
# Put true install location in robot_activate script
sed "s|XXX_INSTALL_LOC_XXX|${install_dir}|g" ${ACTIVATION_SCRIPT_EXAMPLE} > ${ACTIVATION_SCRIPT}

# Add executable permissions to tiltalign_wrapper.sh and get_tasolution.py
tiltalign_wrapper=${ROBOT_DIR}/autoalign/tiltalign_wrapper.sh
get_tasolution=${ROBOT_DIR}/autoalign/get_tasolution.py

for script in $tiltalign_wrapper $get_tasolution;
do
if [ ! -x $script ]
then
    chmod +x $script
fi
done

# Copy prepared robot directory to true install location
mkdir -p $install_dir
\cp -rf $ROBOT_DIR/* $install_dir/ && echo -e "Successfully installed relion_tomo_robot in \e[36m${install_dir}\e[0m"
\rm $ACTIVATION_SCRIPT


