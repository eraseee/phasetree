# phasetree IAC task Mathias


## Architecture
Node.js app for running the web service. This was done due to being most familiar with setting this up. 

The Node.js app, contains access to environment variables through Process.env. 

The infrastructure have been setup with Terraform, as it connects directly with AWS, and the provider can detect Environment variables, for keeping login information secret.



## Setup
Installing Node.js is necessary before running the server.js file

To customize the PORT, HOST, or Message on the initial page. these can all be set in environment variables.

A dockerfile have been added to being the node.js app, but running the app locally does not forward traffic properly.

As such running the code with Node.js lets you go the main page, /health and /version. But running it in docker, does not allow any of these endpoints.



## Guide
There is a powershell fine called buildandpublish.ps1, this is running docker locally, and then publishing to the ECR

Deployment of general infrastructure have been made with Terraform, in the deployment folder. 
This folder contains a terraform file in the Terraform folder, which is used to run plan and apply.
It would make sense to prepare a few powershell files, for running plan and apply, as there are distinguished between dev and prod, in the terraform variables.

General cleanup haven't been prepared, but with Terraform any module not needed any longer, can be removed by commenting it out in the .tf files.
Then running plan and apply to make a teardown on the providers side. 
There are some limiting factors for this, e.g. if something depends on the resource attempted to be removed, this will cause issues.
It is also possible to add the Lifecylce { prevent_destroy = true} flag, to make sure a resource does not get destroyed without explicitly removing this flag.

Github actions have been made to auto deploy to ECR, and automatically deploy a new Task for the image.
Deployment to production requires a manual step, and both have been setup as individual environments, as such it will run all the steps again for production
This have been done in case the ECR or other variables are different from development to production.
Before deployment to production can happen, the automatic deployment to development must succeed


This have not been tested, as I could not deploy on AWS.


## Assumptions
Quite a few assumptions have been made around the actual code, since deployment to AWS did not work.
Any attempts at trying to deploy to AWS ended up in access restrictions. Could not create tags, and if tags was removed, the creation of resources was denied.

Automations is assumed working, but since it have not been tested, this is very unknown.

The node.js app does not run very smoothly in docker, and I have assumed it is due to not forwarding traffic correctly, but it could be the build process that is not doing what it should 
