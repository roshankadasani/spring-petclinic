pipeline {
  agent {
    kubernetes {
      yaml'''
        apiVersion: v1
        kind: Pod
        metadata:
          name: dynamic-worker
        spec:
          containers:
          - name: maven
            image: maven:latest
            command: ["tail", "-f", "/dev/null"]
            imagePullPolicy: Always
            tty: true
          - name: docker
            image: docker:latest
            command: ["tail", "-f", "/dev/null"]
            tty: true
            volumeMounts: 
            - mountPath: /var/run/docker.sock
              name: docker-sock
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
      '''
    }
  }

  environment {
    JFROG_ARTIFACTORY_REPO_NAME = 'rkdemo.jfrog.io/rk-demo-docker'
    DOCKER_IMAGE_NAME = 'spring-petclinic'
    DOCKER_IMAGE_VERSION_MAIN = 'v0.0'
  }

  stages {
    stage('pull-repo-src') {
      steps {
        container('maven') {
          git branch: 'master', 
            changelog: false, 
            poll: false, 
            url: 'https://github.com/roshankadasani/spring-petclinic.git'
        }
      }
    }
    stage('build-jar') {
      steps {
        container('maven') {
          sh 'mvn clean package -Djacoco.skip=true'
        }
      }
    }
    stage('push-jar') {
      steps {
        container('maven') {
          sh 'mvn deploy -Djacoco.skip=true'
        }
      }
    }
    stage('build-docker-image') {
      steps {
        container('docker') {
          sh 'docker build --no-cache -t ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION_MAIN}.$BUILD_NUMBER .'
          sh 'docker tag ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION_MAIN}.$BUILD_NUMBER ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:latest'
        }
      }
    }
    stage('push-docker-image') {
      steps {
        container('docker') {
          withCredentials([usernamePassword(credentialsId: 'jfrog-rk-demo', passwordVariable: 'jfrogArtifactoryPassword', usernameVariable: 'jfrogArtifactoryUsername')]) {
          sh "docker login -u ${env.jfrogArtifactoryUsername} -p ${env.jfrogArtifactoryPassword} rkdemo.jfrog.io"
          sh 'docker push ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION_MAIN}.$BUILD_NUMBER'
          sh 'docker push ${JFROG_ARTIFACTORY_REPO_NAME}/${DOCKER_IMAGE_NAME}:latest'
          }
        }
      }
    }
  }
}