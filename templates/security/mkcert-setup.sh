#!/bin/bash
# mkcert 本地开发证书管理脚本

set -euo pipefail

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 检查 mkcert 是否已安装
check_mkcert() {
    if ! command -v mkcert &> /dev/null; then
        log_error "mkcert 未安装，请先安装"
        exit 1
    fi
    log_info "mkcert 已安装"
}

# 安装根证书
install_ca() {
    log_info "安装 mkcert 根证书..."
    mkcert -install
    log_info "✅ 根证书已安装"
}

# 生成开发证书
generate_cert() {
    local domains=("$@")
    
    if [ ${#domains[@]} -eq 0 ]; then
        domains=("localhost" "127.0.0.1" "::1")
    fi
    
    log_info "生成证书，域名: ${domains[*]}"
    mkcert "${domains[@]}"
    
    # 移动到 certs 目录
    mkdir -p certs
    mv ./*.pem certs/ 2>/dev/null || true
    
    log_info "✅ 证书已生成到 certs/ 目录"
}

# 生成通配符证书
generate_wildcard() {
    local domain="$1"
    log_info "生成通配符证书: *.${domain}"
    mkcert "*.${domain}" "${domain}"
    
    mkdir -p certs
    mv ./*.pem certs/ 2>/dev/null || true
    
    log_info "✅ 通配符证书已生成"
}

# 显示帮助
show_help() {
    cat << EOF
mkcert 本地开发证书管理脚本

用法: $0 <command> [options]

命令:
  install-ca              安装根证书
  generate [domains...]   生成证书（默认: localhost 127.0.0.1 ::1）
  wildcard <domain>       生成通配符证书
  help                    显示帮助

示例:
  $0 install-ca
  $0 generate localhost myapp.local
  $0 wildcard example.local

EOF
}

main() {
    check_mkcert
    
    case "${1:-help}" in
        install-ca)
            install_ca
            ;;
        generate)
            shift
            generate_cert "$@"
            ;;
        wildcard)
            if [ $# -lt 2 ]; then
                log_error "请指定域名"
                exit 1
            fi
            generate_wildcard "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

main "$@"