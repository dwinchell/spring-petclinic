pipeline {
   agent {
        kubernetes {
            cloud 'openshift'
            defaultContainer 'default'
            yaml """
apiVersion: v1
kind: Pod
spec:
    serviceAccount: jenkins
    containers:
    - name: 'jnlp'
      image: "ploigos/ploigos-ci-agent-jenkins:latest"
      tty: true
      volumeMounts:
      - mountPath: '/home/ploigos'
        name: home-ploigos
    - name: 'default'
      image: "ploigos/ploigos-tool-maven:latest"
      tty: true
      volumeMounts:
      - mountPath: '/home/ploigos'
        name: home-ploigos
    - name: 'buildah'
      image: 'ploigos/ploigos-tool-containers:latest'
      tty: true
      securityContext:
        capabilities:
            add:
            - 'SETUID'
            - 'SETGID'
      volumeMounts:
      - mountPath: '/home/ploigos'
        name: home-ploigos
    volumes:
    - name: home-ploigos
      emptyDir: {}
"""
        }
    }
    stages {
        stage('Generate Metadata') {
            steps {
                sh "psr -s generate-metadata -c psr.yaml"
            }
        }
        stage('Unit Test') {
            steps {
                sh "psr -s unit-test -c psr.yaml"
            }
        }
        stage('Package') {
            steps {
                sh "psr -s package -c psr.yaml"
            }
        }
        stage('Create Container Image') {
            steps {
                sh "psr -s create-container-image -c psr.yaml"
            }
        }
    }
}

