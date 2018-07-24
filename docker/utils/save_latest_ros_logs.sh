#!/bin/bash

#set -e # fails on errors
#set -x # echo commands run

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
bold=$(tput bold)
normal=$(tput sgr0)

echo -e "${NC}${normal}You are about to save latest ros logs ${normal}${NC}"

echo -e "${RED}${bold}WARNING! This closes all running docker containers. Do you wish to continue? (y/n) ${normal}${NC}"
read prompt

if [[ $prompt == "" || $prompt == "n" || $prompt == "N" || $prompt == "no" || $prompt == "No" || $prompt == "NO" ]]; then
    exit 1
fi

echo -e "${NC} ${normal}Please add a note for logging with reasons... ${normal}${NC}"
read notes_from_user

container_name=$(docker ps | awk '{if(NR>1) print $NF}')

if [ ! -z "$container_name" ]; then
        container_array=($container_name)
        for container in ${!container_array[@]}; do
            current_container_name=${container_array[$container]}
            echo "Copying logs from $current_container_name.."
            ros_log_dir=~/Desktop/ROS_LOGS/$current_container_name
            dir=ros_logs_$(date +%Y-%m-%d)
            timestamp=$(date +%Y-%m-%d-%T)
            latestws=$(docker exec $current_container_name bash -c 'ls -dtr /home/user/wsdiff_ws_diff* | tail -1')
            latestparam=$(docker exec $current_container_name bash -c 'ls -dtr /home/user/run_params* | tail -1')
	    echo "Killing rosmaster to make .bag.active file into .bag file"
	    docker exec $current_container_name bash -c "kill -SIGINT $(ps aux | grep 'rosmaster' | grep -v grep| awk '{print $2}')"
	    #if rosmaster is still running, use kill -9 to kill it
	    docker exec $current_container_name bash -c "kill -9 $(ps aux | grep 'rosmaster' | grep -v grep| awk '{print $2}') || echo 'rosmaster killed silently'"
	    latestbag=$(docker exec $current_container_name bash -c 'ls -dtr /home/user/*.bag | tail -1')
            
            mkdir -p ${ros_log_dir}
            mkdir -p ${ros_log_dir}/$dir
            docker cp  -L $current_container_name:/home/user/core_dumps ${ros_log_dir}/$dir/ros_log_$timestamp
            docker exec $current_container_name bash -c "rm /home/user/core_dumps/core.*"
            echo "Killing container $current_container_name..."
            docker kill $current_container_name

            docker cp -L $current_container_name:home/user/.ros/log/latest ${ros_log_dir}/$dir

            mv ${ros_log_dir}/$dir/latest/*.* ${ros_log_dir}/$dir/ros_log_$timestamp
            rm -rf ${ros_log_dir}/$dir/latest
	        echo $notes_from_user > ${ros_log_dir}/$dir/ros_log_$timestamp/notes_from_user.txt

            docker cp  -L $current_container_name:$latestws ${ros_log_dir}/$dir/ros_log_$timestamp
            docker cp  -L $current_container_name:$latestparam ${ros_log_dir}/$dir/ros_log_$timestamp
            docker cp  -L $current_container_name:$latestbag ${ros_log_dir}/$dir/ros_log_$timestamp

            echo -e "${GREEN} Latest ROS Logs Saved for $current_container_name! ${NC}"
            sleep 1
        done
else
    echo -e "${RED}There is no docker container running, please start a container to save logs${NC}"
    sleep 1
    exit 1
fi

echo -e "${GREEN}${bold}All ROS logs have been successfully saved!${normal}${NC}"
sleep 2
