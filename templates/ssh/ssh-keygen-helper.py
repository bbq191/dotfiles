#!/usr/bin/env python3
"""
SSH 密钥管理助手
简化 SSH 密钥的生成、管理和配置
"""

import os
import subprocess
import sys
import json
from pathlib import Path
from typing import Dict, List, Optional
import argparse

class SSHKeyManager:
    def __init__(self):
        self.ssh_dir = Path.home() / ".ssh"
        self.ssh_dir.mkdir(mode=0o700, exist_ok=True)
        self.config_file = self.ssh_dir / "config"
        self.key_registry = self.ssh_dir / "key_registry.json"
        
    def load_key_registry(self) -> Dict:
        """加载密钥注册表"""
        if self.key_registry.exists():
            with open(self.key_registry, 'r') as f:
                return json.load(f)
        return {"keys": {}, "version": "1.0.0"}
    
    def save_key_registry(self, registry: Dict):
        """保存密钥注册表"""
        with open(self.key_registry, 'w') as f:
            json.dump(registry, f, indent=2)
        os.chmod(self.key_registry, 0o600)
    
    def generate_key(self, name: str, key_type: str = "ed25519", 
                    comment: str = None, passphrase: str = None) -> bool:
        """生成新的SSH密钥对"""
        if not comment:
            comment = f"{os.getenv('USER', 'user')}@{name}"
        
        key_path = self.ssh_dir / f"id_{key_type}_{name}"
        
        if key_path.exists():
            print(f"❌ 密钥已存在: {key_path}")
            return False
        
        cmd = [
            "ssh-keygen",
            "-t", key_type,
            "-f", str(key_path),
            "-C", comment
        ]
        
        if key_type == "rsa":
            cmd.extend(["-b", "4096"])
        
        if passphrase is not None:
            if passphrase:
                cmd.extend(["-N", passphrase])
            else:
                cmd.extend(["-N", ""])
        
        try:
            print(f"🔑 生成 {key_type.upper()} 密钥: {name}")
            result = subprocess.run(cmd, check=True, capture_output=True, text=True)
            
            # 设置正确的权限
            os.chmod(key_path, 0o600)
            os.chmod(f"{key_path}.pub", 0o644)
            
            # 记录到注册表
            registry = self.load_key_registry()
            registry["keys"][name] = {
                "type": key_type,
                "private_key": str(key_path),
                "public_key": f"{key_path}.pub",
                "comment": comment,
                "created_at": subprocess.run(["date", "-Iseconds"], 
                                           capture_output=True, text=True).stdout.strip(),
                "fingerprint": self.get_key_fingerprint(key_path)
            }
            self.save_key_registry(registry)
            
            print(f"✅ 密钥已生成: {key_path}")
            print(f"📋 公钥内容:")
            with open(f"{key_path}.pub", 'r') as f:
                print(f"   {f.read().strip()}")
            
            return True
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 密钥生成失败: {e}")
            return False
    
    def get_key_fingerprint(self, key_path: Path) -> str:
        """获取密钥指纹"""
        try:
            result = subprocess.run(
                ["ssh-keygen", "-lf", str(key_path)],
                capture_output=True, text=True, check=True
            )
            return result.stdout.strip().split()[1]
        except subprocess.CalledProcessError:
            return "unknown"
    
    def list_keys(self):
        """列出所有SSH密钥"""
        registry = self.load_key_registry()
        
        if not registry["keys"]:
            print("📂 未找到已注册的SSH密钥")
            return
        
        print("🔑 SSH 密钥列表:")
        print()
        
        for name, info in registry["keys"].items():
            key_path = Path(info["private_key"])
            pub_path = Path(info["public_key"])
            
            status = "✅" if key_path.exists() and pub_path.exists() else "❌"
            print(f"{status} {name} ({info['type'].upper()})")
            print(f"   私钥: {info['private_key']}")
            print(f"   公钥: {info['public_key']}")
            print(f"   注释: {info['comment']}")
            print(f"   指纹: {info['fingerprint']}")
            print(f"   创建: {info.get('created_at', 'N/A')}")
            print()
    
    def show_public_key(self, name: str):
        """显示指定密钥的公钥内容"""
        registry = self.load_key_registry()
        
        if name not in registry["keys"]:
            print(f"❌ 未找到密钥: {name}")
            return False
        
        pub_path = Path(registry["keys"][name]["public_key"])
        
        if not pub_path.exists():
            print(f"❌ 公钥文件不存在: {pub_path}")
            return False
        
        with open(pub_path, 'r') as f:
            content = f.read().strip()
        
        print(f"📋 {name} 公钥内容:")
        print(content)
        print()
        print("💡 复制命令:")
        print(f"   cat {pub_path} | clip")  # Windows
        print(f"   cat {pub_path} | pbcopy")  # macOS
        print(f"   cat {pub_path} | xclip -selection clipboard")  # Linux
        
        return True
    
    def add_to_agent(self, name: str = None):
        """将密钥添加到SSH代理"""
        registry = self.load_key_registry()
        
        if name:
            if name not in registry["keys"]:
                print(f"❌ 未找到密钥: {name}")
                return False
            keys_to_add = [registry["keys"][name]["private_key"]]
        else:
            keys_to_add = [info["private_key"] for info in registry["keys"].values()]
        
        added_count = 0
        
        for key_path in keys_to_add:
            try:
                subprocess.run(["ssh-add", key_path], check=True, 
                             capture_output=True, text=True)
                print(f"✅ 已添加到代理: {Path(key_path).name}")
                added_count += 1
            except subprocess.CalledProcessError as e:
                print(f"❌ 添加失败 {Path(key_path).name}: {e}")
        
        print(f"📊 总计添加 {added_count} 个密钥到SSH代理")
        return added_count > 0
    
    def test_connection(self, host: str):
        """测试SSH连接"""
        print(f"🔍 测试SSH连接: {host}")
        
        try:
            result = subprocess.run(
                ["ssh", "-o", "BatchMode=yes", "-o", "ConnectTimeout=10", 
                 host, "echo 'SSH连接成功'"],
                capture_output=True, text=True, timeout=15
            )
            
            if result.returncode == 0:
                print(f"✅ 连接成功: {host}")
                print(f"   输出: {result.stdout.strip()}")
                return True
            else:
                print(f"❌ 连接失败: {host}")
                print(f"   错误: {result.stderr.strip()}")
                return False
                
        except subprocess.TimeoutExpired:
            print(f"⏱️  连接超时: {host}")
            return False
        except Exception as e:
            print(f"❌ 测试失败: {e}")
            return False
    
    def backup_keys(self, backup_dir: str = None):
        """备份SSH密钥"""
        if not backup_dir:
            backup_dir = Path.home() / "ssh_backup"
        else:
            backup_dir = Path(backup_dir)
        
        backup_dir.mkdir(exist_ok=True)
        
        registry = self.load_key_registry()
        backed_up = []
        
        print(f"📦 备份SSH密钥到: {backup_dir}")
        
        for name, info in registry["keys"].items():
            private_path = Path(info["private_key"])
            public_path = Path(info["public_key"])
            
            if private_path.exists():
                backup_private = backup_dir / private_path.name
                subprocess.run(["cp", str(private_path), str(backup_private)], check=True)
                os.chmod(backup_private, 0o600)
                backed_up.append(str(backup_private))
            
            if public_path.exists():
                backup_public = backup_dir / public_path.name
                subprocess.run(["cp", str(public_path), str(backup_public)], check=True)
                backed_up.append(str(backup_public))
        
        # 备份配置文件
        if self.config_file.exists():
            backup_config = backup_dir / "config"
            subprocess.run(["cp", str(self.config_file), str(backup_config)], check=True)
            backed_up.append(str(backup_config))
        
        # 备份注册表
        backup_registry = backup_dir / "key_registry.json"
        subprocess.run(["cp", str(self.key_registry), str(backup_registry)], check=True)
        backed_up.append(str(backup_registry))
        
        print(f"✅ 已备份 {len(backed_up)} 个文件")
        return backed_up
    
    def remove_key(self, name: str):
        """删除SSH密钥"""
        registry = self.load_key_registry()
        
        if name not in registry["keys"]:
            print(f"❌ 未找到密钥: {name}")
            return False
        
        info = registry["keys"][name]
        private_path = Path(info["private_key"])
        public_path = Path(info["public_key"])
        
        print(f"⚠️  即将删除密钥: {name}")
        print(f"   私钥: {private_path}")
        print(f"   公钥: {public_path}")
        
        confirm = input("确认删除？ (y/N): ").lower()
        if confirm != 'y':
            print("❌ 操作已取消")
            return False
        
        # 删除文件
        deleted = []
        if private_path.exists():
            private_path.unlink()
            deleted.append(str(private_path))
        
        if public_path.exists():
            public_path.unlink()
            deleted.append(str(public_path))
        
        # 从注册表中移除
        del registry["keys"][name]
        self.save_key_registry(registry)
        
        print(f"✅ 已删除密钥: {name}")
        print(f"   删除的文件: {', '.join(deleted)}")
        
        return True

