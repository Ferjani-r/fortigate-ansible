pipeline {
    agent any

    triggers {
        // Run every 2 minutes
        cron('H/2 * * * *')
    }

    environment {
        FG_API_TOKEN = credentials('fortigate_api_token')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check & Backup DOWN Interfaces') {
            steps {
                withCredentials([string(credentialsId: 'fortigate_api_token', variable: 'FG_API_TOKEN')]) {
                    sh '''
                        #!/bin/bash
                        mkdir -p backups
                        echo "Running backup with token: $FG_API_TOKEN"
                        ansible-playbook -i hosts check_and_backup_interfaces.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'backups/*.yml', allowEmptyArchive: true
        }
        failure {
            echo 'Build failed!'
        }
        success {
            echo 'Build succeeded!'
        }
    }
}
