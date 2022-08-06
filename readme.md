# Spring Pet Clinic Demo

Source code repo of the java spring boot Pet Clinic sample application. Below is the step by step guide for bootstrapping the application.

## Dependencies
### Code
- JDK 11 or newer
- Maven 3.X
- Git 2.X
### Infra
- Jenkins 2.3.X
- Docker 20.X
- Kubernetes 1.22
- Helm 3.X
  

## Bootstrapping the application
### Clone
Clone the git repo by running the below command.
```
git clone https://github.com/roshankadasani/spring-petclinic.git
```

### Package
Using the below maven command package the java application into a jar file. The jar will be placed in the `target/` folder. 
```
mvn clean package
```

### Run
Using the below java command run start the application.
```
java -jar target/*.jar
```

## Jenkins in Kubernetes
Below are the steps to spin up jenkins server in a Kubernetes cluster. Before proceeding please ensure you have access to deploying resources into a remote or local kubernetes cluster.

```
# Helm to deploy Jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm show values jenkins/jenkins > values.yaml
kubectl create ns jenkins
helm upgrade --install jenkins jenkins/jenkins -f ./values.yaml --wait --namespace jenkins
```

### Pipeline to build and package the application
The `Jenkinsfile` has various steps defined to build the jar file, build docker image, and publish the docker image to docker repo. As jenkins is running inside a kubernetes cluster, new pods will be spun up to perform the agent tasks.

```
stage('build-jar') {
      steps {
        container('maven') {
          sh 'mvn clean package -Djacoco.skip=true'
        }
      }
    }
    stage('build-docker-image') {
      steps {
        container('docker') {
          sh 'docker build --no-cache -t ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION_MAIN}.$BUILD_NUMBER .'
        }
      }
    }
```

## Building Docker Image
Once the jar file is created by maven, the command can be executed to build the docker image and run the application as docker container. `Dockerfile` is placed in the parent folder.

```
docker build --no-cache -t <IMAGE_NAME>:<IMAGE_VERSION> .
docker run -p 8080:8080 <IMAGE_NAME>:<IMAGE_VERSION>

##Example
docker build --no-cache -t spring-petclinic:latest .
docker run -p 8080:8080 spring-petclinic:latest
```

The application can be accessed on port `8080` - `http://localhost:8080/`


## Author
Source code - https://github.com/spring-projects/spring-petclinic
