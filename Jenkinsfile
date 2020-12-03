pipeline {
    agent any
    tools{
        terraform 'terraform'
        maven 'apache-maven-3.6.3'
    }

    parameters {
            choice(name: 'port', choices: ['60001', '60002', '60003', '60004', '60005', '60006', '60007', '60008', '60009', '60010'], description: 'Port')
            choice(name: 'action', choices: ['apply', 'destroy'])
    }

    stages{
        stage('Get Application code'){
            when{ expression { params.action != 'destroy'}}
                steps{
                    sh "rm -rf target app.jar"
                    git branch: 'master', url: 'https://github.com/dklocek/SortAlgorithms.git'
                }
        }

        stage('Build'){
            steps{
                sh 'mvn package'
                sh 'mv target/*.jar app.jar'
            }
        }

        stage('Prepare'){
            steps{
                script{
                    git branch: 'dev', url: 'https://github.com/dklocek/AWS-ECS-Terraform-Jenkins-JavaApp-Deploy.git'
                    try{
                        sh "bash cleanup.sh"
                        sh 'pkill -f app.jar'
                    }catch(Exception e){
                        echo e.toString()
                    }
                }
            }
        }
        stage('Run & Local Test'){
            steps{
                script{
                    withEnv(['JENKINS_NODE_COOKIE=dontkill']){
                        sh 'nohup java -Dserver.port=$port -jar app.jar --server.port=$port &'
                        sh 'sleep 10'
                        sh 'python3.8 tests/a.py -host http://localhost -port $port'
                        sh 'pkill -f app.jar '
                    }
                }
            }
        }

        stage('Build and test image'){
            steps{
                script{
                    sh """cat << EOF > Dockerfile \n \
                    FROM openjdk:8-jre-alpine \n \
                    RUN apk update \n RUN apk upgrade \n \
                    COPY "app.jar" "app.jar" \n \
                    EXPOSE ${port} \n \
                    CMD ["-jar", "-Dserver.port=${port}", "app.jar" ] \n \
                    ENTRYPOINT ["java"]"""
                    sh "docker build -t app ."
                    sh "docker run -d -p $port:$port --name app app"
                    sh 'docker network create testNetwork'
                    sh 'docker network connect testNetwork jenkins'
                    sh 'docker network connect testNetwork app'
                    sh 'python3.8 tests/a.py -host http://app -port $port'
                    sh 'sleep 2'
                    sh 'docker network disconnect testNetwork app'
                    sh 'docker network disconnect testNetwork jenkins'
                    sh 'docker network rm testNetwork'
                    sh 'docker stop app'
                    sh 'docker rm app'
                }
            }
        }

        stage('Push artifact to ECR'){
            steps{
                script{
                    withAWS(credentials: 'aws_creds', region: 'eu-west-1'){
                        sh 'aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 329794110703.dkr.ecr.eu-west-1.amazonaws.com'
                        sh 'docker tag app 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker push 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker rmi 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker rmi app'
                    }
                }
            }
        }

        stage('Deploy'){
            steps{
                withAWS(credentials: 'aws_creds', region: 'eu-wes-1'){
                    sh 'terraform init'
                    sh 'terraform plan -var="ECR_Image=329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER"'
                }
            }
        }
    }
}