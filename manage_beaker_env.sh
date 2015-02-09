#!/bin/bash

action=${1}
allowed_action=(start stop restart rm)
error_msg=0

for i in ${allowed_action[@]} ; do
    if [ $i == $action ] ; then
    	error_msg=1
        echo 'Docker containers action => '${action}
  		docker ${action} myjenkins
   		docker ${action} gitlab_app
   		docker ${action} gitlab_data
	fi
done

if [ ${error_msg} != 1 ] ; then
	echo 'Only theses actions are allowed:'
	echo ${allowed_action[@]}
fi