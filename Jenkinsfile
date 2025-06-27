node {
    pipeline {
        agent none  // no agent here since we have node block

        environment {
            FG_API_TOKEN = credentials('fortigate_api_token') // Jenkins credentials ID
        }

        stages {
            stage('Checkout') {
                agent any
                steps {
                    checkout scm
                }
            }

            stage('Check & Backup DOWN Interfaces') {
                agent any
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
}
