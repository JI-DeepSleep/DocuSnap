# 技术栈

本页面详细介绍 DocuSnap-Backend 系统部署中使用的技术栈，包括服务器环境、运行时环境、Web 服务器、数据库、容器技术和监控工具等。

## 服务器环境

### 操作系统

**推荐选择**：
- **Ubuntu Server 20.04 LTS 或更高版本**
  - 广泛的社区支持
  - 长期支持（LTS）提供稳定性
  - 丰富的软件包资源
  - 良好的安全性和性能

**其他选项**：
- **CentOS 8 / Rocky Linux 8**
  - 企业级稳定性
  - 长期支持
  - 与 RHEL 兼容
- **Debian 11 或更高版本**
  - 极高的稳定性
  - 轻量级
  - 适合资源受限环境

### 硬件配置

**应用服务器**：
- **CPU**：8+ 核心，支持 AVX2 指令集
- **内存**：16+ GB RAM
- **存储**：100+ GB SSD（推荐 NVMe）
- **网络**：1+ Gbps 网络接口

**OCR 服务器**：
- **CPU**：8+ 核心，支持 AVX2 指令集
- **GPU**（推荐）：NVIDIA GPU，8+ GB 显存
- **内存**：16+ GB RAM
- **存储**：100+ GB SSD
- **网络**：1+ Gbps 网络接口

**数据库服务器**（大规模部署）：
- **CPU**：8+ 核心
- **内存**：16+ GB RAM
- **存储**：200+ GB SSD（推荐 RAID 配置）
- **网络**：1+ Gbps 网络接口

## 运行时环境

### Python 环境

**Python 版本**：
- Python 3.8 或更高版本（推荐 3.9+）

**虚拟环境**：
- **virtualenv**：轻量级虚拟环境
- **conda**（可选）：适用于需要复杂依赖管理的场景

**包管理**：
- **pip**：安装 Python 依赖
- **pip-tools**（推荐）：锁定依赖版本，确保环境一致性

**主要依赖**：
```
Flask==3.1.1
gunicorn==20.1.0
zhipuai==2.1.5
Werkzeug==3.0.1
requests==2.31.0
pycryptodome==3.19.0
```

### 依赖管理

**依赖文件**：
- **requirements.txt**：列出所有依赖及其版本
- **requirements-dev.txt**（可选）：开发环境特定依赖

**版本控制**：
- 锁定所有依赖的具体版本，避免意外升级
- 定期更新依赖，修复安全漏洞
- 使用 `pip-compile` 生成依赖锁文件

## Web 服务器

### WSGI 服务器

**Gunicorn**：
- 版本：20.1.0 或更高
- 轻量级、高性能的 WSGI 服务器
- 支持多工作进程和多线程
- 配置示例：
  ```
  gunicorn --workers=4 --threads=2 --bind=0.0.0.0:8000 app:app
  ```

**配置参数**：
- **workers**：工作进程数，建议设置为 CPU 核心数的 2-4 倍
- **threads**：每个工作进程的线程数
- **timeout**：请求超时时间，建议设置为 120 秒或更长
- **max-requests**：工作进程处理的最大请求数，用于防止内存泄漏

### 反向代理

**Nginx**：
- 版本：1.18.0 或更高
- 高性能的 HTTP 和反向代理服务器
- 提供负载均衡、SSL 终结和静态文件服务
- 配置示例：
  ```nginx
  server {
      listen 80;
      server_name example.com;
      return 301 https://$host$request_uri;
  }

  server {
      listen 443 ssl;
      server_name example.com;

      ssl_certificate /path/to/cert.pem;
      ssl_certificate_key /path/to/key.pem;
      ssl_protocols TLSv1.2 TLSv1.3;

      location / {
          proxy_pass http://127.0.0.1:8000;
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_read_timeout 120s;
      }

      location /static {
          alias /path/to/static;
          expires 30d;
      }
  }
  ```

