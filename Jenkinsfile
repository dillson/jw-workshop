pipeline {
  agent {
    kubernetes {
        label 'docker-build-pod'
        yamlFile 'podTemplate/jw-workshop-docker-build.yaml'
    }
  }
  stages {
    stage('Docker Build') {
      steps {
        container('docker'){
          sh 'docker build -t dillson/jw-workshop:latest .'
        }
      }
    }
    stage('Docker Push') {
      steps {
        container('docker'){
          withCredentials([usernamePassword(credentialsId: 'dockerhub', passwordVariable: 'dockerHubPassword', usernameVariable: 'dockerHubUser')]) {
            sh "docker login -u ${env.dockerHubUser} -p ${env.dockerHubPassword}"
            sh 'docker push dillson/jw-workshop:latest'
          }
        }
      }
    }
    stage('Deploy to VKE cluster') {
      steps {
        container('vke-kubectl'){
          withCredentials([usernamePassword(credentialsId: 'VCS', usernameVariable: 'orgID', passwordVariable: 'apiToken')]) {
            sh "vke account login -t ${env.orgID} -r ${env.apiToken}"
            sh '''
                 vke cluster merge-kubectl-auth cb-test-59
		 kubectl delete namespace jw-workshop || true
                 sleep 5
                 kubectl create namespace jw-workshop
                 kubectl run jw-workshop-docker-build --image=dillson/jw-workshop:latest --port 8080 --namespace jw-workshop
                 kubectl expose deployment -n jw-workshop jw-workshop-docker-build --type=NodePort --nodePort 30480 --name=jw-workshop-svc
                 echo "Node Server Launched!"
            '''
          }
        }
      }
    }
  }
}
