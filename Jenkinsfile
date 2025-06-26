pipeline {
    agent any
    environment {
        FG_API_TOKEN = credentials('fortigate_api_token')
    }

    triggers {
        cron('H/5 * * * *')  // every 5 minutes
    }

    stages {
        stage('Check & Backup DOWN Interfaces') {
            steps {
                sh '''
                  mkdir -p backups
                  export ANSIBLE_HTTPAPI_SESSION_KEY='{"access_token":"$FG_API_TOKEN"}'
                  ansible-playbook -i hosts check_and_backup_interfaces.yml
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'backups/*.yml', fingerprint: true
        }
    }
}
