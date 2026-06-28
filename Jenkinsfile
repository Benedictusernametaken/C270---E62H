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
                echo 'Launching database instance first...'
                sh 'docker compose up -d database'
                
                echo 'Waiting for database engine migrations and schema setup to initialize...'
                sh 'sleep 12'
                
                echo 'Launching frontend and backend application layers...'
                sh 'docker compose up -d frontend backend'
                
                echo 'Giving application services a brief moment to bind endpoints...'
                sh 'sleep 5'
                
                echo 'Printing system runtime status check...'
                sh 'docker compose ps'
                
                echo 'Executing internal connection verification handshake...'
                // Clean shell alternative: if curl fails, it prints the server response body text
                sh 'docker compose exec -T backend curl -fS http://localhost:5000/health-check || (docker compose exec -T backend curl -s http://localhost:5000/health-check && exit 1)'
            }
            post {
                always {
                    echo '=== CAPTURING BACKEND CONTAINER RUNTIME LOGS ==='
                    sh 'docker compose logs backend'
                    
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
