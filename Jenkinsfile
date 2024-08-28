pipeline {
    agent { label 'onpremise' }  // 'onpremise' 라벨을 가진 에이전트에서만 실행

    environment {
        DOCKER_IMAGE = 'Harbor/project/team3app'  // Harbor 프로젝트 및 이미지 이름
        IMAGE_TAG = "${env.BUILD_ID}"  // Jenkins 빌드 ID를 이미지 태그로 사용
        REGISTRY_CREDENTIALS = 'harbor'  // Jenkins에 저장된 자격 증명 ID
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
                script {
                    // Kubernetes 매니페스트 파일에서 이미지 태그를 업데이트
                    sh '''
                    sed -i "s|image: .*$|image: ${DOCKER_IMAGE}:${IMAGE_TAG}|" /home/admin/onpremisecicd/deployment.yaml
                    git config user.email "chojo480912@gmail.com"
                    git config user.name "mincheol07"
                    git add /home/admin/onpremisecicd/deloyment.yaml
                    git commit -am "Update image tag to ${IMAGE_TAG}"
                    git push origin main
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