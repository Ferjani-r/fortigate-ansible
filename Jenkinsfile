pipeline {
    agent any

    triggers {
        cron('H/2 * * * *')
    }

    environment {
        FG_API_TOKEN = credentials('FG_API_TOKEN')
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
                    sh """
                        set -e
                        mkdir -p backups
                        TOKEN_PREVIEW=\$(expr substr \$FG_API_TOKEN 1 5)
                        echo "Running backup with token: \${TOKEN_PREVIEW}*****"

                        ansible-playbook -i hosts \\
                          --extra-vars 'ansible_httpapi_session_key={"access_token":"\$FG_API_TOKEN"}' \\
                          check_and_backup_interfaces.yml
                    """
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
