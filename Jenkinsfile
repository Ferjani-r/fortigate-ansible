pipeline {
    agent any

    triggers {
        cron('H/10 * * * *') // Runs every 5 minutes to reduce API load
    }

    environment {
        FG_API_TOKEN = credentials('FG_API_TOKEN') // Credential ID for FortiGate API token
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm // Pulls the latest code from the Git repository
            }
        }

        stage('Check & Back-up DOWN Interfaces') {
            steps {
                withCredentials([string(credentialsId: 'FG_API_TOKEN', variable: 'FG_API_TOKEN')]) {
                    sh '''
                        set -e
                        mkdir -p backups
                        TOKEN_PREVIEW=$(echo "${FG_API_TOKEN}" | cut -c1-5)
                        echo "Running backup with token: ${TOKEN_PREVIEW}*****"

                        ansible-playbook -i hosts \
                          -e '{"ansible_httpapi_session_key": {"access_token": "'${FG_API_TOKEN}'"}}' \
                          --retry-files-enabled \
                          --retries 3 \
                          --delay 10 \
                          check_and_backup_interfaces.yml
                    '''
                }
            }
        }

        stage('Archive Backups') {
            when {
                expression { fileExists('backups') && sh(returnStatus: true, script: 'ls -1 backups/*.yml 2>/dev/null') == 0 }
            }
            steps {
                archiveArtifacts artifacts: 'backups/*.yml', fingerprint: true // Archives backup files
            }
        }
    }

    post {
        failure { echo '❌ Build failed' }
        success { echo '✅ Build succeeded' }
    }
}
