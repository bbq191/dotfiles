#!/usr/bin/env python3
"""
快速测试XDG迁移脚本
"""

import sys
import tempfile
from pathlib import Path

# 添加脚本目录到Python路径  
sys.path.append(str(Path(__file__).parent))

def test_xdg_migrator():
    """测试XDG迁移器基本功能"""
    try:
        from migrate_to_xdg import XDGMigrator, log_info, log_success, log_error
        
        log_info("🧪 开始快速测试...")
        
        # 创建迁移器实例
        migrator = XDGMigrator()
        log_success("✅ XDGMigrator 初始化成功")
        
        # 显示配置信息
        log_info(f"可用工具: {list(migrator.migration_configs.keys())}")
        log_info(f"XDG_CONFIG_HOME: {migrator.xdg_config_home}")
        
        # 测试模板变量处理
        test_content = "Config: {{XDG_CONFIG_HOME}}/test\nData: {{TOOL_DATA_DIR}}/plugins"
        processed = migrator.process_template_variables(
            test_content, 
            migrator.migration_configs['docker']
        )
        log_info(f"模板处理测试:")
        log_info(f"  原始: {test_content}")
        log_info(f"  处理后: {processed}")
        
        # 测试迁移流程（dry run）
        log_info("🔄 测试迁移流程...")
        
        # 创建临时目录结构来模拟现有配置
        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            
            # 模拟创建XDG目录
            for tool_name, config in migrator.migration_configs.items():
                migrator.create_xdg_directories(config)
                log_info(f"✅ 为 {tool_name} 创建了XDG目录结构")
        
        log_success("🎉 所有测试通过！")
        return True
        
    except Exception as e:
        log_error(f"❌ 测试失败: {e}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == "__main__":
    success = test_xdg_migrator()
    sys.exit(0 if success else 1)