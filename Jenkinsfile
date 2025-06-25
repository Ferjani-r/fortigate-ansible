pipeline {
    agent any

    environment {
        FG_API_TOKEN = credentials('fortigate_api_token')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Ferjani-r/fortigate-ansible.git'
            }
        }

        stage('Add Interface') {
            steps {
                sh '''
                export ANSIBLE_HTTPAPI_SESSION_KEY="{\\"access_token\\":\\"$FG_API_TOKEN\\"}"
                ansible-playbook -i hosts add_interface.yml
                '''
            }
        }

        stage('Add Route') {
            steps {
                sh '''
                export ANSIBLE_HTTPAPI_SESSION_KEY="{\\"access_token\\":\\"$FG_API_TOKEN\\"}"
                ansible-playbook -i hosts route.yml
                '''
            }
        }
    }
}
