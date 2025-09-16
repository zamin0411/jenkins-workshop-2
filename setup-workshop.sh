#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "=========================================="
echo "    Workshop Setup & Deployment Script"
echo "=========================================="
echo ""

# Step 1: Setup Jenkins deployment environment
print_status "Step 1: Setting up Jenkins deployment environment..."
chmod +x template/test/test.sh
mkdir -p deploy
chmod -R 777 deploy

# Step 2: Build and start services
print_status "Step 2: Building and starting Jenkins and Nginx..."
docker-compose up -d --build

# Step 3: Wait for Jenkins to start
print_status "Step 3: Waiting for Jenkins to start..."
sleep 30

# Step 4: Setup SSH keys in container
print_status "Step 4: Setting up SSH keys in Jenkins container..."

# Create SSH directory and set permissions
print_status "Creating SSH directory and setting permissions..."
docker exec jenkins mkdir -p /root/.ssh
docker exec jenkins chmod 700 /root/.ssh
docker exec jenkins chmod 600 /root/.ssh/newbie_id_rsa
docker exec jenkins chmod 644 /root/.ssh/newbie_id_rsa.pub

# Verify SSH key setup
print_status "Verifying SSH key setup..."
docker exec jenkins ls -la /root/.ssh/
docker exec jenkins ssh-keygen -l -f /root/.ssh/newbie_id_rsa

print_success "SSH key setup complete!"

# Step 5: Wait for Jenkins to be ready
print_status "Step 5: Waiting for Jenkins to be ready..."
sleep 10

# Check if Jenkins is accessible
print_status "Checking if Jenkins is accessible..."
if ! curl -s http://localhost:8080/jenkins/ > /dev/null; then
    print_warning "Jenkins is not accessible yet. Waiting a bit more..."
    sleep 20
fi

if ! curl -s http://localhost:8080/jenkins/ > /dev/null; then
    print_error "Jenkins is still not accessible. Please check the container logs."
    echo "Container logs:"
    docker-compose logs jenkins
    exit 1
fi

print_success "Jenkins is accessible"

# Step 6: Copy deployment script
print_status "Step 6: Copying deployment script..."
docker cp deploy-script.sh jenkins:/usr/share/nginx/html/jenkins/deploy-script.sh
docker exec jenkins chmod +x /usr/share/nginx/html/jenkins/deploy-script.sh

# Step 7: Import Jenkins job
print_status "Step 7: Importing Jenkins job..."

# Create job directory
JOB_NAME="Deploy Application"
JOB_DIR="/var/jenkins_home/jobs/$JOB_NAME"

print_status "Creating job directory: $JOB_DIR"
docker-compose exec jenkins mkdir -p "$JOB_DIR"

# Copy config file
print_status "Copying job configuration..."
docker cp jenkins-config.xml jenkins:/tmp/jenkins-config.xml
docker-compose exec jenkins cp /tmp/jenkins-config.xml "$JOB_DIR/config.xml"

# Set permissions
print_status "Setting permissions..."
docker-compose exec jenkins chown -R jenkins:jenkins "$JOB_DIR"

# Create job structure
print_status "Creating job structure..."
docker-compose exec jenkins mkdir -p "$JOB_DIR/builds"
docker-compose exec jenkins mkdir -p "$JOB_DIR/workspace"

# Set permissions for job structure
docker-compose exec jenkins chown -R jenkins:jenkins "$JOB_DIR/builds"
docker-compose exec jenkins chown -R jenkins:jenkins "$JOB_DIR/workspace"

print_success "Job imported successfully!"

# Step 8: Get Jenkins admin password
print_status "Step 8: Getting Jenkins admin password..."
echo ""
if docker-compose exec jenkins test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    print_warning "Jenkins admin password:"
    docker-compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
else
    print_warning "Jenkins admin password not generated yet. This is normal for first run."
    print_status "Complete Jenkins setup first, then the password will be generated."
fi

# Step 9: Test SSH connection
print_status "Step 9: Testing SSH connection to remote server..."
if docker exec jenkins ssh -o ConnectTimeout=10 -p 3334 newbie@118.69.34.46 -i /root/.ssh/newbie_id_rsa "echo 'SSH connection successful'" 2>/dev/null; then
    print_success "SSH connection to remote server successful!"
else
    print_warning "SSH connection to remote server failed. This is expected if the remote server is not configured yet."
    print_warning "You'll need to add the SSH public key to your remote server before running Ansible."
fi

# Step 10: Display final information
echo ""
echo "=========================================="
echo "           Setup Complete!"
echo "=========================================="
echo ""
print_success "Jenkins is running at: http://localhost:8080"
print_success "Nginx is running at: http://localhost"
print_success "Jenkins web interface: http://localhost/jenkins/"
echo ""
print_status "Next steps:"
echo "1. Complete Jenkins setup and install required plugins:"
echo "   - Ansible plugin"
echo "   - Role-based Authorization Strategy plugin"
echo "   - Email Extension Plugin"
echo ""
echo "2. You should see 'Deploy Application' job in the Jenkins dashboard"
echo ""
echo "3. To test Ansible deployment:"
echo "   docker exec jenkins ansible-playbook /ansible/deploy.yml"
echo ""
echo "4. If the job doesn't appear, restart Jenkins:"
echo "   docker-compose restart jenkins"
echo ""
print_warning "Remember to add your SSH public key to the remote server:"
echo "   cat ~/.ssh/newbie_id_rsa.pub"
echo ""
print_success "Workshop setup complete! 🎉"
