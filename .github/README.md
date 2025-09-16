# GitHub Actions + Jenkins Integration

This repository includes GitHub Actions workflows that automatically trigger Jenkins jobs for deployment.

## Workflows

### 1. `jenkins-deploy.yml`
Main deployment workflow that triggers Jenkins jobs based on:
- **Push to main/develop branches** - Automatic deployment
- **Pull requests** - Test deployment
- **Manual dispatch** - On-demand deployment with environment selection

### 2. `trigger-jenkins.yml`
Simple workflow for basic Jenkins job triggering.

## Setup Instructions

### 1. Jenkins Configuration

#### Install Required Plugins
- **GitHub Plugin** - For GitHub integration
- **Parameterized Trigger Plugin** - For parameterized builds
- **Build Authorization Token Root Plugin** - For API access

#### Create Jenkins Job
1. Create a new **Pipeline** job named `workshop2`
2. Configure the job to accept these parameters:
   - `BRANCH_NAME` (String)
   - `GIT_COMMIT` (String) 
   - `GIT_URL` (String)
   - `BUILD_CAUSE` (String)
   - `DEPLOY_ENVIRONMENT` (String, default: staging)

#### Generate API Token
1. Go to **Jenkins** → **Manage Jenkins** → **Manage Users**
2. Click on your user → **Configure**
3. Click **Add new Token** → **Generate**
4. Copy the generated token

### 2. GitHub Secrets Configuration

Add these secrets to your GitHub repository:

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following repository secrets:

```
JENKINS_URL=https://your-jenkins-server.com
JENKINS_USER=your-jenkins-username
JENKINS_TOKEN=your-api-token
JENKINS_JOB_NAME=workshop2
```

### 3. Jenkinsfile Updates

Make sure your Jenkinsfile accepts the parameters from GitHub Actions:

```groovy
pipeline {
    agent any
    
    parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Git branch name')
        string(name: 'GIT_COMMIT', defaultValue: '', description: 'Git commit hash')
        string(name: 'GIT_URL', defaultValue: '', description: 'Git repository URL')
        string(name: 'BUILD_CAUSE', defaultValue: 'manual', description: 'Build trigger cause')
        string(name: 'DEPLOY_ENVIRONMENT', defaultValue: 'staging', description: 'Deployment environment')
    }
    
    // ... rest of your pipeline
}
```

## Workflow Features

### Automatic Triggers
- **Push to main/develop**: Triggers production/staging deployment
- **Pull requests**: Triggers test deployment
- **Path filtering**: Only triggers on changes to relevant files

### Manual Triggers
- **Environment selection**: Choose between staging/production
- **Force deployment**: Deploy even without changes

### Notifications
- **PR comments**: Updates pull requests with deployment status
- **Build links**: Direct links to Jenkins build logs
- **Failure notifications**: Clear error messages on failure

## Usage

### Automatic Deployment
1. Push changes to `main` or `develop` branch
2. GitHub Actions will automatically trigger Jenkins
3. Monitor progress in both GitHub Actions and Jenkins

### Manual Deployment
1. Go to **Actions** tab in GitHub
2. Select **Deploy to Jenkins** workflow
3. Click **Run workflow**
4. Choose environment and options
5. Click **Run workflow**

### Pull Request Deployment
1. Create a pull request
2. GitHub Actions will trigger test deployment
3. Check PR comments for deployment status
4. Merge when ready for production

## Troubleshooting

### Common Issues

1. **Jenkins job not triggered**
   - Check GitHub secrets are correctly set
   - Verify Jenkins URL is accessible
   - Ensure Jenkins job name matches `JENKINS_JOB_NAME` secret

2. **Authentication failed**
   - Verify `JENKINS_USER` and `JENKINS_TOKEN` are correct
   - Check Jenkins user has proper permissions
   - Ensure API token is not expired

3. **Job parameters not passed**
   - Verify Jenkins job accepts the required parameters
   - Check parameter names match exactly

4. **Timeout errors**
   - Increase timeout in workflow file
   - Check Jenkins server performance
   - Monitor Jenkins build queue

### Debug Steps

1. Check GitHub Actions logs for detailed error messages
2. Verify Jenkins job configuration
3. Test Jenkins API access manually
4. Check Jenkins build logs for deployment issues

## Security Notes

- Store sensitive information in GitHub Secrets only
- Use least-privilege Jenkins API tokens
- Regularly rotate API tokens
- Monitor Jenkins access logs
