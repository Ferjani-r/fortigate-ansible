pipeline {
    agent any                                  // gives every stage a workspace

    triggers {                                 // every 2 minutes
        cron('H/2 * * * *')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check & back‑up DOWN interfaces') {
            steps {
                withCredentials([string(credentialsId: 'fortigate_api_token',
                                         variable: 'FG_API_TOKEN')]) {
                    sh '''
                        set -e
                        mkdir -p backups          # ensure dir exists
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
        failure  { echo '❌  Build failed'  }
        success  { echo '✅  Build succeeded' }
    }
}
