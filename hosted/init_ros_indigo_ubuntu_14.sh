#!/usr/bin/env bash

sudo apt-get install wget -y
sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu trusty main" > /etc/apt/sources.list.d/ros-latest.list'
wget http://packages.ros.org/ros.key -O - | sudo apt-key add -
sudo apt-get update -y
sudo apt-get install ros-indigo-desktop-full -y
sudo apt-get install ros-indigo-cmake-modules -y

sudo apt-get install python-wstool -y
sudo apt-get install python-rosinstall -y
sudo apt-get install python-rosdep -y
sudo apt-get install python-pip -y

pip install catkin_pkg

source /opt/ros/indigo/setup.bash
mkdir -p ~/workspace/src
cd ~/workspace/src
catkin_init_workspace
cd ~/workspace/
catkin_make

source ~/workspace/devel/setup.bash

sudo rosdep init -y
rosdep update -y

cd ~/workspace/src
wstool init
