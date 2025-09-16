pipeline {
    agent any
    
    environment {
        // Project configuration
        PROJECT_FOLDER = 'web-performance-project1-initial'
        
        // Firebase project configuration
        FIREBASE_PROJECT = 'jenkins-firebase-87e2d'
        FIREBASE_SERVICE_ACCOUNT_FILE = 'firebase-service-account.json'
        
        // Ansible configuration
        ANSIBLE_HOSTS = 'ansible/hosts'
        ANSIBLE_PLAYBOOK = 'ansible/deploy.yml'
        
        // Node.js configuration
        NODE_VERSION = '18'
    }
     
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                script {
                    echo "Checked out code from ${env.BRANCH_NAME}"
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo "Starting build stage..."
                }
                sh '''
                    echo "Current directory: $(pwd)"
                    echo "Listing contents:"
                    ls -la
                    echo "Checking for package.json in ${PROJECT_FOLDER}:"
                    ls -la ${PROJECT_FOLDER}/ || echo "Directory not found"
                '''
                dir(env.PROJECT_FOLDER) {
                    sh '''
                        echo "Installing Node.js dependencies..."
                        npm install
                        echo "Build completed successfully!"
                    '''
                }
            }
        }
        
        stage('Lint') {
            steps {
                script {
                    echo "Starting lint stage..."
                }
                dir(env.PROJECT_FOLDER) {
                    sh '''
                        echo "Running linting..."
                        echo "Current directory: $(pwd)"
                        echo "Checking for package.json:"
                        ls -la package.json || echo "package.json not found"
                        
                        # Run linting and capture exit code
                        set +e
                        npm run lint
                        LINT_EXIT_CODE=$?
                        set -e
                        
                        # Check if linting failed
                        if [ $LINT_EXIT_CODE -ne 0 ]; then
                            echo "❌ Linting failed with exit code: $LINT_EXIT_CODE"
                            echo "Build will fail due to linting errors/warnings"
                            exit $LINT_EXIT_CODE
                        fi
                        
                        echo "✅ Linting passed successfully!"
                    '''
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    echo "Starting test stage..."
                }
                dir(env.PROJECT_FOLDER) {
                    sh '''
                        echo "Running tests..."
                        echo "Current directory: $(pwd)"
                        
                        # Run tests and capture exit code
                        set +e
                        npm run test:ci
                        TEST_EXIT_CODE=$?
                        set -e
                        
                        # Check if tests failed
                        if [ $TEST_EXIT_CODE -ne 0 ]; then
                            echo "❌ Tests failed with exit code: $TEST_EXIT_CODE"
                            echo "Build will fail due to test failures"
                            exit $TEST_EXIT_CODE
                        fi
                        
                        echo "✅ All tests passed successfully!"
                    '''
                }
            }
        }
        
        stage('Deploy to Remote Server') {
            steps {
                script {
                    echo "Starting deployment to remote server..."
                }
                sh '''
                    echo "Deploying to remote server using Ansible..."
                    cd ansible
                    ansible-playbook -i hosts deploy.yml
                    echo "Remote server deployment completed!"
                '''
            }
        }
        
        stage('Setup Firebase Credentials') {
            steps {
                script {
                    echo "Setting up Firebase service account credentials from Jenkins credentials store..."
                }
                dir(env.PROJECT_FOLDER) {
                    withCredentials([file(credentialsId: 'firebase-service-account', variable: 'FIREBASE_CREDENTIALS_FILE')]) {
                        sh '''
                            echo "Copying Firebase service account from credentials store"
                            cp ${FIREBASE_CREDENTIALS_FILE} ${FIREBASE_SERVICE_ACCOUNT_FILE}
                            echo "Setting proper permissions for service account file"
                            chmod 600 ${FIREBASE_SERVICE_ACCOUNT_FILE}
                            echo "Verifying service account file:"
                            ls -la ${FIREBASE_SERVICE_ACCOUNT_FILE}
                        '''
                    }
                }
            }
        }
        
        stage('Deploy to Firebase') {
            steps {
                script {
                    echo "Starting Firebase deployment..."
                }
                dir(env.PROJECT_FOLDER) {
                    sh '''
                        echo "Deploying to Firebase project: ${FIREBASE_PROJECT}"
                        echo "Current directory: $(pwd)"
                        echo "Checking for firebase.json:"
                        ls -la firebase.json || echo "firebase.json not found"
                        echo "Checking for service account file:"
                        ls -la ${FIREBASE_SERVICE_ACCOUNT_FILE}
                        
                        # Set Firebase service account environment variable
                        export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/${FIREBASE_SERVICE_ACCOUNT_FILE}"
                        echo "GOOGLE_APPLICATION_CREDENTIALS set to: ${GOOGLE_APPLICATION_CREDENTIALS}"
                        
                        # Use Firebase project
                        firebase use ${FIREBASE_PROJECT}
                        
                        # Deploy to Firebase hosting
                        firebase deploy --only hosting --project ${FIREBASE_PROJECT}
                        echo "Firebase deployment completed!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo "Pipeline execution completed!"
            }
            // Clean up Firebase service account file
            dir(env.PROJECT_FOLDER) {
                sh '''
                    if [ -f "${FIREBASE_SERVICE_ACCOUNT_FILE}" ]; then
                        echo "Cleaning up Firebase service account file for security"
                        rm -f ${FIREBASE_SERVICE_ACCOUNT_FILE}
                        echo "Service account file removed"
                    fi
                '''
            }
            // Clean up workspace
            cleanWs()
        }
        success {
            script {
                echo "All stages completed successfully!"
                
                // Send comprehensive success notification
                slackSend (
                    channel: '#lnd-2025-workshop',
                    color: 'good',
                    message: """
                    🚀 *Pipeline Execution Successful*
                    
                    *Project:* ${env.JOB_NAME}
                    *Build:* #${env.BUILD_NUMBER}
                    *User:* ${env.GIT_AUTHOR_NAME ?: env.CHANGE_AUTHOR ?: env.BUILD_USER ?: 'System'}
                    *Branch:* ${env.BRANCH_NAME ?: 'main'}
                    *Duration:* ${currentBuild.durationString}
                    
                    *Completed Stages:*
                    ✅ Checkout
                    ✅ Build
                    ✅ Lint
                    ✅ Test
                    ✅ Deploy to Remote Server
                    ✅ Deploy to Firebase
                    
                    *Deployments:*
                    • Remote Server: ✅ Completed
                    • Firebase Hosting: ✅ Completed
                    
                    *Build URL:* ${env.BUILD_URL}
                    """
                )
            }
        }
        failure {
            script {
                echo "Pipeline failed at stage: ${env.STAGE_NAME}"
                
                // Send comprehensive failure notification
                slackSend (
                    channel: '#lnd-2025-workshop',
                    color: 'danger',
                    message: """
                    ❌ *Pipeline Execution Failed*
                    
                    *Project:* ${env.JOB_NAME}
                    *Build:* #${env.BUILD_NUMBER}
                    *User:* ${env.GIT_AUTHOR_NAME ?: env.CHANGE_AUTHOR ?: env.BUILD_USER ?: 'System'}
                    *Branch:* ${env.BRANCH_NAME ?: 'main'}
                    *Failed Stage:* ${env.STAGE_NAME ?: 'Unknown'}
                    *Duration:* ${currentBuild.durationString}
                    
                    *Error Details:*
                    Check the build logs for more information.
                    
                    *Build URL:* ${env.BUILD_URL}
                    *Console Output:* ${env.BUILD_URL}console
                    """
                )
            }
        }
    }
}
