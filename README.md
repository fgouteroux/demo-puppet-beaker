# demo-puppet-beaker

Test Automation platform using puppet and beaker on [Amazon Web Services (AWS)](http://aws.amazon.com)

# Installation

Please fill the config file **aws_auth** with the IAM user credentials (access/secret key).
```
:default:
  :aws_access_key_id: xxxxxxxxxxxx
  :aws_secret_access_key: xyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxyxy
```

Run the script **deploy_beaker_env.sh** that will create two containers:
- gitlab
- jenkins


## Gitlab

> The gitlab version used in the docker container is the [community edition](https://gitlab.com/gitlab-org/gitlab-ce/).

You have to change the default password for the gitlab user "**root**", by default **5iveL!fe**

Create your project and add a web hook: "http://your-jenkins-server/gitlab/build_now"


## Jenkins


> Jenkins version has been fixed to the **1.595** and Dockerfile has been created to integrate beaker requirements.

> Docker build source could be retrieved from [here](https://registry.hub.docker.com/_/jenkins/).


Before create jenkins job, you have to install the **gitlab-hook plugin**.
That will install git-client and others dependencies required.


Then you can create the job with:
- parameterized build with string parameter **BRANCH**.
- configured git repository
