#!/bin/bash

owner=$(echo $HOME | rev | cut -d"/" -f1 | rev)
#owner=""

echo "********************"
echo "* Deploying gitlab *"
echo "********************"
echo .
echo "1. Cloning gitlab repository"
git clone https://gitlab.com/gitlab-org/gitlab-ce.git
echo "2. Building gitlab image"
docker build --tag gitlab_image gitlab-ce/docker/
echo "3. Running gitlab container"
docker run --detach --name gitlab_data gitlab_image /bin/true
docker run --detach --name gitlab_app --publish 80:80 --publish 2222:22 --volumes-from gitlab_data gitlab_image
echo "You can then go to http://ec2-XXX-XXX-XXX-XXX.us-west-2.compute.amazonaws.com"
echo "You can login with username root and password 5iveL!fe"
echo .
echo "********************"
echo "* Deploying jenkins *"
echo "********************"
echo .
echo "1. Building jenkins image"
docker build --tag=${owner}"/jenkins" jenkins/
echo "2. Running jenkins container"
docker run --detach --name myjenkins -p 8080:8080 -v /var/jenkins_home ${owner}/jenkins
echo "You can then go to http://ec2-XXX-XXX-XXX-XXX.us-west-2.compute.amazonaws.com:8080"
echo .
