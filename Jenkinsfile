pipeline {
    agent any
    tools{
        terraform 'terraform'
        maven 'apache-maven-3.6.3'
    }

    parameters {
            choice(name: 'port', choices: ['50001', '50002', '50003', '50004', '50005', '50006', '50007', '50008', '50009', '50010'], description: 'Port')
            choice(name: 'action', choices: ['apply', 'destroy'])
    }

    stages{
        stage('Get Application code'){
            when{ expression { params.action != 'destroy'}}
                steps{
                    git branch: 'master', url: 'https://github.com/dklocek/SortAlgorithms.git'
                }
        }

        stage('Build'){
            steps{
                sh 'mvn package'
            }
        }

        stage('Run & Local Test'){

        }
    }
}