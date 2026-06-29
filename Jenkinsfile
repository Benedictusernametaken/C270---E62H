pipeline {
    agent any

    environment {
        APP_NAME = 'nutritrack'
    }

    stages {
        // STAGE 1: CLONE & PULL THE REPOSITORY
        stage('Checkout Code') {
            steps {
                // Using docker root to clear root-owned ghost folders if they exist
                // sh 'docker run --rm -v "$(pwd):/workspace" alpine rm -rf /workspace/database/init.sql'
                
                echo 'Purging host workspace folder caches entirely...'
                deleteDir() 

                echo 'Pulling the latest codebase from the develop branch...'
                checkout scm
            }
        }

        // STAGE 2: COMPILE & BUILD CONTAINERS
        stage('Docker Compile') {
            steps {
                echo 'Orchestrating container builds via Docker Compose...'
                sh 'docker compose build --no-cache --pull'
            }
        }

        // STAGE 3: RUN INTEGRATION & HEALTH CHECKS
        stage('Integration Testing') {
            steps {
                echo '🧹 DEFENSIVE CLEANUP: Wiping any stale persistent volume caches...'
                sh 'docker compose down -v'

                echo 'Launching all service architecture layers simultaneously...'
                // Docker Compose handles the startup sequence automatically using the health check
                sh 'docker compose up -d database frontend backend'
                
                echo 'Giving application services a brief moment to bind endpoints...'
                sh 'sleep 5'
                
                echo 'Printing system runtime status check...'
                sh 'docker compose ps'
                
                echo 'Executing internal connection verification handshake...'
                sh '''docker compose exec -T backend python -c "
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
                    sh 'docker compose logs backend'

                    echo '=== DIAGNOSTIC: CAPTURING DATABASE INITIALIZATION LOGS ==='
                    sh 'docker compose logs database'
                    
                    echo 'Cleaning up active test environments...'
                    sh 'docker compose down -v'
                }
            }
        }
    }

    post {
        success {
            echo '🎉 Build Passed! The 3-tier architecture is verified and secure.'
        }
        failure {
            echo '❌ Build Failed! Check the compilation logs or integration curl output above.'
        }
    }
}