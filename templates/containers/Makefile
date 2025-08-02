# Docker 开发环境 Makefile
# 简化常用容器操作命令

.PHONY: help build up down logs shell clean restart

# 默认目标
help: ## 显示帮助信息
	@echo "可用命令:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 构建相关
build: ## 构建开发环境镜像
	docker-compose -f docker-compose.dev.yml build

build-prod: ## 构建生产环境镜像
	docker-compose -f docker-compose.yml build

# 运行相关
up: ## 启动开发环境
	docker-compose -f docker-compose.dev.yml up -d

up-logs: ## 启动开发环境并显示日志
	docker-compose -f docker-compose.dev.yml up

down: ## 停止并删除容器
	docker-compose -f docker-compose.dev.yml down

restart: ## 重启服务
	docker-compose -f docker-compose.dev.yml restart

# 日志和调试
logs: ## 查看所有服务日志
	docker-compose -f docker-compose.dev.yml logs -f

logs-app: ## 查看应用服务日志
	docker-compose -f docker-compose.dev.yml logs -f app

shell: ## 进入应用容器 shell
	docker-compose -f docker-compose.dev.yml exec app sh

shell-db: ## 进入数据库容器 shell
	docker-compose -f docker-compose.dev.yml exec postgres psql -U postgres -d myapp_dev

# 数据库操作
db-reset: ## 重置数据库
	docker-compose -f docker-compose.dev.yml exec app npm run db:reset

db-migrate: ## 运行数据库迁移
	docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

db-seed: ## 运行数据库种子数据
	docker-compose -f docker-compose.dev.yml exec app npm run db:seed

# 清理
clean: ## 清理未使用的镜像和容器
	docker system prune -f

clean-all: ## 清理所有 Docker 资源（危险操作）
	docker system prune -a -f
	docker volume prune -f

# 测试
test: ## 在容器中运行测试
	docker-compose -f docker-compose.dev.yml exec app npm test

test-watch: ## 在容器中运行测试（监视模式）
	docker-compose -f docker-compose.dev.yml exec app npm run test:watch

# 开发工具
install: ## 在容器中安装新的 npm 包
	docker-compose -f docker-compose.dev.yml exec app npm install

lint: ## 运行代码检查
	docker-compose -f docker-compose.dev.yml exec app npm run lint

format: ## 格式化代码
	docker-compose -f docker-compose.dev.yml exec app npm run format