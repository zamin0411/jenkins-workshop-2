import jenkins.model.Jenkins
import hudson.security.GlobalMatrixAuthorizationStrategy
import hudson.security.HudsonPrivateSecurityRealm
import org.jenkinsci.plugins.rolestrategy.RoleBasedAuthorizationStrategy
import org.jenkinsci.plugins.rolestrategy.Role
import org.jenkinsci.plugins.rolestrategy.RoleDefinition
import org.jenkinsci.plugins.rolestrategy.RoleType
import org.jenkinsci.plugins.rolestrategy.RoleBasedAuthorizationStrategy

// Get Jenkins instance
Jenkins jenkins = Jenkins.getInstance()

// Check if Role-based Authorization Strategy plugin is installed
if (!jenkins.getPluginManager().getPlugin("role-strategy")) {
    println "ERROR: Role-based Authorization Strategy plugin is not installed!"
    println "Please install the plugin first from Manage Jenkins > Manage Plugins"
    System.exit(1)
}

// Get the authorization strategy
def authStrategy = jenkins.getAuthorizationStrategy()

// Check if it's already role-based
if (!(authStrategy instanceof RoleBasedAuthorizationStrategy)) {
    println "ERROR: Role-based strategy is not enabled!"
    println "Please enable it from Manage Jenkins > Configure Global Security"
    System.exit(1)
}

println "Role-based strategy is enabled. Proceeding with role import..."

// Define the roles
def roles = [:]

// Admin role
roles['admin'] = [
    name: 'admin',
    description: 'Full access to all Jenkins features',
    permissions: [
        'hudson.model.Hudson.Administer',
        'hudson.model.Hudson.Read',
        'hudson.model.Item.Build',
        'hudson.model.Item.Delete',
        'hudson.model.Item.Configure',
        'hudson.model.Item.Create',
        'hudson.model.Item.Read',
        'hudson.model.Item.Workspace',
        'hudson.model.Item.Move',
        'hudson.model.Item.Discover',
        'hudson.model.Item.Cancel',
        'hudson.model.Run.Delete',
        'hudson.model.Run.Update',
        'hudson.scm.SCM.Tag',
        'hudson.model.View.Create',
        'hudson.model.View.Delete',
        'hudson.model.View.Configure',
        'hudson.model.View.Read'
    ],
    users: ['admin']
]

// Developer role
roles['developer'] = [
    name: 'developer',
    description: 'Can build and view jobs',
    permissions: [
        'hudson.model.Hudson.Read',
        'hudson.model.Item.Build',
        'hudson.model.Item.Configure',
        'hudson.model.Item.Read',
        'hudson.model.Item.Workspace',
        'hudson.model.Item.Discover',
        'hudson.model.Item.Cancel',
        'hudson.model.Run.Update',
        'hudson.model.View.Read'
    ],
    users: ['dev1', 'dev2', 'dev3']
]

// Viewer role
roles['viewer'] = [
    name: 'viewer',
    description: 'Read-only access',
    permissions: [
        'hudson.model.Hudson.Read',
        'hudson.model.Item.Read',
        'hudson.model.View.Read'
    ],
    users: ['viewer1', 'viewer2']
]

// Import roles
roles.each { roleKey, roleData ->
    println "Creating role: ${roleData.name}"
    
    try {
        // Create the role
        def role = new Role(roleData.name, roleData.description, roleData.permissions, roleData.users)
        
        // Add to global roles
        authStrategy.addRole(RoleType.Global, role)
        
        println "✓ Successfully created role: ${roleData.name}"
        println "  - Permissions: ${roleData.permissions.size()}"
        println "  - Users: ${roleData.users.join(', ')}"
        
    } catch (Exception e) {
        println "✗ Failed to create role ${roleData.name}: ${e.message}"
    }
}

// Save the configuration
jenkins.save()

println ""
println "Role import completed!"
println "You may need to restart Jenkins for changes to take full effect."
println ""
println "To verify roles, go to: Manage Jenkins > Manage and Assign Roles"
