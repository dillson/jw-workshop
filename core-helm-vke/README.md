# Helm Chart for CloudBees Core on VMware Kubernetes Engine (VKE)

## Create the Helm Chart
```
helm package ./CloudBeesCore
```

## Installation Instructions

1. Choose a ```<namespace>``` for CloudBees Core.
2. Install an Ingress Controller.
```
helm install --namespace ingress-nginx --name nginx-ingress stable/nginx-ingress              --set rbac.create=true              --set controller.service.externalTrafficPolicy=Local              --set controller.scope.enabled=true              --set controller.scope.namespace=<namespace>
```
3. Wait for the _Load Balancer Ingress_ hostname.
```
kubectl describe service nginx-ingress-controller -n ingress-nginx
```
4. Install CloudBees Core.
```
helm install cloudbeescore --set cjocHost=<lb-ingress-hostname> --namespace <namespace>
```
5. Monitor the progress.
```
kubectl rollout status sts cjoc --namespace <namespace>
```
6. Wait for success message.
```
statefulset rolling update complete 1 pods at revision cjoc-59cc694b8b...
```
7. Go to ```http://<lb-ingress-hostname>/cjoc```
8. Get the initial admin password.
```
kubectl exec cjoc-0 cat /var/jenkins_home/secrets/initialAdminPassword --namespace <namespace>
```
9. Follow the instructions in the setup wizard. You may request a trial license.

## Team Onboarding
1. Click on the _Teams_ menu item.
2. Follow the team creation wizard.
3. Specify a name for team.
4. Choose an icon.
5. Add people.
6. Select a team recipe.
7. Wait for a few minutes for the Jenkins Master to be created.

## Create a Pipeline from an Existing Repo
1. Click on _Pipelines_.
2. Click _New Pipeline_.
3. Select your repo provider.
4. Provide your access token.
5. Select your repo.