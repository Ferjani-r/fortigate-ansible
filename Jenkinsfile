pipeline {
    agent any

    environment {
        ANSIBLE_HTTPAPI_AUTH_TYPE = 'token'
        ANSIBLE_HTTPAPI_USE_SSL = 'true'
        ANSIBLE_HTTPAPI_VALIDATE_CERTS = 'false'
        ANSIBLE_HTTPAPI_PORT = '443'
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/Ferjani-r/fortigate-ansible.git', branch: 'main'
            }
        }

        stage('Check & Backup DOWN Interfaces') {
            steps {
                withCredentials([string(credentialsId: 'FG_API_TOKEN', variable: 'FG_API_TOKEN')]) {
                    sh '''
                        mkdir -p backups
                        echo "Testing token injection: ${FG_API_TOKEN:0:5}*****"  # Optional for debugging

                        ansible-playbook -i hosts check_and_backup_interfaces.yml \
                          --extra-vars "ansible_httpapi_token=${FG_API_TOKEN}"
                    '''
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'backups/*.yml', onlyIfSuccessful: true
        }
    }
}