**配置重点**：
- SSL/TLS 配置，确保安全通信
- 代理超时设置，适应长时间运行的请求
- 请求头传递，确保应用能获取客户端信息
- 静态文件服务，提高性能

## 数据库

### SQLite

**版本**：
- SQLite 3.30.0 或更高版本

**配置**：
- 数据库文件路径：`/path/to/docusnap.db`
- 权限设置：确保应用服务器有读写权限
- 定期备份：使用 `sqlite3_backup` API 或文件复制

**优化**：
- 启用 WAL 模式，提高并发性能
- 定期执行 VACUUM，优化数据库大小
- 添加适当的索引，提高查询性能

### PostgreSQL（大规模部署推荐）

**版本**：
- PostgreSQL 12 或更高版本

**配置**：
- 连接池：使用 pgBouncer 或应用内连接池
- 主从复制：提高可用性和读取性能
- 定期备份：使用 pg_dump 或连续归档

**迁移方案**：
- 从 SQLite 迁移到 PostgreSQL 的步骤
- 使用 SQLAlchemy 作为 ORM，简化迁移
- 数据验证和一致性检查

## 容器技术

### Docker

**版本**：
- Docker 19.03 或更高版本

**镜像**：
- **应用服务镜像**：基于 Python 官方镜像
- **OCR 服务镜像**：包含 CnOCR 和依赖

**Dockerfile 示例**（应用服务）：
```dockerfile
FROM python:3.9-slim

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 设置环境变量
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=app.py

# 暴露端口
EXPOSE 8000

# 启动命令
CMD ["gunicorn", "--workers=4", "--threads=2", "--bind=0.0.0.0:8000", "app:app"]
```

### Docker Compose

**版本**：
- Docker Compose 1.25 或更高版本

**配置示例**：
```yaml
version: '3'

services:
  app:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - ./data:/app/data
    environment:
      - FLASK_ENV=production
    depends_on:
      - ocr-service

  ocr-service:
    build: ./ocr-service
    ports:
      - "5001:5001"
    volumes:
      - ./models:/app/models

  nginx:
    image: nginx:latest
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - app
```

### Kubernetes（大规模部署）

**版本**：
- Kubernetes 1.18 或更高版本

**组件**：
- **Deployment**：管理应用和 OCR 服务的 Pod
- **Service**：提供内部服务发现和负载均衡
- **Ingress**：管理外部访问路由
- **ConfigMap**：管理配置
- **Secret**：管理敏感信息
- **PersistentVolume**：提供持久化存储

**配置示例**（应用服务部署）：
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: docusnap-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: docusnap-app
  template:
    metadata:
      labels:
        app: docusnap-app
    spec:
      containers:
      - name: docusnap-app
        image: docusnap-app:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        volumeMounts:
        - name: data-volume
          mountPath: /app/data
      volumes:
      - name: data-volume
        persistentVolumeClaim:
          claimName: docusnap-data-pvc
```

## 监控与日志

### 监控工具

**Prometheus**：
- 收集和存储指标数据
- 支持自定义指标和告警规则
- 与 Grafana 集成，提供可视化界面

**配置示例**：
```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'docusnap-app'
    static_configs:
      - targets: ['docusnap-app:8000']
  - job_name: 'ocr-service'
    static_configs:
      - targets: ['ocr-service:5001']
```

### 日志管理

**ELK 栈**：
- **Elasticsearch**：存储和索引日志
- **Logstash**：处理和转换日志
- **Kibana**：可视化和分析日志

**Fluentd/Fluent Bit**：
- 收集容器和应用日志
- 转发到 Elasticsearch 或其他存储

**日志配置**（Flask 应用）：
```python
import logging
from logging.handlers import RotatingFileHandler

