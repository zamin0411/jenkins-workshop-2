#!/bin/bash

# Deployment Script for Jenkins Job
# This script handles deployment to local and remote servers using Ansible

set -e  # Exit on any error

echo "=== Starting Deployment Process ==="
echo "Deploy User: $DEPLOY_USER"
echo "Max Releases: $MAX_RELEASES"
echo "Deploy Local: $DEPLOY_LOCAL"
echo "Deploy Remote: $DEPLOY_REMOTE"
echo "Timestamp: $(date +%Y%m%d%H%M%S)"

# Set environment variables
export ANSIBLE_CONFIG=/ansible/ansible.cfg
export ANSIBLE_HOST_KEY_CHECKING=False

# Create user directory if not exists
echo "Creating user directory..."
mkdir -p /usr/share/nginx/html/jenkins/$DEPLOY_USER
cp -r /usr/share/nginx/html/jenkins/template/* /usr/share/nginx/html/jenkins/$DEPLOY_USER/

# Set permissions
chmod -R 755 /usr/share/nginx/html/jenkins/$DEPLOY_USER
chmod +x /usr/share/nginx/html/jenkins/$DEPLOY_USER/test/test.sh

# Update ansible inventory with current user
sed -i "s/ansible_user=.*/ansible_user=$DEPLOY_USER/" /ansible/hosts

# Run ansible playbook
echo "Running Ansible playbook..."
cd /ansible

if [ "$DEPLOY_LOCAL" = "true" ]; then
    echo "Deploying to local server..."
    ansible-playbook -i hosts deploy.yml --limit local -e "ansible_user=$DEPLOY_USER max_releases=$MAX_RELEASES"
fi

if [ "$DEPLOY_REMOTE" = "true" ]; then
    echo "Deploying to remote server..."
    ansible-playbook -i hosts deploy.yml --limit remote -e "ansible_user=$DEPLOY_USER max_releases=$MAX_RELEASES"
fi

echo "=== Deployment completed successfully! ==="
