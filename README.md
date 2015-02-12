# demo-puppet-beaker

Test Automation platform using puppet and beaker on [Amazon Web Services (AWS)](http://aws.amazon.com)

# Installation

1/ Please fill the config file **aws_auth** with your IAM user credentials (access/secret key).
```
:default:
  :aws_access_key_id: xxxxxxxxxxxx
  :aws_secret_access_key: xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy
```

2/ Run the script **deploy_beaker_env.sh** that will create two containers:
  - gitlab
  - jenkins

# Use

## Gitlab

> The gitlab version used in the docker container is the [community edition](https://gitlab.com/gitlab-org/gitlab-ce/).

1. Change the default password for the "**root**" user, by default **5iveL!fe**
2. Create your gitlab project
3. Add a web hook like this "http://your-jenkins-server/gitlab/build_now"

> For testing only, you can use the gitlab-sample-project repository for your gitlab project. See [For testing only](#For-testing-only)

## Jenkins

> Jenkins version has been fixed to the **1.596** and Dockerfile has been created to integrate beaker requirements.

> Docker build source can be retrieved from [here](https://registry.hub.docker.com/_/jenkins/).


1. Install the **gitlab-hook plugin**. That will install **git-client** and others dependencies required.
2. Create your jenkins job with:

  - parameterized build with string parameter **BRANCH**.
  - configured git repository

## Test

1. Modify your code
2. Push it
3. Watch the running jenkins job
4. Get Tests Results

## For testing only

Before using it, you have to:

1/ Set the gitlab project address in **bootstrap_puppetmaster.sh** at line 125

```
[...]
:cachedir: /var/cache/r10k
:sources:
  :local:
    remote: http://192.168.59.103/puppet/puppet.git
    basedir: /etc/puppet/environments
```
2/ Create "**roles**" and "**modules**" repositories in your gitlab (files are located in modules directory)

3/ Set the repositories addresses in **Puppetfile** at lines 28-31

```
[...]
mod "roles",
  :git => "http://192.168.59.103/puppet/roles.git"

mod "profiles",
  :git => "http://192.168.59.103/puppet/profiles.git"
```

4/ Set AWS parameters in:

  * ec2.yaml in **config/image_template/**

```
AMI:
  debian-wheezy-amd64-west:
    :image:
      :foss: ami-3d9cc00d
    :region: us-west-2
  ubuntu-14.04-amd64-west:
    :image:
      :foss: ami-3d50120d
    :region: us-west-2
```
  * app_server.cfg in **spec/acceptance/nodesets**

```
HOSTS:
  puppet:
    roles:
      - master
    platform: debian-wheezy-amd64-west
    user: admin
    subnet_id: subnet-XXXXXXX
    vpc_id: vpc-XXXXXXX
    amisize: t2.small
    hypervisor: ec2
    snapshot: foss
  app-server-1:
    roles:
      - agent
      - app_server
    platform: debian-wheezy-amd64-west
    user: admin
    subnet_id: subnet-XXXXXXX
    vpc_id: vpc-XXXXXXX
    amisize: t2.small
    hypervisor: ec2
    snapshot: foss
```
