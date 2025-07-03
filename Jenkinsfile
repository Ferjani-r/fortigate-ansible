pipeline {
    agent any

    triggers {
        cron('H/30 * * * *') // Runs every 10 minutes
    }

    environment {
        MYSQL_USER = 'observium' // From config.php
        MYSQL_PASS = credentials('OBSERVIUM_DB_PASSWORD') // Set to 'admin' in Jenkins
        MYSQL_HOST = 'localhost' // From config.php
        MYSQL_DB   = 'observium' // From config.php
        FORTIGATE_DEVICE_IP = '172.17.120.21'
        FG_API_TOKEN = credentials('FG_API_TOKEN') // Use existing FortiGate API token
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Query Observium Database') {
            steps {
                withCredentials([string(credentialsId: 'OBSERVIUM_DB_PASSWORD', variable: 'DB_PASS')]) {
                    sh '''
                        set -e
                        mkdir -p observium_data
                        # Query database for interface statuses with proper escaping
                        mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p"${DB_PASS}" ${MYSQL_DB} -e "SELECT p.port_id, d.hostname, p.ifName, p.ifDescr, p.ifAdminStatus, p.ifOperStatus FROM ports AS p JOIN devices AS d ON p.device_id = d.device_id WHERE d.hostname = \\"${FORTIGATE_DEVICE_IP}\\";" > observium_discovery.log
                        # Extract down interfaces using tab as delimiter
                        DOWN_INTERFACES=$(grep -i "down" observium_discovery.log | tail -n +2 | awk '{print $3}' || true)
                        echo "Down interfaces from Observium: $DOWN_INTERFACES"
                        # Backup down interfaces using API token
                        if [ -n "$DOWN_INTERFACES" ]; then
                            TIMESTAMP=$(date +%Y%m%d_%H%M%S)
                            for INTERFACE in $DOWN_INTERFACES; do
                                ./backup_interface.sh "${FORTIGATE_DEVICE_IP}" "${INTERFACE}" "${FG_API_TOKEN}" "observium_data/backup_${TIMESTAMP}_${INTERFACE}.conf"
                            done
                        fi
                    '''
                }
            }
        }

        stage('Validate Output') {
            when {
                expression { fileExists('observium_discovery.log') }
            }
            steps {
                sh '''
                    set -e
                    if [ ! -s observium_discovery.log ]; then
                        echo "Error: observium_discovery.log is empty"
                        exit 1
                    fi
                    cat observium_discovery.log
                '''
            }
        }

        stage('Archive Results') {
            when {
                expression { fileExists('observium_discovery.log') }
            }
            steps {
                archiveArtifacts artifacts: 'observium_discovery.log,observium_data/backup_*.conf', fingerprint: true
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
