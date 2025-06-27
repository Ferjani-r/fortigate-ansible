pipeline {
    agent any

    environment {
        FG_API_TOKEN = credentials('fortigate_api_token') // Jenkins credentials ID
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
                    // Run bash explicitly to avoid "Bad substitution" error
                    sh '''
                        #!/bin/bash
                        mkdir -p backups

                        # Example command that might use FG_API_TOKEN or other bash syntax
                        echo "Running backup with token: $FG_API_TOKEN"

                        # Run your ansible-playbook command here, for example:
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
