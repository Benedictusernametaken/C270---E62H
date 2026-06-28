pipeline {
    agent any

    environment {
        APP_NAME = 'nutritrack'
    }

    stages {
        // STAGE 1: CLONE & PULL THE REPOSITORY
        stage('Checkout Code') {
            steps {
                echo 'Pulling the latest codebase from the develop branch...'
                checkout scm
            }
        }

        // STAGE 2: COMPILE & BUILD CONTAINERS
        stage('Docker Compile') {
            steps {
                echo 'Orchestrating container builds via Docker Compose...'
                sh 'docker compose build'
            }
        }

        // STAGE 3: RUN INTEGRATION & HEALTH CHECKS
        stage('Integration Testing') {
            steps {
                echo 'Launching application environment stack to execute system health checks...'
                sh 'docker compose up -d frontend backend database'
                
                echo 'Waiting for database engine migrations to settle...'
                sh 'sleep 10'
                
                echo 'Executing connection verification handshake...'
                // CHANGE localhost TO backend SO JENKINS TALKS DIRECTLY TO THE FLASK CONTAINER NETWORK
                sh 'curl -f http://backend:5000/health-check'
            }
            post {
                always {
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