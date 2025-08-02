#!/usr/bin/env python3
"""
GPG 密钥管理设置脚本
自动化 GPG 密钥生成、配置和 Git 集成
"""

import subprocess
import sys
import json
from pathlib import Path
from typing import Optional, Dict, List

class GPGManager:
    def __init__(self):
        self.gpg_dir = Path.home() / ".gnupg"
        
    def check_gpg_installed(self) -> bool:
        """检查 GPG 是否已安装"""
        try:
            result = subprocess.run(["gpg", "--version"], 
                                  capture_output=True, check=True)
            print("✅ GPG 已安装")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("❌ GPG 未安装，请先安装 GPG")
            return False
    
    def generate_key(self, name: str, email: str, passphrase: str = "") -> Optional[str]:
        """生成新的 GPG 密钥"""
        print(f"🔑 生成 GPG 密钥: {name} <{email}>")
        
        # GPG 密钥生成配置
        key_config = f"""
%echo Generating GPG key
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: {name}
Name-Email: {email}
Expire-Date: 2y
"""
        
        if passphrase:
            key_config += f"Passphrase: {passphrase}\n"
        else:
            key_config += "%no-protection\n"
        
        key_config += "%commit\n%echo done\n"
        
        try:
            # 写入临时配置文件
            config_file = Path.home() / "gpg_key_config.txt"
            with open(config_file, 'w') as f:
                f.write(key_config)
            
            # 生成密钥
            result = subprocess.run(
                ["gpg", "--batch", "--generate-key", str(config_file)],
                capture_output=True, text=True, check=True
            )
            
            # 删除临时配置文件
            config_file.unlink()
            
            # 获取密钥 ID
            key_id = self.get_key_id(email)
            if key_id:
                print(f"✅ GPG 密钥已生成: {key_id}")
                return key_id
            else:
                print("❌ 无法获取密钥 ID")
                return None
                
        except subprocess.CalledProcessError as e:
            print(f"❌ 密钥生成失败: {e}")
            if config_file.exists():
                config_file.unlink()
            return None
    
    def get_key_id(self, email: str) -> Optional[str]:
        """获取指定邮箱的密钥 ID"""
        try:
            result = subprocess.run(
                ["gpg", "--list-secret-keys", "--keyid-format", "LONG", email],
                capture_output=True, text=True, check=True
            )
            
            lines = result.stdout.split('\n')
            for line in lines:
                if 'sec' in line and '4096R/' in line:
                    # 提取密钥 ID
                    key_id = line.split('4096R/')[1].split()[0]
                    return key_id
            
            return None
            
        except subprocess.CalledProcessError:
            return None
    
    def list_keys(self):
        """列出所有 GPG 密钥"""
        try:
            result = subprocess.run(
                ["gpg", "--list-secret-keys", "--keyid-format", "LONG"],
                capture_output=True, text=True, check=True
            )
            
            print("🔑 GPG 密钥列表:")
            print(result.stdout)
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 无法列出密钥: {e}")
    
    def export_public_key(self, key_id: str) -> Optional[str]:
        """导出公钥"""
        try:
            result = subprocess.run(
                ["gpg", "--armor", "--export", key_id],
                capture_output=True, text=True, check=True
            )
            
            return result.stdout
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 导出公钥失败: {e}")
            return None
    
    def configure_git(self, key_id: str, name: str, email: str):
        """配置 Git 使用 GPG 签名"""
        try:
            # 配置 Git 用户信息
            subprocess.run(["git", "config", "--global", "user.name", name], check=True)
            subprocess.run(["git", "config", "--global", "user.email", email], check=True)
            
            # 配置 GPG 签名
            subprocess.run(["git", "config", "--global", "user.signingkey", key_id], check=True)
            subprocess.run(["git", "config", "--global", "commit.gpgsign", "true"], check=True)
            subprocess.run(["git", "config", "--global", "tag.gpgsign", "true"], check=True)
            
            print(f"✅ Git 已配置使用 GPG 密钥: {key_id}")
            
        except subprocess.CalledProcessError as e:
            print(f"❌ Git 配置失败: {e}")
    
    def setup_gpg_agent(self):
        """配置 GPG Agent"""
        gpg_agent_conf = self.gpg_dir / "gpg-agent.conf"
        
        config_content = """# GPG Agent 配置
default-cache-ttl 28800
max-cache-ttl 86400
pinentry-program pinentry-qt
"""
        
        with open(gpg_agent_conf, 'w') as f:
            f.write(config_content)
        
        print("✅ GPG Agent 已配置")
    
    def backup_keys(self, key_id: str, backup_dir: str = None):
        """备份 GPG 密钥"""
        if not backup_dir:
            backup_dir = Path.home() / "gpg_backup"
        else:
            backup_dir = Path(backup_dir)
        
        backup_dir.mkdir(exist_ok=True)
        
        # 备份公钥
        public_key_file = backup_dir / f"{key_id}_public.asc"
        try:
            result = subprocess.run(
                ["gpg", "--armor", "--export", key_id],
                capture_output=True, text=True, check=True
            )
            
            with open(public_key_file, 'w') as f:
                f.write(result.stdout)
            
            print(f"✅ 公钥已备份: {public_key_file}")
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 公钥备份失败: {e}")
        
        # 备份私钥
        private_key_file = backup_dir / f"{key_id}_private.asc"
        try:
            result = subprocess.run(
                ["gpg", "--armor", "--export-secret-keys", key_id],
                capture_output=True, text=True, check=True
            )
            
            with open(private_key_file, 'w') as f:
                f.write(result.stdout)
            
            print(f"✅ 私钥已备份: {private_key_file}")
            
        except subprocess.CalledProcessError as e:
            print(f"❌ 私钥备份失败: {e}")

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="GPG 密钥管理设置")
    parser.add_argument("--name", help="用户姓名")
    parser.add_argument("--email", help="用户邮箱")
    parser.add_argument("--passphrase", help="密钥密码（可选）")
    parser.add_argument("--list", action="store_true", help="列出现有密钥")
    parser.add_argument("--backup", help="备份密钥的目录")
    
    args = parser.parse_args()
    
    manager = GPGManager()
    
    if not manager.check_gpg_installed():
        sys.exit(1)
    
    if args.list:
        manager.list_keys()
        return
    
    if args.name and args.email:
        # 生成新密钥
        key_id = manager.generate_key(args.name, args.email, args.passphrase or "")
        
        if key_id:
            # 配置 Git
            manager.configure_git(key_id, args.name, args.email)
            
            # 设置 GPG Agent
            manager.setup_gpg_agent()
            
            # 显示公钥
            public_key = manager.export_public_key(key_id)
            if public_key:
                print("\n📋 公钥内容（可添加到 GitHub/GitLab）:")
                print(public_key)
            
            # 备份密钥
            if args.backup:
                manager.backup_keys(key_id, args.backup)
            
            print(f"\n🎉 GPG 设置完成！")
            print(f"   密钥 ID: {key_id}")
            print(f"   Git 已配置自动签名")
    else:
        parser.print_help()

if __name__ == "__main__":
    main()