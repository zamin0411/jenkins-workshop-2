# Jenkins Deployment Automation

## Tổng quan
Dự án này thiết lập Jenkins để tự động hóa quá trình deploy ứng dụng lên cả server local và remote thông qua Ansible.

## Cấu trúc thư mục
```
.
├── template/                 # Template files cho deployment
│   ├── app/
│   │   └── index.html      # Demo HTML file
│   ├── test/
│   │   └── test.sh         # Test script
│   └── deploy/             # Deploy directory structure
├── ansible/                 # Ansible configuration
│   ├── ansible.cfg         # Ansible config
│   ├── hosts               # Inventory file
│   ├── deploy.yml          # Deployment playbook
│   └── requirements.txt    # Python dependencies
├── docker-compose.yml      # Docker services configuration
├── Dockerfile.jenkins      # Custom Jenkins image with Ansible
├── nginx.conf              # Nginx configuration
├── jenkins-config.xml      # Jenkins job configuration
├── jenkins-role-config.xml # Role-based access control
├── setup-workshop.sh       # Complete workshop setup script
├── cleanup-workshop.sh     # Cleanup script
├── deploy-script.sh        # Deployment script for Jenkins job
├── import-jenkins-roles.sh # Role import helper script
├── import-roles.groovy     # Automated role import script
├── newbie_id_rsa          # SSH private key for remote server
├── newbie_id_rsa.pub      # SSH public key for remote server
└── README.md               # This file
```

## Yêu cầu hệ thống
- Docker và Docker Compose
- SSH key cho remote server access
- Port 80, 8080, 50000 available

## Cài đặt và thiết lập

### 1. Chuẩn bị SSH key
```bash
# Copy SSH key vào thư mục hiện tại
cp ~/.ssh/newbie_id_rsa ./
chmod 600 newbie_id_rsa
```

### 2. Chạy complete setup script
```bash
chmod +x setup-workshop.sh
./setup-workshop.sh
```

**Script này sẽ tự động:**
- Thiết lập Jenkins deployment environment
- Build và start Docker containers
- Setup SSH keys trong container
- Import Jenkins job
- Test SSH connection
- Hiển thị thông tin cần thiết

### 3. Thiết lập Jenkins (nếu cần)
Nếu setup script không hoàn thành tự động:
1. Truy cập http://localhost:8080
2. Sử dụng admin password từ console
3. Cài đặt suggested plugins
4. Tạo admin user
5. Cài đặt thêm plugins:
   - Ansible plugin
   - Role-based Authorization Strategy plugin
   - Email Extension Plugin

### 4. Import Jenkins Roles (Optional)
```bash
# Check role import requirements
chmod +x import-jenkins-roles.sh
./import-jenkins-roles.sh

# Or use automated import (requires Jenkins CLI)
# java -jar jenkins-cli.jar -s http://localhost:8080/jenkins/ groovy import-roles.groovy
```

### 5. Cleanup (nếu cần)
```bash
chmod +x cleanup-workshop.sh
./cleanup-workshop.sh
```

## Cấu hình Ansible

### Inventory
- **Local**: localhost (ansible_connection=local)
- **Remote**: 10.1.1.195 thông qua jump host 118.69.34.46:3333

### SSH Configuration
```bash
# Test connection trực tiếp
ssh newbie@118.69.34.46 -p 3334 -i newbie_id_rsa

# Test connection từ Jenkins container
docker exec jenkins ssh -p 3334 newbie@118.69.34.46 -i /root/.ssh/newbie_id_rsa "echo 'SSH connection successful'"
```

## Sử dụng

### 1. Chạy deployment job
1. Vào Jenkins dashboard
2. Chọn "Deploy Application" job
3. Click "Build with Parameters"
4. Điền thông tin:
   - DEPLOY_USER: tên user (default: manhg)
   - MAX_RELEASES: số release giữ lại (default: 5)
   - DEPLOY_LOCAL: deploy lên local server
   - DEPLOY_REMOTE: deploy lên remote server

### 2. Chạy Ansible deployment trực tiếp
```bash
# Deploy lên cả local và remote
docker exec jenkins ansible-playbook /ansible/deploy.yml -i /ansible/hosts

# Deploy chỉ lên localhost
docker exec jenkins ansible-playbook /ansible/deploy.yml -i /ansible/hosts -l localhost

# Deploy chỉ lên remote server
docker exec jenkins ansible-playbook /ansible/deploy.yml -i /ansible/hosts -l remote_server
```

### 3. Quá trình deployment
1. **Connect đến server**: SSH connection test
2. **Kiểm tra nginx**: service nginx status
3. **Tạo user directory**: copy template files
4. **Chạy test script**: kiểm tra file index.html
5. **Deploy**: tạo release folder với timestamp (format: yyyymmddhhMMss)
6. **Tạo symlink**: current → latest release
7. **Cleanup**: giữ lại MAX_RELEASES releases

### 4. Kết quả
- **Local**: `/usr/share/nginx/html/jenkins/manhg/deploy/YYYYMMDDHHMMSS/`
- **Remote**: `/usr/share/nginx/html/jenkins/manhg/deploy/YYYYMMDDHHMMSS/`
- **Symlink**: `deploy/current` → latest release
- **Web Access**: http://localhost/jenkins/manhg/deploy/current/

## Tính năng

### ✅ Build Steps (5 điểm)
- Tất cả các step được viết trong build step
- Shell script execution
- Error handling và logging

### ✅ Ansible Configuration (2 điểm)
- **Local deployment**: ansible_connection=local
- **Remote deployment**: thông qua jump host
- Playbook với tasks đầy đủ

### ✅ Role-based Access (1 điểm)
- Admin: full access
- Developer: build và view
- Viewer: read-only access

### ✅ Email Notification (1 điểm)
- Success notification
- Failure notification
- Configurable recipients

### ✅ Symlink và Cleanup (1 điểm)
- `current` symlink đến latest release
- Giữ lại 5 releases (configurable)
- Automatic cleanup

## Testing

### Test Environment
```bash
# Test deployment environment
./test-deployment.sh

# Run demo deployment
./demo-deployment.sh
```

### Demo Results
- ✅ Demo deployment created successfully
- ✅ Test script passed
- ✅ File accessible at: http://localhost/deploy/demo_user/deploy/current/

## Troubleshooting

### Permission Issues
```bash
chmod -R 777 deploy/
chmod +x template/test/test.sh
```

### SSH Connection Issues
```bash
# Test jump host connection
ssh -p 3333 zigexn@118.69.34.46

# Test direct connection
ssh newbie@118.69.34.46 -p 3334
```

### Jenkins Issues
```bash
# Restart Jenkins
docker-compose restart jenkins

# View logs
docker-compose logs jenkins
```

## Monitoring

### Logs
```bash
# Jenkins logs
docker-compose logs -f jenkins

# Nginx logs
docker-compose logs -f nginx
```

### Status
```bash
# Service status
docker-compose ps

# Nginx status (remote)
service nginx status
```

## Security Notes
- SSH keys được mount read-only
- Ansible disable host key checking
- User permissions được set đúng
- Network isolation với Docker

## Support
Để được hỗ trợ, vui lòng liên hệ team DevOps hoặc tạo issue trong repository.
