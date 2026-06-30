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
                echo 'Orchestrating container builds via Docker Compose...'
                // Pass environment variables seamlessly to the compose build context
                sh 'docker compose build --no-cache --pull'
            }
        }

        // STAGE 3: RUN INTEGRATION & HEALTH CHECKS
        stage('Integration Testing') {
            steps {
                echo '🧹 DEFENSIVE CLEANUP: Wiping any stale persistent volume caches...'
                sh 'docker compose down -v'

                echo 'Launching all service architecture layers simultaneously...'
                // Using the -p flag isolates this team build instance from other projects on the server
                sh 'docker compose -p ${APP_NAME}_${BUILD_NUMBER} up -d database frontend backend'
                
                echo 'Giving application services a brief moment to bind endpoints...'
                sh 'sleep 5'
                
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
    }

    // Add this section to post status back to GitHub
    post {
        success {
            githubNotify status: 'SUCCESS', description: 'Pipeline Passed!'
        }
        failure {
            githubNotify status: 'FAILURE', description: 'Pipeline Failed!'
        }
    }

    post {
        success {
            echo "🎉 Build #${BUILD_NUMBER} Passed! The 3-tier architecture is verified and secure."
        }
        failure {
            echo "❌ Build #${BUILD_NUMBER} Failed! Check the logs or integration test diagnostics above."
        }
    }
}

// Test comment: Verifying automated GitHub Webhook integration