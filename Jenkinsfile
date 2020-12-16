pipeline {
    agent any
    tools{
        terraform 'terraform'
        maven 'apache-maven-3.6.3'
    }

    parameters {
            choice(name: 'port', choices: ['60001', '60002', '60003', '60004', '60005', '60006', '60007', '60008', '60009', '60010'], description: 'Port')
            choice(name: 'action', choices: ['apply', 'destroy'])
            choice(name: 'environment', choices: ['dev', 'prod'])
            string(name: 'deployPort', defaultValue: '80', description: 'Port which will be used by application on deployed environment')
            choice(name: 'action type (ignore inf action destroy)'), choices: ['start_new', 'update'])
    }

    stages{
        stage('Get Application code'){
            when{ expression { params.action != 'destroy'}}
                steps{
                    sh "rm -rf target app.jar"
                    git branch: $environment, url: 'https://github.com/dklocek/SortAlgorithms.git'
                }
        }

        stage('Build'){
            when{ expression { params.action != 'destroy'}}
            steps{
                sh 'mvn package'
                sh 'mv target/*.jar app.jar'
            }
        }

        stage('Prepare'){
            when{ expression { params.action != 'destroy'}}
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
            when{ expression { params.action != 'destroy'}}
            steps{
                script{
                    withEnv(['JENKINS_NODE_COOKIE=dontkill']){
                        sh 'nohup java -Dserver.port=$port -jar app.jar --server.port=$port &'
                        sh 'sleep 10'
                        sh 'python3.8 scripts/test.py -host http://localhost -port $port'
                        sh 'pkill -f app.jar '
                    }
                }
            }
        }

        stage('Build and test image'){
            when{ expression { params.action != 'destroy'}}
            steps{
                script{
                    sh """cat << EOF > Dockerfile \n \
                    FROM openjdk:8-jre-alpine \n \
                    RUN apk update \n RUN apk upgrade \n \
                    COPY "app.jar" "app.jar" \n \
                    EXPOSE ${port} \n \
                    CMD ["-jar", "-Dserver.port=${deployPort}", "app.jar" ] \n \
                    ENTRYPOINT ["java"]"""
                    sh "docker build -t app ."
                    sh "docker run -d -p $deployPort:$deployPort --name app app"
                    sh 'docker network create testNetwork'
                    sh 'docker network connect testNetwork jenkins'
                    sh 'docker network connect testNetwork app'
                    sh 'sleep 10'
                    sh 'python3.8 scripts/test.py -host http://app -port $deployPort'
                    sh 'docker network disconnect testNetwork app'
                    sh 'docker network disconnect testNetwork jenkins'
                    sh 'docker network rm testNetwork'
                    sh 'docker stop app'
                    sh 'docker rm app'
                }
            }
        }

        stage('Push artifact to ECR'){
            when{ expression { params.action != 'destroy'}}
            steps{
                script{
                    withAWS(credentials: 'aws_creds', region: 'eu-west-1'){
                        sh 'aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 329794110703.dkr.ecr.eu-west-1.amazonaws.com'
                        sh 'docker tag app 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker push 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker rmi 329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER'
                        sh 'docker rmi app'
                        sh 'bash cleanup.sh'
                    }
                }
            }
        }

        stage('Deploy'){
            when{ expression { params.action != 'destroy' && params.action == 'start_new'}}
            steps{
                withAWS(credentials: 'aws_creds', region: 'eu-wes-1'){
                    sh 'terraform init'
                    sh 'terraform plan -var="ECR_Image=329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER" -out plan'
                    sh 'terraform apply --auto-approve plan'
                    sh ''
                }
            }
        }

        stage('Update'){
                    when{ expression { params.action != 'destroy' && params.action == 'update'}}
                    steps{
                        withAWS(credentials: 'aws_creds', region: 'eu-wes-1'){
                            sh 'terraform init'
                            sh 'terraform plan -var="ECR_Image=329794110703.dkr.ecr.eu-west-1.amazonaws.com/sorters:$BUILD_NUMBER" -out plan'
                            sh 'terraform apply --auto-approve plan'
                        }
                    }
                }

        stage('Destroy'){
            when{ expression { params.action == 'destroy'}}
                steps{
                    sh 'terraform destroy --auto-approve'
                }
        }
    }
}