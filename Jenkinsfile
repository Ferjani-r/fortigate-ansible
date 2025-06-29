pipeline {
    agent any

    triggers {
        cron('H/2 * * * *') // every 2 minutes
    }

    environment {
        FG_API_TOKEN = credentials('FG_API_TOKEN')  // your Jenkins credential ID
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check & back‑up DOWN interfaces') {
            steps {
                withCredentials([string(credentialsId: 'FG_API_TOKEN', variable: 'FG_API_TOKEN')]) {
                    sh '''
                        #!/bin/bash
                        set -e
                        mkdir -p backups
                        echo "Running backup with token: ${FG_API_TOKEN:0:5}*****"

                        ansible-playbook -i hosts \
                                         --extra-vars "ansible_httpapi_session_key={\\"access_token\\":\\"$FG_API_TOKEN\\"}" \
                                         check_and_backup_interfaces.yml
                    '''
                }
            }
        }

        stage('Archive backups') {
            when {
                expression { fileExists('backups') && sh(returnStatus: true, script: 'ls -1 backups/*.yml 2>/dev/null') == 0 }
            }
            steps {
                archiveArtifacts artifacts: 'backups/*.yml', fingerprint: true
            }
        }
    }

    post {
        failure  { echo '❌  Build failed' }
        success  { echo '✅  Build succeeded' }
    }
}
