pipeline {
    agent any

    triggers {
        cron('H/10 * * * *') // Runs every 10 minutes
    }

    environment {
        FG_API_TOKEN = credentials('FG_API_TOKEN')
        OBSERVIUM_CREDENTIALS = credentials('OBSERVIUM_CREDENTIALS') // Username: observium, Password: admin
        OBSERVIUM_PATH = '/opt/observium'
        FORTIGATE_DEVICE_IP = '172.17.120.21'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run Observium Discovery') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'OBSERVIUM_CREDENTIALS', usernameVariable: 'OBSERVIUM_USER', passwordVariable: 'OBSERVIUM_PASS')]) {
                    sh '''
                        set -e
                        mkdir -p observium_data
                        # Run discovery and capture output/stderr, exit on failure
                        if ! sudo -u observium ${OBSERVIUM_PATH}/observium-wrapper discovery --host ${FORTIGATE_DEVICE_IP} > observium_discovery.log 2>&1; then
                            cat observium_discovery.log
                            exit 1
                        fi
                        cat observium_discovery.log
                        echo "Observium discovery completed for ${FORTIGATE_DEVICE_IP}"
                    '''
                }
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
                          -e "{'ansible_httpapi_session_key': {'access_token': '${FG_API_TOKEN}'}}" \
                          check_and_backup_interfaces.yml > ansible_output.log

                        DOWN_INTERFACES=$(grep -A 10 "down_interfaces" ansible_output.log | grep -o '"name": "[^"]*"' | cut -d'"' -f4)
                        echo "Down interfaces from Ansible: $DOWN_INTERFACES"
                    '''
                }
            }
        }

        stage('Cross-Check with Observium') {
            steps {
                sh '''
                    set -e
                    # Parse discovery log for down interfaces (adjust based on log format)
                    DOWN_FROM_OBSERVIUM=$(grep -i "down" observium_discovery.log | grep -o "interface [a-zA-Z0-9-]*" | cut -d" " -f2 || true)
                    echo "Down interfaces from Observium: $DOWN_FROM_OBSERVIUM"

                    if [ -n "$DOWN_FROM_OBSERVIUM" ]; then
                        if ! grep -q "$DOWN_FROM_OBSERVIUM" <<< "$DOWN_INTERFACES"; then
                            echo "Warning: Observium detected down interfaces ($DOWN_FROM_OBSERVIUM) not matched by Ansible ($DOWN_INTERFACES). Triggering additional check."
                            ansible-playbook -i hosts \
                              -e "{'ansible_httpapi_session_key': {'access_token': '${FG_API_TOKEN}'}}" \
                              check_and_backup_interfaces.yml
                        fi
                    fi
                '''
            }
        }

        stage('Validate Backups') {
            when {
                expression { fileExists('backups') && sh(returnStatus: true, script: 'ls -1 backups/*.yml 2>/dev/null') == 0 }
            }
            steps {
                sh '''
                    set -e
                    for file in backups/*.yml; do
                        checksum=$(sha256sum "$file" | awk '{print $1}')
                        echo "Checksum for $file: $checksum"
                        if ! grep -q "interface" "$file"; then
                            echo "Validation failed: $file is corrupted"
                            exit 1
                        fi
                    done
                '''
            }
        }

        stage('Archive Backups') {
            when {
                expression { fileExists('backups') && sh(returnStatus: true, script: 'ls -1 backups/*.yml 2>/dev/null') == 0 }
            }
            steps {
                archiveArtifacts artifacts: 'backups/*.yml,observium_discovery.log,ansible_output.log', fingerprint: true
            }
        }
    }

    post {
        success {
            echo '✅ Build succeeded'
        }
        failure {
            echo '❌ Build failed'
        }
    }
}
