#!/usr/bin/env python3
"""
SSH 配置管理器
管理 ~/.ssh/config 文件中的主机配置
"""

import os
import re
import sys
import argparse
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import shutil
from datetime import datetime

class SSHConfigManager:
    def __init__(self, config_path: Path = None):
        self.config_path = config_path or Path.home() / ".ssh" / "config"
        self.config_path.parent.mkdir(mode=0o700, exist_ok=True)
        
        # 确保配置文件存在
        if not self.config_path.exists():
            self.config_path.touch(mode=0o600)
        else:
            os.chmod(self.config_path, 0o600)
    
    def backup_config(self) -> Path:
        """备份当前配置文件"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_path = self.config_path.parent / f"config.backup.{timestamp}"
        shutil.copy2(self.config_path, backup_path)
        return backup_path
    
    def parse_config(self) -> List[Dict]:
        """解析SSH配置文件"""
        if not self.config_path.exists():
            return []
        
        with open(self.config_path, 'r') as f:
            content = f.read()
        
        hosts = []
        current_host = None
        lines = content.split('\n')
        
        for line_num, line in enumerate(lines, 1):
            line = line.strip()
            
            # 跳过空行和注释
            if not line or line.startswith('#'):
                continue
            
            # 检测 Host 定义
            if line.lower().startswith('host '):
                if current_host:
                    hosts.append(current_host)
                
                host_names = line[5:].strip()
                current_host = {
                    'names': host_names,
                    'line_start': line_num,
                    'options': {},
                    'raw_lines': [line]
                }
            elif current_host and '=' in line or ' ' in line:
                # 解析配置选项
                if ' ' in line:
                    parts = line.split(None, 1)
                    if len(parts) == 2:
                        key, value = parts
                        current_host['options'][key.lower()] = value
                        current_host['raw_lines'].append(line)
        
        # 添加最后一个主机
        if current_host:
            hosts.append(current_host)
        
        return hosts
    
    def find_host(self, host_name: str) -> Optional[Dict]:
        """查找指定的主机配置"""
        hosts = self.parse_config()
        
        for host in hosts:
            # 检查主机名是否匹配
            names = [name.strip() for name in host['names'].split()]
            if host_name in names:
                return host
        
        return None
    
    def list_hosts(self):
        """列出所有主机配置"""
        hosts = self.parse_config()
        
        if not hosts:
            print("📂 SSH配置文件中未找到主机配置")
            return
        
        print("🔧 SSH 主机配置列表:")
        print()
        
        for host in hosts:
            names = host['names']
            hostname = host['options'].get('hostname', 'N/A')
            user = host['options'].get('user', 'N/A')
            port = host['options'].get('port', '22')
            
            print(f"🖥️  {names}")
            print(f"   地址: {hostname}:{port}")
            print(f"   用户: {user}")
            
            # 显示密钥文件
            identity_file = host['options'].get('identityfile')
            if identity_file:
                print(f"   密钥: {identity_file}")
            
            # 显示其他重要选项
            important_options = ['forwardagent', 'proxyjump', 'localforward', 'remoteforward']
            for opt in important_options:
                if opt in host['options']:
                    print(f"   {opt.title()}: {host['options'][opt]}")
            
            print()
    
    def add_host(self, name: str, hostname: str, user: str = None, 
                port: int = 22, identity_file: str = None, **options):
        """添加新的主机配置"""
        # 检查主机是否已存在
        if self.find_host(name):
            print(f"❌ 主机配置已存在: {name}")
            return False
        
        # 备份当前配置
        backup_path = self.backup_config()
        print(f"📦 已备份配置到: {backup_path}")
        
        # 构建新的主机配置
        config_lines = [f"\n# 主机: {name}", f"Host {name}"]
        config_lines.append(f"    HostName {hostname}")
        
        if user:
            config_lines.append(f"    User {user}")
        
        if port != 22:
            config_lines.append(f"    Port {port}")
        
        if identity_file:
            config_lines.append(f"    IdentityFile {identity_file}")
        
        # 添加其他选项
        for key, value in options.items():
            config_lines.append(f"    {key.title()} {value}")
        
        # 添加到配置文件
        with open(self.config_path, 'a') as f:
            f.write('\n'.join(config_lines) + '\n')
        
        print(f"✅ 已添加主机配置: {name}")
        return True
    
    def remove_host(self, name: str):
        """删除主机配置"""
        host = self.find_host(name)
        if not host:
            print(f"❌ 未找到主机配置: {name}")
            return False
        
        # 备份当前配置
        backup_path = self.backup_config()
        print(f"📦 已备份配置到: {backup_path}")
        
        # 读取所有行
        with open(self.config_path, 'r') as f:
            lines = f.readlines()
        
        # 找到要删除的行范围
        start_line = host['line_start'] - 1  # 转换为0索引
        
        # 查找配置结束位置
        end_line = start_line + 1
        while end_line < len(lines):
            line = lines[end_line].strip()
            if line.lower().startswith('host ') and not line.startswith('    '):
                break
            end_line += 1
        
        # 删除配置行
        del lines[start_line:end_line]
        
        # 写回文件
        with open(self.config_path, 'w') as f:
            f.writelines(lines)
        
        print(f"✅ 已删除主机配置: {name}")
        return True
    
    def update_host(self, name: str, **options):
        """更新主机配置"""
        host = self.find_host(name)
        if not host:
            print(f"❌ 未找到主机配置: {name}")
            return False
        
        # 备份当前配置
        backup_path = self.backup_config()
        print(f"📦 已备份配置到: {backup_path}")
        
        # 读取所有行
        with open(self.config_path, 'r') as f:
            lines = f.readlines()
        
        # 找到配置范围
        start_line = host['line_start'] - 1
        end_line = start_line + 1
        while end_line < len(lines):
            line = lines[end_line].strip()
            if line.lower().startswith('host ') and not line.startswith('    '):
                break
            end_line += 1
        
        # 构建新的配置行
        new_lines = [lines[start_line]]  # Host 行
        
        # 保留现有选项并更新
        updated_options = host['options'].copy()
        updated_options.update(options)
        
        for key, value in updated_options.items():
            new_lines.append(f"    {key.title()} {value}\n")
        
        # 替换配置行
        lines[start_line:end_line] = new_lines
        
        # 写回文件
        with open(self.config_path, 'w') as f:
            f.writelines(lines)
        
        print(f"✅ 已更新主机配置: {name}")
        return True
    
    def test_host(self, name: str):
        """测试主机连接"""
        host = self.find_host(name)
        if not host:
            print(f"❌ 未找到主机配置: {name}")
            return False
        
        print(f"🔍 测试SSH连接: {name}")
        
        try:
            import subprocess
            result = subprocess.run(
                ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", 
                 name, "echo 'Connection successful'"],
                capture_output=True, text=True, timeout=15
            )
            
            if result.returncode == 0:
                print(f"✅ 连接成功: {name}")
                return True
            else:
                print(f"❌ 连接失败: {name}")
                print(f"   错误: {result.stderr.strip()}")
                return False
                
        except subprocess.TimeoutExpired:
            print(f"⏱️  连接超时: {name}")
            return False
        except Exception as e:
            print(f"❌ 测试失败: {e}")
            return False
    
    def generate_host_aliases(self) -> str:
        """生成主机别名脚本"""
        hosts = self.parse_config()
        aliases = []
        
        for host in hosts:
            names = [name.strip() for name in host['names'].split()]
            primary_name = names[0]
            
            # 生成SSH连接别名
            aliases.append(f'alias ssh-{primary_name}="ssh {primary_name}"')
            
            # 生成SCP别名
            aliases.append(f'alias scp-to-{primary_name}="scp -r \\$1 {primary_name}:\\$2"')
            aliases.append(f'alias scp-from-{primary_name}="scp -r {primary_name}:\\$1 \\$2"')
        
        return '\n'.join(aliases)
    
    def validate_config(self):
        """验证SSH配置文件的语法"""
        try:
            import subprocess
            result = subprocess.run(
                ["ssh", "-F", str(self.config_path), "-T", "nonexistent_host"],
                capture_output=True, text=True
            )
            
            # SSH会返回错误，但如果配置语法正确，错误信息不会包含语法错误
            if "Bad configuration" in result.stderr or "parse error" in result.stderr:
                print("❌ SSH配置文件语法错误:")
                print(result.stderr)
                return False
            else:
                print("✅ SSH配置文件语法正确")
                return True
                
        except Exception as e:
            print(f"❌ 配置验证失败: {e}")
            return False

def main():
    parser = argparse.ArgumentParser(description="SSH配置管理器")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")
    
    # 列出主机
    subparsers.add_parser("list", help="列出所有主机配置")
    
    # 添加主机
    add_parser = subparsers.add_parser("add", help="添加新的主机配置")
    add_parser.add_argument("name", help="主机名称")
    add_parser.add_argument("hostname", help="主机地址")
    add_parser.add_argument("--user", help="用户名")
    add_parser.add_argument("--port", type=int, default=22, help="端口号")
    add_parser.add_argument("--identity-file", help="密钥文件路径")
    
    # 删除主机
    remove_parser = subparsers.add_parser("remove", help="删除主机配置")
    remove_parser.add_argument("name", help="主机名称")
    
    # 更新主机
    update_parser = subparsers.add_parser("update", help="更新主机配置")
    update_parser.add_argument("name", help="主机名称")
    update_parser.add_argument("--hostname", help="主机地址")
    update_parser.add_argument("--user", help="用户名")
    update_parser.add_argument("--port", type=int, help="端口号")
    update_parser.add_argument("--identity-file", help="密钥文件路径")
    
    # 测试连接
    test_parser = subparsers.add_parser("test", help="测试主机连接")
    test_parser.add_argument("name", help="主机名称")
    
    # 生成别名
    subparsers.add_parser("aliases", help="生成主机别名")
    
    # 验证配置
    subparsers.add_parser("validate", help="验证配置文件语法")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = SSHConfigManager()
    
    try:
        if args.command == "list":
            manager.list_hosts()
        elif args.command == "add":
            manager.add_host(args.name, args.hostname, args.user, 
                           args.port, args.identity_file)
        elif args.command == "remove":
            manager.remove_host(args.name)
        elif args.command == "update":
            options = {}
            if args.hostname:
                options['hostname'] = args.hostname
            if args.user:
                options['user'] = args.user
            if args.port:
                options['port'] = str(args.port)
            if args.identity_file:
                options['identityfile'] = args.identity_file
            
            if options:
                manager.update_host(args.name, **options)
            else:
                print("❌ 未指定要更新的选项")
        elif args.command == "test":
            manager.test_host(args.name)
        elif args.command == "aliases":
            print("# SSH 主机别名")
            print("# 将以下内容添加到你的 shell 配置文件中")
            print()
            print(manager.generate_host_aliases())
        elif args.command == "validate":
            manager.validate_config()
    except Exception as e:
        print(f"❌ 执行失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()