#!/bin/bash
# 数据库开发环境快速设置脚本
# 使用 Docker 快速启动常用数据库服务

set -euo pipefail

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查 Docker 是否运行
check_docker() {
    if ! docker info &> /dev/null; then
        log_error "Docker 未运行，请先启动 Docker"
        exit 1
    fi
    log_success "Docker 运行正常"
}

# 启动 PostgreSQL
start_postgres() {
    local container_name="dev-postgres"
    local port="${1:-5432}"
    local password="${2:-password}"
    
    log_info "启动 PostgreSQL 容器..."
    
    if docker ps -a --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "容器 ${container_name} 已存在，正在重启..."
        docker restart "${container_name}"
    else
        docker run -d \
            --name "${container_name}" \
            -e POSTGRES_PASSWORD="${password}" \
            -e POSTGRES_DB=myapp_dev \
            -p "${port}:5432" \
            -v postgres_dev_data:/var/lib/postgresql/data \
            postgres:15-alpine
    fi
    
    log_success "PostgreSQL 已启动在端口 ${port}"
    log_info "连接命令: pgcli postgresql://postgres:${password}@localhost:${port}/myapp_dev"
}

# 启动 MySQL
start_mysql() {
    local container_name="dev-mysql"
    local port="${1:-3306}"
    local password="${2:-password}"
    
    log_info "启动 MySQL 容器..."
    
    if docker ps -a --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "容器 ${container_name} 已存在，正在重启..."
        docker restart "${container_name}"
    else
        docker run -d \
            --name "${container_name}" \
            -e MYSQL_ROOT_PASSWORD="${password}" \
            -e MYSQL_DATABASE=myapp_dev \
            -p "${port}:3306" \
            -v mysql_dev_data:/var/lib/mysql \
            mysql:8.0
    fi
    
    log_success "MySQL 已启动在端口 ${port}"
    log_info "连接命令: mycli -u root -p${password} -h localhost -P ${port} myapp_dev"
}

# 启动 Redis
start_redis() {
    local container_name="dev-redis"
    local port="${1:-6379}"
    
    log_info "启动 Redis 容器..."
    
    if docker ps -a --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "容器 ${container_name} 已存在，正在重启..."
        docker restart "${container_name}"
    else
        docker run -d \
            --name "${container_name}" \
            -p "${port}:6379" \
            -v redis_dev_data:/data \
            redis:7-alpine redis-server --appendonly yes
    fi
    
    log_success "Redis 已启动在端口 ${port}"
    log_info "连接命令: redis-cli -h localhost -p ${port}"
}

# 启动 MongoDB
start_mongodb() {
    local container_name="dev-mongodb"
    local port="${1:-27017}"
    local username="${2:-admin}"
    local password="${3:-password}"
    
    log_info "启动 MongoDB 容器..."
    
    if docker ps -a --format 'table {{.Names}}' | grep -q "^${container_name}$"; then
        log_warn "容器 ${container_name} 已存在，正在重启..."
        docker restart "${container_name}"
    else
        docker run -d \
            --name "${container_name}" \
            -e MONGO_INITDB_ROOT_USERNAME="${username}" \
            -e MONGO_INITDB_ROOT_PASSWORD="${password}" \
            -e MONGO_INITDB_DATABASE=myapp_dev \
            -p "${port}:27017" \
            -v mongodb_dev_data:/data/db \
            mongo:6
    fi
    
    log_success "MongoDB 已启动在端口 ${port}"
    log_info "连接命令: mongosh mongodb://${username}:${password}@localhost:${port}/myapp_dev"
}

# 停止所有数据库容器
stop_all() {
    log_info "停止所有开发数据库容器..."
    
    local containers=("dev-postgres" "dev-mysql" "dev-redis" "dev-mongodb")
    
    for container in "${containers[@]}"; do
        if docker ps --format 'table {{.Names}}' | grep -q "^${container}$"; then
            log_info "停止容器: ${container}"
            docker stop "${container}"
        fi
    done
    
    log_success "所有容器已停止"
}

# 清理所有数据库容器和数据
cleanup_all() {
    log_warn "这将删除所有开发数据库容器和数据，无法恢复！"
    read -p "确认继续？ (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "操作已取消"
        return
    fi
    
    log_info "清理所有开发数据库容器和数据..."
    
    local containers=("dev-postgres" "dev-mysql" "dev-redis" "dev-mongodb")
    local volumes=("postgres_dev_data" "mysql_dev_data" "redis_dev_data" "mongodb_dev_data")
    
    # 停止并删除容器
    for container in "${containers[@]}"; do
        if docker ps -a --format 'table {{.Names}}' | grep -q "^${container}$"; then
            log_info "删除容器: ${container}"
            docker rm -f "${container}"
        fi
    done
    
    # 删除数据卷
    for volume in "${volumes[@]}"; do
        if docker volume ls --format 'table {{.Name}}' | grep -q "^${volume}$"; then
            log_info "删除数据卷: ${volume}"
            docker volume rm "${volume}"
        fi
    done
    
    log_success "清理完成"
}

# 显示状态
show_status() {
    log_info "数据库容器状态:"
    echo
    
    local containers=("dev-postgres" "dev-mysql" "dev-redis" "dev-mongodb")
    
    for container in "${containers[@]}"; do
        if docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep -q "^${container}"; then
            echo -e "${GREEN}✓${NC} ${container}:"
            docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep "^${container}"
        else
            echo -e "${RED}✗${NC} ${container}: 未运行"
        fi
        echo
    done
}

# 显示帮助
show_help() {
    cat << EOF
数据库开发环境快速设置脚本

用法: $0 <command> [options]

命令:
  postgres [port] [password]  启动 PostgreSQL (默认: 5432, password)
  mysql [port] [password]     启动 MySQL (默认: 3306, password)  
  redis [port]                启动 Redis (默认: 6379)
  mongodb [port] [user] [pwd] 启动 MongoDB (默认: 27017, admin, password)
  all                         启动所有数据库
  stop                        停止所有数据库容器
  status                      显示容器状态
  cleanup                     清理所有容器和数据（危险操作）
  help                        显示此帮助信息

示例:
  $0 postgres              # 启动 PostgreSQL，默认端口和密码
  $0 postgres 5433 mypass  # 启动 PostgreSQL，自定义端口和密码
  $0 all                   # 启动所有数据库
  $0 status                # 查看状态
  $0 stop                  # 停止所有服务

EOF
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        show_help
        exit 0
    fi
    
    # 检查 Docker（除了 help 命令）
    if [[ "$1" != "help" ]]; then
        check_docker
    fi
    
    case "$1" in
        postgres)
            start_postgres "${2:-5432}" "${3:-password}"
            ;;
        mysql)
            start_mysql "${2:-3306}" "${3:-password}"
            ;;
        redis)
            start_redis "${2:-6379}"
            ;;
        mongodb)
            start_mongodb "${2:-27017}" "${3:-admin}" "${4:-password}"
            ;;
        all)
            start_postgres
            start_mysql
            start_redis
            start_mongodb
            echo
            show_status
            ;;
        stop)
            stop_all
            ;;
        status)
            show_status
            ;;
        cleanup)
            cleanup_all
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"