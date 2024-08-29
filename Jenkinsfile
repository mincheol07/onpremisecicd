pipeline {
    agent { label 'onpremise' }  // 'onpremise' 라벨을 가진 에이전트에서만 실행

    environment {
        DOCKER_IMAGE = 'Harbor/project/team3app'  // Harbor 프로젝트 및 이미지 이름
        IMAGE_TAG = "${env.BUILD_ID}"  // Jenkins 빌드 ID를 이미지 태그로 사용
        REGISTRY_CREDENTIALS = 'harbor'
        GIT_CREDENTIALS_ID = 'github'  // Jenkins에 저장된 자격 증명 ID
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                git branch: 'main', url: 'https://github.com/mincheol07/onpremisecicd.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to Harbor') {
            steps {
                script {
                    docker.withRegistry('https://Harbor', REGISTRY_CREDENTIALS) {
                        dockerImage.push()
                    }
                }
            }
        }

         stage('Update Kubernetes Manifests') {
            steps {
               withCredentials([usernamePassword(credentialsId: "${GIT_CREDENTIALS_ID}", passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                    sh '''
                    cd /home/admin/manifest/
                    sed -i "s|image: .*$|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|" deployment.yaml
                    git add .
                    git config user.email "chojo480912@gmail.com"
                    git config user.name "mincheol07"
                    git commit -m "Update image tag to ${IMAGE_TAG}"
                    git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/your-org/your-repo.git HEAD:main
                    '''
                }
            }
        }



        
    }

    post {
        always {
            cleanWs()
        }
    }
}