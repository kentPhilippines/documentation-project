#!/bin/bash

# 部署脚本
DEPLOY_PATH=/opt/binance-trading
BACKUP_PATH=/opt/backups/binance-trading

# 创建备份
create_backup() {
    echo "Creating backup..."
    timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p $BACKUP_PATH
    tar -czf $BACKUP_PATH/backup_$timestamp.tar.gz $DEPLOY_PATH
}

# 更新应用
update_application() {
    echo "Updating application..."
    cd $DEPLOY_PATH
    
    # 拉取最新代码
    git pull origin main
    
    # 停止当前服务
    docker-compose down backend-dev
    
    # 拉取最新镜像
    docker-compose pull backend-dev
    
    # 启动服务
    docker-compose up -d backend-dev
}

# 健康检查
health_check() {
    echo "Performing health check..."
    max_attempts=30
    attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -f http://localhost:8080/actuator/health; then
            echo "Application is healthy"
            return 0
        fi
        
        echo "Attempt $attempt of $max_attempts..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo "Health check failed"
    return 1
}

# 回滚
rollback() {
    echo "Rolling back..."
    latest_backup=$(ls -t $BACKUP_PATH | head -n1)
    if [ ! -z "$latest_backup" ]; then
        cd $DEPLOY_PATH
        docker-compose down backend-dev
        rm -rf *
        tar -xzf $BACKUP_PATH/$latest_backup -C /
        docker-compose up -d backend-dev
    else
        echo "No backup found"
        exit 1
    fi
}

# 主流程
main() {
    create_backup
    
    if update_application; then
        if health_check; then
            echo "Deployment successful"
            exit 0
        else
            echo "Health check failed, rolling back..."
            rollback
        fi
    else
        echo "Update failed, rolling back..."
        rollback
    fi
    
    exit 1
}

main 