handler = RotatingFileHandler('app.log', maxBytes=10000000, backupCount=10)
handler.setFormatter(logging.Formatter(
    '%(asctime)s %(levelname)s: %(message)s [in %(pathname)s:%(lineno)d]'
))
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)
```

## 安全工具

### SSL/TLS

**Let's Encrypt**：
- 免费的 SSL/TLS 证书
- 使用 Certbot 自动更新证书
- 配置 HTTPS 重定向和 HSTS

**配置示例**：
```bash
certbot --nginx -d example.com -d www.example.com
```

### Web 应用防火墙

**ModSecurity**：
- 开源 Web 应用防火墙
- 与 Nginx 集成
- 提供 OWASP 核心规则集

**配置示例**：
```nginx
# 在 Nginx 配置中加载 ModSecurity
load_module modules/ngx_http_modsecurity_module.so;

server {
    # ... 其他配置 ...
    
    modsecurity on;
    modsecurity_rules_file /etc/nginx/modsecurity/main.conf;
    
    # ... 其他配置 ...
}
```

### 网络安全

**UFW/iptables**：
- 配置防火墙规则，限制端口访问
- 只开放必要的端口（80, 443, 22）
- 限制 SSH 访问来源

**配置示例**：
```bash
# 允许 SSH, HTTP, HTTPS
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# 拒绝其他所有入站连接
ufw default deny incoming

# 允许所有出站连接
ufw default allow outgoing

# 启用防火墙
ufw enable
```

## 自动化部署

### CI/CD 工具

**GitHub Actions / GitLab CI**：
- 自动化构建、测试和部署流程
- 支持多环境部署
- 集成代码质量检查和安全扫描

**配置示例**（GitHub Actions）：
```yaml
name: Deploy DocuSnap Backend

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.9'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        pytest
    
    - name: Build Docker image
      run: |
        docker build -t docusnap-app:latest .
    
    - name: Deploy to production
      if: github.ref == 'refs/heads/main'
      run: |
        # 部署脚本
        ./deploy.sh
```

### 配置管理

**Ansible**：
- 自动化服务器配置和应用部署
- 声明式配置，确保环境一致性
- 支持多服务器并行部署

**配置示例**（Ansible Playbook）：
```yaml
---
- name: Deploy DocuSnap Backend
  hosts: app_servers
  become: yes
  
  tasks:
    - name: Install required packages
      apt:
        name:
          - python3
          - python3-pip
          - nginx
        state: present
        update_cache: yes
    
    - name: Clone application repository
      git:
        repo: https://github.com/JI-DeepSleep/DocuSnap-Backend.git
        dest: /opt/docusnap
        version: main
    
    - name: Install Python dependencies
      pip:
        requirements: /opt/docusnap/requirements.txt
        virtualenv: /opt/docusnap/venv
        virtualenv_command: python3 -m venv
    
    - name: Configure Nginx
      template:
        src: templates/nginx.conf.j2
        dest: /etc/nginx/sites-available/docusnap
      notify: Restart Nginx
    
    - name: Enable Nginx site
      file:
        src: /etc/nginx/sites-available/docusnap
        dest: /etc/nginx/sites-enabled/docusnap
        state: link
      notify: Restart Nginx
    
    - name: Start application service
      systemd:
        name: docusnap
        state: started
        enabled: yes
  
  handlers:
    - name: Restart Nginx
      systemd:
        name: nginx
        state: restarted
```

## 总结

DocuSnap-Backend 系统的部署技术栈涵盖了服务器环境、运行时环境、Web 服务器、数据库、容器技术、监控工具和自动化部署等多个方面。根据不同的部署规模和需求，可以选择适当的技术组合，从单机部署的简单配置到基于 Kubernetes 的大规模分布式部署。

通过合理选择和配置这些技术，可以构建一个高效、可靠、安全的部署环境，为 DocuSnap-Backend 系统提供稳定的运行基础。同时，自动化部署和监控工具的使用，可以简化系统的维护和运营工作，提高系统的可用性和可维护性。