pipeline {
    agent any

    options {
        disableConcurrentBuilds()
    }

    environment {
        APP_NAME          = 'nutritrack'
        POSTGRES_USER     = 'nutri_admin'
        POSTGRES_PASSWORD = credentials('nutritrack-db-password') 
        POSTGRES_DB       = 'nutritrack_db'
        
        FLASK_APP         = 'app.main'
        FLASK_ENV         = 'production'
        PYTHONPATH        = '/app'

        // Explicitly naming ONLY the base file disables Compose's automatic
        // merge of docker-compose.override.yml, so the test stack never
        // inherits host port bindings (see docker-compose.override.yml).
        COMPOSE_TEST_FILES = '-f docker-compose.yml'
    }

    stages {
        // STAGE 1: CLEAN WORKSPACE & FETCH CODE
        stage('Checkout Code') {
            steps {
                echo 'Purging host workspace folder caches entirely...'
                deleteDir() 
                checkout scm
            }
        }

        // STAGE 2: ISOLATED TESTING (Runs first!)
        stage('Integration Testing') {
            steps {
                echo '🧹 DEFENSIVE CLEANUP: Wiping any stale test containers...'
                // Using "-p ${APP_NAME}_test" guarantees this command ONLY touches test setups
                sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test down -v --remove-orphans || true'

                echo 'Building and starting test containers...'
                sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test build --no-cache'
                sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test up -d database frontend'
                
                echo 'Waiting for test database initialization...'
                sh 'sleep 10'
                
                sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test up -d backend'

                echo 'Checking container status before proceeding...'
                sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test ps'

                echo 'Running internal verification handshake (with retries)...'
                sh '''
                    echo "--- WAITING FOR BACKEND TO BECOME READY ---"
                    ATTEMPTS=10
                    SLEEP_SECONDS=3
                    SUCCESS=0

                    for i in $(seq 1 $ATTEMPTS); do
                        echo "Attempt $i/$ATTEMPTS..."
                        if docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test exec -T backend python -c "
import urllib.request, urllib.error
try:
    res = urllib.request.urlopen('http://127.0.0.1:5000/health-check', timeout=5)
    print('SUCCESS: Health check responded with status:', res.status)
    exit(0)
except Exception as e:
    print('Not ready yet:', str(e))
    exit(1)
"; then
                            SUCCESS=1
                            break
                        fi
                        sleep $SLEEP_SECONDS
                    done

                    if [ "$SUCCESS" -ne 1 ]; then
                        echo "!!! BACKEND FAILED TO BECOME HEALTHY AFTER $ATTEMPTS ATTEMPTS !!!"
                        exit 1
                    fi
                '''
            }
            post {
                always {
                    echo '--- CAPTURING BACKEND LOGS (post-attempt, for diagnostics) ---'
                    sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test logs backend > backend_debug.log 2>&1 || true'
                    sh 'cat backend_debug.log || true'
                    archiveArtifacts artifacts: 'backend_debug.log', allowEmptyArchive: true

                    echo 'Cleaning up isolated test architecture environment...'
                    sh 'docker compose ${COMPOSE_TEST_FILES} -p ${APP_NAME}_test down -v --remove-orphans || true'
                }
            }
        }

        // STAGE 3: PRODUCTION DEPLOYMENT (Only runs if Testing succeeds!)
        stage('Deploy to Production') {
            steps {
                echo 'Cleaning up and starting production services...'
                // No -f flags here, so Compose auto-merges docker-compose.yml +
                // docker-compose.override.yml and gets real host ports as intended.
                sh '''
                    docker compose down --remove-orphans || true
                    docker compose pull || true
                    docker compose up -d database frontend
                    sleep 5
                    docker compose up -d backend
                '''
            }
        }
    


        // STAGE 4: RUN ANSIBLE PLAYBOOK 
        stage('Deploy Application via Ansible') {
            steps {
                echo '🚀 Initiating Automated Ansible Deployment...'
                
                // Runs the optimized playbook using the repository configuration
                sh "ansible-playbook your-playbook-name.yml --extra-vars 'app_workspace=${WORKSPACE} project_namespace=${APP_NAME}_${BUILD_NUMBER}'"
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