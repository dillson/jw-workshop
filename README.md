# CI/CD with Cloudbees on VKE Workshop

This workshop is presented by VMware and Cloudbees

Instructions created by Dan Illson and Jeff Fry

Presented by Valentina Alaria, Jeff Fry, Dan Illson, Sean O'Dell, and Bill Shetti

## Prerequisites

In order to successfully complete this workshop, you will need:

1. A terminal shell (preferably bash) or emulator
2. [A github account](https://github.com/)
3. The [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) command line package configured within the shell 
4. The kubectl utility installed (this can be installed from the VKE UI)
5. [Helm installed](https://docs.helm.sh/using_helm/#installing-helm) 
6. A login for the VMware Kubernetes Engine service (provided at check-in)

If you need to install any of the prerequsites or signup for a github account, this can be done while the VMware Kubernetes Engine cluster is being built or the Cloudbees core components/Jenkins master are being provisioned.

Please follow the links above for instructions to install or request the prerequisite items.

## Provision a VKE cluster

### Login to VKE UI and Download the CLI package

Download the CLI package from the button in the bottom left corner of the screen labeled 'Download CLI' and select the correct operating system. Make sure it has execute permissions.

### Login to the VKE CLI

Use the following format, replacing organization-id with your organization ID and refresh-token with your refresh token.
```yaml
vke account login -t organization-id -r refresh-token
```

The organization ID is available in the VKE UI by clicking on the box showing your username and organization name in the upper right portion of the screen. Please click on the Org ID to get the long form and use that long form in the command.

For an API/refresh token, please click again on the box displaying your username and organization name. Then please click on the 'My Account' button.

On the resulting page, please select 'API tokens' the third option in the horizontal navigation bar under 'My Account'. If you have an existing token, please copy and use it, otherwise please click the button labelled 'New Token' and then copy the result.

### Create a cluster

To create a VKE cluster, run the following command:
```yaml
vke cluster create --name <cluster name> --region us-west-2 -f sharedfolder -pr sharedproject -v 1.10.2-59 --privilegedMode
```

For region please use the value 'us-west-2'

You will be asked to acknowledge the creation of a piviliged mode Kubernetes cluster. Please enter 'Y' at the prompt.

### Get Kubectl and Helm

If it isn't already installed on your machine, please install the kubectl command line package for managing Kubernetes.

Kubectl can be pulled down in a variety of ways, including from the VKE UI (on the page for a smartcluster, select actions and then select the correct operating system for your device).

For Helm, please see the following page: [Helm](https://github.com/helm/helm)

### Access the VKE Cluster

To gain kubectl access to your VKE cluster via the command line use the following command:
```yaml
vke cluster merge-kubectl-auth <cluster name>
```

This will authenticate kubectl to your VKE cluster and set the correct context to access that cluster.

Correct funtionality can be verfied by successfully running 'kubectl get' commands against the cluster (kubectl get nodes, kubectl get pods, etc)

### Initiailize Helm

To setup Tiller (the cluster side component of Helm) in your VKE cluster, run the following command:
```yaml
helm init
helm repo update
```

The 'helm repo update' command pulls the most recent version of the charts in any repositiories mapped into Helm (stable by default) so as to avoid installing older versions of these components, which might introduce issues.

The `helm init` command will take a couple of minutes to run on the VKE cluster as it will cause the cluster to scale up and add a worker node.
This is expected, please move on to the 

## Clone this repository to your local machine and create an online copy

In order to feed the CI/CD pipeline automatically on a git push, you'll need to create an individual copy of this repository.

### Fork this repository

In order to have your own working copy of this repository, you'll want to fork it into your account.
1. First navigate to [http://github.com] and login to your account
2. Then navigate to the page for this repository [https://github.com/dillson/jw-workshop]
3. In the upper-right hand section of the screen, click on the button labeled 'Fork'

A copy of this repository will then be forked into your account

### Clone the repository

First pick a location on your local machine to clone the forked repository.

After ensuring that 'git' is installed, run this command:
```
git clone https://github.com/<your username>/jw-workshop.git
```
Comgratulations, you know have a local copy of this repository. It will be in a folder labeled 'jw-workshop'

## Helm Chart for CloudBees Core on VMware Kubernetes Engine (VKE) - based on [This repo by Jeff Fry](https://github.com/cloudbees/core-helm-vke)

### Create the Helm Chart

From folder 'jw-workshop' (root of the cloned repository), run:
```
helm package core-helm-vke/cloudbeescore
```

### Installation Instructions

1. Install Helm if not already installed.
```
helm init
```

2. Wait for the tiller pod to come up. This may take a few minutes.
```
kubectl -n kube-system get pods
```
```
NAME                             READY     STATUS    RESTARTS   AGE
tiller-deploy-5c688d5f9b-l27kk   1/1       Running   0          3m
```
3. Create a namespace for CloudBees Core to be installed in. 

```
kubectl create namespace cloudbees
```

4. Install an Nginx Ingress Controller with Helm. Ensure you specify the controller scope using the cloudbees namespace
```
kubectl create namespace ingress-nginx
```
```
kubectl create clusterrolebinding nginx-ingress-cluster-rule --clusterrole=cluster-admin --serviceaccount=ingress-nginx:nginx-ingress
```
```
helm install --namespace ingress-nginx --name nginx-ingress stable/nginx-ingress --version 0.23.0 --set rbac.create=true --set controller.service.externalTrafficPolicy=Local --set controller.scope.enabled=true --set controller.scope.namespace=cloudbees
```
4. Wait for the _Load Balancer Ingress_ field to populate. This is the hostname that will be used in the next step. This may take a few minutes and require multiple runs before the value populates.
```
kubectl describe service nginx-ingress-controller -n ingress-nginx
```
5. Install CloudBees Core. The <lb-ingress-hostname> value is included in the output of the previous command.
```
helm install core-helm-vke/cloudbeescore --set cjocHost=<lb-ingress-hostname> --namespace cloudbees
```
6. Monitor the progress.
```
kubectl rollout status sts cjoc --namespace cloudbees
```
7. Wait for success message.
```
statefulset rolling update complete 1 pods at revision cjoc-59cc694b8b...
```
8. Go to ```http://<lb-ingress-hostname>/cjoc```
9. Get the initial admin password.
```
kubectl exec cjoc-0 cat /var/jenkins_home/secrets/initialAdminPassword --namespace cloudbees
```
10. 10. Follow the instructions in the setup wizard. Request a trial license.

## Cloudbees configuration and pipeline creation

### Team Onboarding
1. Click on the _Teams_ menu item.
2. Follow the team creation wizard.
3. Specify a name for team.
4. Choose an icon.
5. Add people.
6. Select a team recipe.
7. Wait for a few minutes for the Jenkins Master to be created.

### Jenkins Plugin Configuration

1. Use the horizontal navigation bar at the top of the screen to navigate to the leftmost 'Jenkins'
2. From the vertical navigation bar on the left edge of the screen, select 'Manage Jenkins' -> 'Manage Plugins'
3. Select the 'Available' tab from the top of the main panel. Then search down the list for 'GitHub plugin'. Check the box for this plugin, then click the 'Install without restart' button at the bottom of the screen

### Pipeline setup

Return to the main screen of the Cloudbees Jenkins Operations Center by using the horizontal navigation bar at the top of the screen again. Click on the leftmost entry 'Jenkins'

1. Click on the 'Teams >> {name}' link in the middle of the main panel. The name will be the value you specified when creating a team earlier.
2. From the vertical navigation bar on the left edge of the screen, click 'New Item'
3. Select the 'Pipeline' type from the list. Be sure to give it a name. Then click the 'OK' button at the bottom of the screen.
4. On the following screen, Check the box in the 'General' section reading 'GitHub Project'. A text box will then appear and ask for the project URL. Use the URL of **your** forked Github repository. Likely of the form, "github.com/'username'/jw-workshop".
5. Under the 'Build Triggers' section, check the box labeled 'GitHub hook trigger for GITScm polling'. This will enable the desired 'build on git push' behavior.