def main():
    parser = argparse.ArgumentParser(description="SSH密钥管理助手")
    subparsers = parser.add_subparsers(dest="command", help="可用命令")
    
    # 生成密钥
    gen_parser = subparsers.add_parser("generate", help="生成新的SSH密钥")
    gen_parser.add_argument("name", help="密钥名称")
    gen_parser.add_argument("--type", default="ed25519", 
                           choices=["ed25519", "rsa", "ecdsa"],
                           help="密钥类型")
    gen_parser.add_argument("--comment", help="密钥注释")
    gen_parser.add_argument("--passphrase", help="密钥密码")
    
    # 列出密钥
    subparsers.add_parser("list", help="列出所有SSH密钥")
    
    # 显示公钥
    show_parser = subparsers.add_parser("show", help="显示公钥内容")
    show_parser.add_argument("name", help="密钥名称")
    
    # 添加到代理
    agent_parser = subparsers.add_parser("add-agent", help="添加密钥到SSH代理")
    agent_parser.add_argument("name", nargs="?", help="密钥名称（可选，默认添加所有）")
    
    # 测试连接
    test_parser = subparsers.add_parser("test", help="测试SSH连接")
    test_parser.add_argument("host", help="主机名或配置名")
    
    # 备份密钥
    backup_parser = subparsers.add_parser("backup", help="备份SSH密钥")
    backup_parser.add_argument("--dir", help="备份目录")
    
    # 删除密钥
    remove_parser = subparsers.add_parser("remove", help="删除SSH密钥")
    remove_parser.add_argument("name", help="密钥名称")
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    manager = SSHKeyManager()
    
    try:
        if args.command == "generate":
            manager.generate_key(args.name, args.type, args.comment, args.passphrase)
        elif args.command == "list":
            manager.list_keys()
        elif args.command == "show":
            manager.show_public_key(args.name)
        elif args.command == "add-agent":
            manager.add_to_agent(args.name)
        elif args.command == "test":
            manager.test_connection(args.host)
        elif args.command == "backup":
            manager.backup_keys(args.dir)
        elif args.command == "remove":
            manager.remove_key(args.name)
    except Exception as e:
        print(f"❌ 执行失败: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()