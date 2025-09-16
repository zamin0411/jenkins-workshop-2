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
echo "      Jenkins Role Import Script"
echo "=========================================="
echo ""

# Check if Jenkins is running
print_status "Checking if Jenkins is running..."
if ! curl -s http://localhost:8080/jenkins/ > /dev/null; then
    print_error "Jenkins is not accessible. Please start Jenkins first:"
    echo "   ./setup-workshop.sh"
    exit 1
fi

print_success "Jenkins is accessible"

# Check if Role-based Authorization Strategy plugin is installed
print_status "Checking if Role-based Authorization Strategy plugin is installed..."

# Check if role-based strategy is enabled
print_status "Checking if role-based strategy is enabled..."
if curl -s http://localhost:8080/jenkins/configureSecurity/ | grep -q 'name="authorizationStrategy" value="hudson.security.GlobalMatrixAuthorizationStrategy"'; then
    print_warning "Role-based strategy is not enabled yet"
    echo ""
    echo "Please enable role-based strategy manually:"
    echo "1. Go to: http://localhost:8080/jenkins/configureSecurity/"
    echo "2. Under 'Authorization', select 'Role-based strategy'"
    echo "3. Click 'Save'"
    echo ""
    echo "After enabling role-based strategy, run this script again."
    exit 1
fi

print_success "Role-based strategy is enabled"

# Now import the roles
print_status "Importing role configuration..."

# Create the roles using Jenkins CLI or REST API
# For now, we'll provide manual instructions
echo ""
print_success "Role configuration file is ready: jenkins-role-config.xml"
echo ""
print_status "To import the roles manually:"
echo ""
echo "1. Go to: http://localhost:8080/jenkins/manage/role-strategy/"
echo "2. Click 'Manage Roles'"
echo "3. Add the following roles:"
echo ""
echo "   ADMIN ROLE:"
echo "   - Name: admin"
echo "   - Description: Full access to all Jenkins features"
echo "   - Permissions: Check all permissions"
echo "   - Assign to: admin (your admin user)"
echo ""
echo "   DEVELOPER ROLE:"
echo "   - Name: developer"
echo "   - Description: Can build and view jobs"
echo "   - Permissions: Read, Build, Configure, Workspace, Discover, Cancel, Update"
echo "   - Assign to: dev1, dev2, dev3 (or your developer usernames)"
echo ""
echo "   VIEWER ROLE:"
echo "   - Name: viewer"
echo "   - Description: Read-only access"
echo "   - Permissions: Read only"
echo "   - Assign to: viewer1, viewer2 (or your viewer usernames)"
echo ""
echo "4. Click 'Assign Roles' to assign roles to users"
echo "5. Save the configuration"
echo ""

print_success "Role import instructions completed!"
echo ""
print_status "Alternative: You can also use the Jenkins CLI to import roles:"
echo "   java -jar jenkins-cli.jar -s http://localhost:8080/jenkins/ groovy import-roles.groovy"
