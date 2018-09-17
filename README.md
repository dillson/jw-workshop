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

Download the CLI package from the button in the bottom left corner of the screen labeled 'Download CLI' and slecting the correct operating system. Make sure it has execute permissions.

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
vke cluster create --name <name> --region <region> -f sharedfolder -pr sharedproject
```

For region please use the value 'us-west-2'

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

## Helm Chart for CloudBees Core on VMware Kubernetes Engine (VKE) - based on [This repo by Jeff Fry](https://github.com/cloudbees/core-helm-vke)

### Create the Helm Chart
```
helm package ./CloudBeesCore
```

### Installation Instructions

1. Choose a ```<cloudbees namespace>``` for CloudBees Core. 'cloudbees' is the recommended value.
2. Install an Ingress Controller fron the [stable helm chart](https://github.com/helm/charts/tree/master/stable/nginx-ingress).
```
helm install --namespace ingress-nginx --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.service.externalTrafficPolicy=Local            --set controller.scope.enabled=true --set controller.scope.namespace=<cloudbees namespace>
```
3. Wait for the _Load Balancer Ingress_ hostname.
```
kubectl describe service nginx-ingress-controller -n ingress-nginx
```
4. Install CloudBees Core.
```
helm install cloudbeescore --set cjocHost=<lb-ingress-hostname> --namespace <cloudbees namespace>
```
5. Monitor the progress.
```
kubectl rollout status sts cjoc --namespace <cloubees namespace>
```
6. Wait for success message.
```
statefulset rolling update complete 1 pods at revision cjoc-59cc694b8b...
```
7. Go to ```http://<lb-ingress-hostname>/cjoc```
8. Get the initial admin password.
```
kubectl exec cjoc-0 cat /var/jenkins_home/secrets/initialAdminPassword --namespace <cloudbees namespace>
```
9. Follow the instructions in the setup wizard. Request a trial license and fill in the short form.

### Team Onboarding
1. Click on the _Teams_ menu item.
2. Follow the team creation wizard.
3. Specify a name for team.
4. Choose an icon.
5. Add people.
6. Select a team recipe.
7. Wait for a few minutes for the Jenkins Master to be created.

## Clone and upload a copy of the workshop Github repository

Make 