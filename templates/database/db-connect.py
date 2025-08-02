#!/usr/bin/env python3
"""
数据库连接快捷工具
快速连接到预配置的数据库实例
"""

import json
import subprocess
import sys
import argparse
from pathlib import Path

class DatabaseConnector:
    def __init__(self, config_file: Path = None):
        if config_file is None:
            config_file = Path(__file__).parent / "database-connections.json"
        
        self.config_file = config_file
        self.config = self.load_config()
    
    def load_config(self) -> dict:
        """加载数据库连接配置"""
        if not self.config_file.exists():
            raise FileNotFoundError(f"配置文件不存在: {self.config_file}")
        
        with open(self.config_file, 'r', encoding='utf-8') as f:
            return json.load(f)
    
    def list_connections(self):
        """列出所有可用的数据库连接"""
        print("📊 可用的数据库连接:")
        print()
        
        for db_type, connections in self.config["connections"].items():
            print(f"🔷 {db_type.upper()}")
            for name, config in connections.items():
                alias = config.get("alias", name)
                cli_tool = config.get("cli_tool", "N/A")
                host = config.get("host", config.get("database_file", "N/A"))
                print(f"  • {alias:12} ({name}) - {cli_tool} -> {host}")
            print()
    
    def get_connection_config(self, alias_or_name: str) -> tuple:
        """根据别名或名称获取连接配置"""
        # 搜索所有连接，查找匹配的别名或名称
        for db_type, connections in self.config["connections"].items():
            for name, config in connections.items():
                if config.get("alias") == alias_or_name or name == alias_or_name:
                    return db_type, name, config
        
        return None, None, None
    
    def build_connection_command(self, db_type: str, config: dict) -> list:
        """构建连接命令"""
        cli_tool = config["cli_tool"]
        
        if cli_tool == "pgcli":
            return ["pgcli", config["connection_string"]]
        elif cli_tool == "mycli":
            cmd = ["mycli", "-u", config["username"], "-h", config["host"], 
                   "-P", str(config["port"]), config["database"]]
            if config.get("password"):
                cmd.extend(["-p", config["password"]])
            return cmd
        elif cli_tool == "redis-cli":
            cmd = ["redis-cli", "-h", config["host"], "-p", str(config["port"])]
            if config.get("database", 0) != 0:
                cmd.extend(["-n", str(config["database"])])
            return cmd
        elif cli_tool == "mongosh":
            return ["mongosh", config["connection_string"]]
        elif cli_tool == "sqlite3":
            return ["sqlite3", config["database_file"]]
        else:
            raise ValueError(f"不支持的CLI工具: {cli_tool}")
    
    def connect(self, alias_or_name: str):
        """连接到指定的数据库"""
        db_type, name, config = self.get_connection_config(alias_or_name)
        
        if not config:
            print(f"❌ 找不到数据库连接: {alias_or_name}")
            print()
            self.list_connections()
            return False
        
        try:
            cmd = self.build_connection_command(db_type, config)
            print(f"🔗 连接到 {db_type.upper()} ({name})...")
            print(f"命令: {' '.join(cmd)}")
            print()
            
            # 执行连接命令
            subprocess.run(cmd, check=True)
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 连接失败: {e}")
            return False
        except Exception as e:
            print(f"❌ 错误: {e}")
            return False
    
    def test_connection(self, alias_or_name: str):
        """测试数据库连接"""
        db_type, name, config = self.get_connection_config(alias_or_name)
        
        if not config:
            print(f"❌ 找不到数据库连接: {alias_or_name}")
            return False
        
        cli_tool = config["cli_tool"]
        
        try:
            if cli_tool == "pgcli":
                cmd = ["psql", config["connection_string"], "-c", "SELECT 1;"]
            elif cli_tool == "mycli":
                cmd = ["mysql", "-u", config["username"], "-h", config["host"], 
                       "-P", str(config["port"]), "-e", "SELECT 1;"]
                if config.get("password"):
                    cmd.insert(-2, f"-p{config['password']}")
            elif cli_tool == "redis-cli":
                cmd = ["redis-cli", "-h", config["host"], "-p", str(config["port"]), "ping"]
            elif cli_tool == "mongosh":
                cmd = ["mongosh", config["connection_string"], "--eval", "db.runCommand('ping')"]
            elif cli_tool == "sqlite3":
                cmd = ["sqlite3", config["database_file"], "SELECT 1;"]
            else:
                print(f"⚠️  暂不支持测试 {cli_tool}")
                return False
            
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                print(f"✅ {db_type.upper()} ({name}) 连接正常")
                return True
            else:
                print(f"❌ {db_type.upper()} ({name}) 连接失败:")
                print(f"   错误: {result.stderr}")
                return False
                
        except subprocess.TimeoutExpired:
            print(f"⏱️  {db_type.upper()} ({name}) 连接超时")
            return False
        except Exception as e:
            print(f"❌ {db_type.upper()} ({name}) 测试失败: {e}")
            return False
    
    def generate_aliases(self) -> str:
        """生成 shell 别名"""
        aliases = []
        script_path = Path(__file__).absolute()
        
        for db_type, connections in self.config["connections"].items():
            for name, config in connections.items():
                alias = config.get("alias")
                if alias:
                    aliases.append(f'alias {alias}="python3 {script_path} connect {alias}"')
        
        return "\n".join(aliases)

def main():
    parser = argparse.ArgumentParser(description="数据库连接快捷工具")
    parser.add_argument("command", choices=["list", "connect", "test", "aliases"], 
                       help="操作命令")
    parser.add_argument("target", nargs="?", help="数据库连接名称或别名")
    parser.add_argument("--config", type=Path, help="配置文件路径")
    
    args = parser.parse_args()
    
    try:
        connector = DatabaseConnector(args.config)
        
        if args.command == "list":
            connector.list_connections()
        elif args.command == "connect":
            if not args.target:
                parser.error("连接命令需要指定目标数据库")
            connector.connect(args.target)
        elif args.command == "test":
            if not args.target:
                parser.error("测试命令需要指定目标数据库")
            connector.test_connection(args.target)
        elif args.command == "aliases":
            print("# 数据库连接别名")
            print("# 将以下内容添加到你的 shell 配置文件中")
            print()
            print(connector.generate_aliases())
            
    except Exception as e:
        print(f"❌ 程序错误: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()