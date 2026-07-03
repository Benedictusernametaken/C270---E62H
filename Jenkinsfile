pipeline {
    agent any

    // 🔒 Concurrent build protection: drops a build in queue if a teammate pushes to the same branch right after
    options {
        disableConcurrentBuilds()
    }

    environment {
        APP_NAME = 'nutritrack'
        // 1. 🔒 SECURITY LOCKDOWN: Inject the DB credentials dynamically out of Jenkins Secret Store
        // Create a 'Secret Text' credential in Jenkins called 'nutritrack-db-password'
        POSTGRES_USER     = 'nutri_admin'
        POSTGRES_PASSWORD = credentials('nutritrack-db-password') 
        POSTGRES_DB       = 'nutritrack_db'
        
        // App runtime environments
        FLASK_APP         = 'app.main'
        FLASK_ENV         = 'development'
        PYTHONPATH        = '/app'
    }

    stages {
        // STAGE 1: CLONE & PULL THE REPOSITORY
        stage('Checkout Code') {
            steps {
                echo 'Purging host workspace folder caches entirely...'
                deleteDir() 

                // Dynamically show exactly who pushed what branch
                echo "Pulling the latest codebase from branch: ${env.BRANCH_NAME ?: 'Target Branch'}..."
                checkout scm
            }
        }

        // STAGE 2: COMPILE & BUILD CONTAINERS
        stage('Docker Compile') {
            steps {
                echo '🧹 DEFENSIVE CLEANUP: Stripping any existing loose conflicting containers...'
                // This clears out any stale or crashed container using those exact static names before rebuilding
                sh 'docker rm -f nutritrack-frontend nutritrack-backend nutritrack-database || true'

                echo 'Orchestrating container builds via Docker Compose...'
                // Pass environment variables seamlessly to the compose build context
                sh 'docker compose build --no-cache --pull'
            }
        }

        // STAGE 3: RUN INTEGRATION & HEALTH CHECKS
        stage('Integration Testing') {
            steps {
                echo '🧹 DEFENSIVE CLEANUP: Stripping any existing loose project containers...'
                sh 'docker rm -f nutritrack-frontend* nutritrack-backend* nutritrack-database* || true'

                echo 'Launching isolated service architecture layers...'
                // The single quotes allow Docker Compose to read your OS environment metrics directly
                sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} up -d database frontend backend'
                
                echo 'Giving application services a brief moment to bind endpoints...'
                sh 'sleep 10' // Increased to 10s to give the database engine enough breathing room to boot up
                
                echo 'Printing system runtime status check...'
                sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} ps'
                
                echo 'Executing internal connection verification handshake...'
                    sh '''docker compose -p ${APP_NAME}_${BUILD_NUMBER} exec -T backend python -c "
import urllib.request, urllib.error
try:
    res = urllib.request.urlopen('http://localhost:5000/health-check', timeout=5)
    print('SUCCESS: Health check responded with status:', res.status)
except urllib.error.HTTPError as e:
    print('!!! HEALTH CHECK FAILED WITH STATUS:', e.code)
    print(e.read().decode('utf-8', errors='ignore'))
    exit(1)
"'''
            }

            post {
                always {
                    echo '=== CAPTURING BACKEND CONTAINER RUNTIME LOGS ==='
                    sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} logs backend'

                    echo '=== DIAGNOSTIC: CAPTURING DATABASE INITIALIZATION LOGS ==='
                    sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} logs database'
                    
                    echo 'Cleaning up active test environments...'
                    sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} down -v'
                }
            }
        }

        // STAGE 4: RUN ANSIBLE PLAYBOOK 
        stage('Deploy Application via Ansible') {
            steps {
                echo '🚀 Initiating Automated Ansible Deployment...'
                
                // Runs the optimized playbook using the repository configuration
                sh "ansible-playbook -i hosts.ini ansible/deploy.yml -e 'app_workspace=${WORKSPACE}'"
            }
        }
    }

    

    // 🌟 UNIFIED GLOBAL POST BLOCK (Merged GitHub notifications and console echoes)
    post {
        success {
            githubNotify(
                credentialsId: 'github-token',
                context: 'Jenkins CI/CD Pipeline',
                description: 'Build passed successfully!',
                status: 'SUCCESS',
                account: 'Benedictusernametaken',
                repo: 'C270---E62H',
                sha: env.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
            )
            echo "🎉 Build #${BUILD_NUMBER} Passed! The 3-tier architecture is verified and secure."
        }
        failure {
            githubNotify(
                credentialsId: 'github-token',
                context: 'Jenkins CI/CD Pipeline',
                description: 'Pipeline Failed!',
                status: 'FAILURE',
                account: 'Benedictusernametaken',
                repo: 'C270---E62H',
                sha: env.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
            )
            echo "❌ Build #${BUILD_NUMBER} Failed! Check the logs or integration test diagnostics above."
        }
    }
}

// ._.