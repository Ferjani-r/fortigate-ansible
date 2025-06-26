pipeline {
    agent any

    environment {
        FG_API_TOKEN = credentials('fortigate_api_token')
    }

    parameters {
        choice(name: 'PLAYBOOK', choices: ['add_interface.yml', 'route.yml'], description: 'Choose which playbook to run')
        string(name: 'INTERFACE_NAME', defaultValue: 'port2', description: 'Interface name (if applicable)')
        string(name: 'INTERFACE_IP', defaultValue: '192.168.2.1 255.255.255.0', description: 'IP address + mask (if applicable)')
    }

    stages {
        stage('Run Ansible') {
            steps {
                script {
                    // Optional: create a dynamic playbook file with parameters
                    if (params.PLAYBOOK == 'add_interface.yml') {
                        writeFile file: 'dynamic_interface.yml', text: """
---
- name: Configure FortiGate Interface
  hosts: fortigate
  gather_facts: false
  connection: httpapi
  collections:
    - fortinet.fortios
  tasks:
    - name: Create or modify interface ${params.INTERFACE_NAME}
      fortinet.fortios.fortios_system_interface:
        vdom: "root"
        state: "present"
        system_interface:
          name: "${params.INTERFACE_NAME}"
          ip: "${params.INTERFACE_IP}"
          allowaccess:
            - ping
            - https
            - ssh
          type: "physical"
                        """
                        sh '''
                          export ANSIBLE_HTTPAPI_SESSION_KEY='{"access_token":"$FG_API_TOKEN"}'
                          ansible-playbook -i hosts dynamic_interface.yml
                        '''
                    } else {
                        // Run static playbook (e.g., route.yml)
                        sh '''
                          export ANSIBLE_HTTPAPI_SESSION_KEY='{"access_token":"$FG_API_TOKEN"}'
                          ansible-playbook -i hosts $PLAYBOOK
                        '''
                    }
                }
            }
        }
    }
}
