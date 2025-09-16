pipeline {
    agent any
    
    environment {
        // Project configuration
        PROJECT_FOLDER = 'web-performance-project1-initial'
        
        // Firebase project configuration
        FIREBASE_PROJECT = 'jenkins-firebase-87e2d'
        
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
                        echo "Current directory: $(pwd)"
                        echo "Checking for package.json:"
                        ls -la package.json || echo "package.json not found"
                        npm install
                        echo "Build completed successfully!"
                    '''
                }
            }
        }
        
        stage('Lint & Test') {
            steps {
                script {
                    echo "Starting lint and test stage..."
                }
                dir(env.PROJECT_FOLDER) {
                    sh '''
                        echo "Running linting and tests..."
                        echo "Current directory: $(pwd)"
                        echo "Checking for package.json:"
                        ls -la package.json || echo "package.json not found"
                        npm run test:ci
                        echo "Lint and test completed successfully!"
                    '''
                }
            }
            post {
                always {
                    // Publish test results
                    publishTestResults testResultsPattern: '${PROJECT_FOLDER}/coverage/test-results.xml'
                    
                    // Publish coverage reports
                    publishCoverage adapters: [
                        coberturaAdapter('${PROJECT_FOLDER}/coverage/cobertura-coverage.xml')
                    ], sourceFileResolver: sourceFiles('STORE_LAST_BUILD')
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
                        firebase use ${FIREBASE_PROJECT}
                        firebase deploy --only hosting
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
            // Clean up workspace
            cleanWs()
        }
        success {
            script {
                echo "All stages completed successfully!"
                // Send success notification (optional)
                // emailext (
                //     subject: "Deployment Successful - ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                //     body: "The deployment pipeline completed successfully.",
                //     to: "your-email@example.com"
                // )
            }
        }
        failure {
            script {
                echo "Pipeline failed at stage: ${env.STAGE_NAME}"
                // Send failure notification (optional)
                // emailext (
                //     subject: "Deployment Failed - ${env.JOB_NAME} - ${env.BUILD_NUMBER}",
                //     body: "The deployment pipeline failed at stage: ${env.STAGE_NAME}",
                //     to: "your-email@example.com"
                // )
            }
        }
        unstable {
            script {
                echo "Pipeline completed with warnings!"
            }
        }
    }
}
