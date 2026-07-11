def buildAndPushTag(Map args) {
    def defaults = [
        registryUrl: 'https://index.docker.io/v1/.',
        credentialsId: 'dockerhub-credentials',
        dockerfileDir: "./",
        dockerfileName: "Dockerfile",
        buildArgs: "",
        pushLatest: false
    ]
    args = defaults + args
    docker.withRegistry('', args.credentialsId) {
        def image = docker.build("${args.image}:${args.buildTag}", "${args.buildArgs} ${args.dockerfileDir} -f ${args.dockerfileName}")
        image.push()
        if(args.pushLatest) {
            image.push("latest")
            sh "docker rmi --force ${args.image}:latest"
        }
        sh "docker rmi --force ${args.image}:${args.buildTag}"

        return "${args.image}:${args.buildTag}"
    }
     
}

pipeline {
     
  agent { label 'agent-docker-1' }
  environment {
        K8S_NAMESPACE = 'formazione-sou'
        CHART_PATH = 'helm-chart'
        HELM_APP = 'formazione-sou-app'
        IMAGE_NAME    = 'giulia00/formazione_sou_k8s'
    }

    stages {
        stage('Checkout') {
            steps {
                script{
                   checkout scm
                }
        }
        }
        stage('Tag version'){
            steps {
                script{
                    if(env.TAG_NAME){
                        env.IMAGE_TAG = env.TAG_NAME
                    }
                    else if (env.GIT_BRANCH == 'origin/main'){
                        env.IMAGE_TAG = "latest"
                    }
                    else if (env.GIT_BRANCH == 'origin/develop'){
                        env.IMAGE_TAG = "develop-${env.GIT_COMMIT}"
                    }

                }
            }
        }
        stage('Build') {
            steps {
                script{
                     buildAndPushTag(
                        image: 'giulia00/formazione_sou_k8s', 
                        buildTag: "${env.IMAGE_TAG}",
                    ) 
        }

    }
}
        stage('Deploy su cluster con Helm') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                        sh """
                            helm upgrade --install \
                            ${HELM_APP} \
                            ./${CHART_PATH} \
                            --namespace ${K8S_NAMESPACE} \
                            --set image.tag=${IMAGE_TAG} \
                            --kubeconfig "\${KUBECONFIG_FILE}"
                        """
                    }
                }
            }
        }
        stage('Export Deployment') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    sh """
                        kubectl get deployment formazione-sou-app-helm-chart \
                          -n formazione-sou \
                          -o yaml \
                          --server="https://10.0.2.2:8443" \
                          --insecure-skip-tls-verify\
                          --kubeconfig "\${KUBECONFIG_FILE}" \
                          > flask-deployment-export.yaml
                    """
                    sh 'bash script_check.sh'
                }
            }
        }
}

}
