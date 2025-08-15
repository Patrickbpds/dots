#!/usr/bin/env python3
"""
Configuration migration tool for Quickshell Heimdall
Migrates from QML-based configuration to JSON configuration
"""

import json
import os
import sys
import re
from pathlib import Path
from datetime import datetime
from typing import Dict, Any, List, Optional

class ConfigMigrator:
    def __init__(self):
        self.qml_dir = Path.home() / ".config/quickshell/heimdall/config"
        self.output_file = Path.home() / ".config/quickshell/heimdall/shell.json"
        self.version = "1.0.0"
        
    def migrate(self, input_path: Optional[str] = None, output_path: Optional[str] = None) -> bool:
        """Main migration function"""
        
        if output_path:
            self.output_file = Path(output_path)
        
        # Check if output already exists
        if self.output_file.exists():
            print(f"Warning: {self.output_file} already exists")
            response = input("Overwrite? (y/n): ")
            if response.lower() != 'y':
                print("Migration cancelled")
                return False
        
        # Create new configuration
        config = self.create_base_config()
        
        # Migrate from QML files
        if input_path:
            # Migrate from existing JSON
            config = self.migrate_from_json(input_path, config)
        else:
            # Migrate from QML files
            config = self.migrate_from_qml(config)
        
        # Save configuration
        return self.save_config(config)
    
    def create_base_config(self) -> Dict[str, Any]:
        """Create base configuration structure"""
        return {
            "version": self.version,
            "metadata": {
                "created": datetime.now().isoformat() + "Z",
                "lastModified": datetime.now().isoformat() + "Z",
                "profile": "default",
                "migratedFrom": "qml"
            },
            "system": self.get_system_defaults(),
            "appearance": {},
            "bar": {},
            "modules": {},
            "services": {},
            "commands": {},
            "wallpaper": self.get_wallpaper_defaults(),
            "hotReload": {
                "enabled": True,
                "debounceMs": 500,
                "validateSchema": True,
                "backupOnChange": True
            }
        }
    
    def get_system_defaults(self) -> Dict[str, Any]:
        """Get system configuration defaults"""
        return {
            "startup": {
                "sequence": [
                    {"name": "display-init", "delay": 0},
                    {"name": "wallpaper-daemon", "delay": 500},
                    {"name": "restore-wallpaper", "delay": 1000},
                    {"name": "quickshell", "delay": 1500},
                    {"name": "docker-desktop", "delay": 2000}
                ],
                "daemons": {
                    "wallpaper": "swww-daemon --format xrgb",
                    "fallback": "hyprpaper"
                }
            },
            "paths": {
                "state": "~/.local/state/quickshell/user/generated",
                "cache": "~/.cache/quickshell",
                "config": "~/.config/quickshell/heimdall",
                "wallpaperDir": "~/Pictures/Wallpapers",
                "wallpaperState": "~/.local/state/quickshell/user/generated/wallpaper/path.txt"
            },
            "environment": {
                "HEIMDALL_STATE_DIR": "$HOME/.local/state/quickshell/user/generated",
                "QS_CONFIG_NAME": "heimdall",
                "HEIMDALL_BACKEND": "swww"
            }
        }
    
    def get_wallpaper_defaults(self) -> Dict[str, Any]:
        """Get wallpaper configuration defaults"""
        wallpaper_path = Path.home() / ".local/state/quickshell/user/generated/wallpaper/path.txt"
        current_wallpaper = "~/Pictures/Wallpapers/Autumn-Alley.jpg"
        
        if wallpaper_path.exists():
            try:
                current_wallpaper = wallpaper_path.read_text().strip()
            except:
                pass
        
        return {
            "current": current_wallpaper,
            "mode": "fill",
            "transition": {
                "type": "fade",
                "duration": 300
            }
        }
    
    def migrate_from_qml(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate configuration from QML files"""
        print("Migrating from QML configuration files...")
        
        # Map of QML files to configuration sections
        qml_mappings = {
            "AppearanceConfig.qml": "appearance",
            "BarConfig.qml": "bar",
            "SessionConfig.qml": "commands",
            "ServiceConfig.qml": "services",
            "DashboardConfig.qml": "modules.dashboard",
            "LauncherConfig.qml": "modules.launcher",
            "NotifsConfig.qml": "modules.notifications",
            "LockConfig.qml": "modules.lockScreen",
            "ControlCenterConfig.qml": "modules.controlCenter"
        }
        
        for qml_file, config_path in qml_mappings.items():
            qml_path = self.qml_dir / qml_file
            if qml_path.exists():
                print(f"  Processing {qml_file}...")
                self.parse_qml_file(qml_path, config, config_path)
        
        # Fix specific issues
        config = self.apply_fixes(config)
        
        return config
    
    def parse_qml_file(self, qml_path: Path, config: Dict[str, Any], config_path: str) -> None:
        """Parse a QML file and extract configuration"""
        try:
            content = qml_path.read_text()
            
            # Extract property definitions
            properties = self.extract_qml_properties(content)
            
            # Apply to configuration
            self.set_nested_value(config, config_path, properties)
            
        except Exception as e:
            print(f"    Warning: Failed to parse {qml_path.name}: {e}")
    
    def extract_qml_properties(self, content: str) -> Dict[str, Any]:
        """Extract properties from QML content"""
        properties = {}
        
        # Pattern for simple properties
        prop_pattern = r'property\s+(\w+)\s+(\w+):\s*(.+?)(?:\n|$)'
        
        for match in re.finditer(prop_pattern, content):
            prop_type = match.group(1)
            prop_name = match.group(2)
            prop_value = match.group(3).strip()
            
            # Convert QML value to Python value
            value = self.convert_qml_value(prop_type, prop_value)
            if value is not None:
                properties[prop_name] = value
        
        # Pattern for list properties
        list_pattern = r'property\s+list<string>\s+(\w+):\s*\[(.*?)\]'
        
        for match in re.finditer(list_pattern, content, re.DOTALL):
            prop_name = match.group(1)
            list_content = match.group(2)
            
            # Parse list items
            items = []
            for item in re.findall(r'"([^"]*)"', list_content):
                items.append(item)
            
            properties[prop_name] = items
        
        return properties
    
    def convert_qml_value(self, prop_type: str, value: str) -> Any:
        """Convert QML value to Python value"""
        value = value.rstrip(';')
        
        if prop_type == "bool":
            return value.lower() == "true"
        elif prop_type == "int":
            try:
                return int(value)
            except:
                return None
        elif prop_type == "real" or prop_type == "double":
            try:
                return float(value)
            except:
                return None
        elif prop_type == "string":
            # Remove quotes
            if value.startswith('"') and value.endswith('"'):
                return value[1:-1]
            return value
        else:
            # Try to parse as JSON
            try:
                return json.loads(value)
            except:
                return None
    
    def set_nested_value(self, config: Dict[str, Any], path: str, value: Any) -> None:
        """Set a nested value in the configuration"""
        parts = path.split('.')
        current = config
        
        for part in parts[:-1]:
            if part not in current:
                current[part] = {}
            current = current[part]
        
        # Merge with existing values
        if isinstance(value, dict) and parts[-1] in current and isinstance(current[parts[-1]], dict):
            current[parts[-1]].update(value)
        else:
            current[parts[-1]] = value
    
    def apply_fixes(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Apply specific fixes for known issues"""
        
        # Fix logout command
        if "commands" in config:
            if "logout" not in config["commands"] or not config["commands"]["logout"]:
                config["commands"]["logout"] = ["loginctl", "terminate-user", "${USER}"]
            elif isinstance(config["commands"]["logout"], list) and len(config["commands"]["logout"]) > 2:
                # Fix empty username parameter
                if config["commands"]["logout"][2] == "":
                    config["commands"]["logout"][2] = "${USER}"
        
        # Add default commands if missing
        default_commands = {
            "terminal": "kitty",
            "browser": "firefox",
            "fileManager": "nemo",
            "editor": "code",
            "shutdown": ["systemctl", "poweroff"],
            "reboot": ["systemctl", "reboot"],
            "hibernate": ["systemctl", "hibernate"],
            "lock": ["hyprlock"],
            "screenshot": ["grimblast", "copy", "area"]
        }
        
        if "commands" not in config:
            config["commands"] = {}
        
        for cmd, value in default_commands.items():
            if cmd not in config["commands"]:
                config["commands"][cmd] = value
        
        # Ensure appearance has required structure
        if "appearance" not in config or not config["appearance"]:
            config["appearance"] = self.get_appearance_defaults()
        
        # Ensure bar configuration
        if "bar" not in config or not config["bar"]:
            config["bar"] = self.get_bar_defaults()
        
        return config
    
    def get_appearance_defaults(self) -> Dict[str, Any]:
        """Get appearance configuration defaults"""
        return {
            "rounding": {
                "scale": 1.0,
                "small": 12,
                "normal": 17,
                "large": 25,
                "full": 1000
            },
            "spacing": {
                "scale": 1.0,
                "small": 7,
                "smaller": 5,
                "normal": 12,
                "larger": 15,
                "large": 20
            },
            "padding": {
                "scale": 1.0,
                "small": 7,
                "smaller": 5,
                "normal": 12,
                "larger": 15,
                "large": 20
            },
            "font": {
                "family": {
                    "sans": "IBM Plex Sans",
                    "mono": "JetBrains Mono NF",
                    "material": "Material Symbols Rounded"
                },
                "size": {
                    "scale": 1.0,
                    "small": 11,
                    "normal": 13,
                    "large": 18,
                    "extraLarge": 24
                }
            },
            "animation": {
                "curve": {
                    "emphasized": [0.05, 0.7, 0.1, 1.0],
                    "standard": [0.3, 0.0, 0.8, 0.15],
                    "expressive": [0.4, 0.0, 0.2, 1.0]
                },
                "duration": {
                    "scale": 1.0,
                    "small": 100,
                    "normal": 200,
                    "large": 400,
                    "extraLarge": 600
                }
            },
            "transparency": {
                "enabled": False,
                "base": 0.85,
                "layers": 0.4
            }
        }
    
    def get_bar_defaults(self) -> Dict[str, Any]:
        """Get bar configuration defaults"""
        return {
            "enabled": True,
            "position": "top",
            "height": 30,
            "persistent": True,
            "showOnHover": True,
            "dragThreshold": 30,
            "workspaces": {
                "shown": 5,
                "rounded": True,
                "activeIndicator": True,
                "showLabels": False
            },
            "status": {
                "showAudio": False,
                "showKeyboard": False,
                "showNetwork": True,
                "showBluetooth": True,
                "showBattery": True
            },
            "sizes": {
                "innerHeight": 30,
                "previewHeight": 200,
                "menuWidth": 400
            }
        }
    
    def migrate_from_json(self, input_path: str, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate from an existing JSON configuration"""
        print(f"Migrating from existing JSON: {input_path}")
        
        try:
            with open(input_path, 'r') as f:
                old_config = json.load(f)
            
            # Merge configurations
            config = self.merge_configs(config, old_config)
            
            # Update version
            config["version"] = self.version
            config["metadata"]["lastModified"] = datetime.now().isoformat() + "Z"
            config["metadata"]["migratedFrom"] = "json"
            
        except Exception as e:
            print(f"Error reading input file: {e}")
            return config
        
        return config
    
    def merge_configs(self, base: Dict[str, Any], overlay: Dict[str, Any]) -> Dict[str, Any]:
        """Merge two configurations"""
        for key, value in overlay.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                base[key] = self.merge_configs(base[key], value)
            else:
                base[key] = value
        return base
    
    def save_config(self, config: Dict[str, Any]) -> bool:
        """Save configuration to file"""
        try:
            # Create backup if file exists
            if self.output_file.exists():
                backup_path = self.output_file.with_suffix(f".json.backup.{datetime.now().strftime('%Y%m%d-%H%M%S')}")
                self.output_file.rename(backup_path)
                print(f"Backed up existing configuration to: {backup_path}")
            
            # Save new configuration
            with open(self.output_file, 'w') as f:
                json.dump(config, f, indent=2)
            
            print(f"✅ Configuration saved to: {self.output_file}")
            return True
            
        except Exception as e:
            print(f"❌ Error saving configuration: {e}")
            return False

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Migrate Quickshell Heimdall configuration")
    parser.add_argument("--input", "-i", help="Input configuration file (JSON)")
    parser.add_argument("--output", "-o", help="Output configuration file")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be migrated without saving")
    
    args = parser.parse_args()
    
    migrator = ConfigMigrator()
    
    if args.dry_run:
        print("DRY RUN - No files will be modified")
        config = migrator.create_base_config()
        if args.input:
            config = migrator.migrate_from_json(args.input, config)
        else:
            config = migrator.migrate_from_qml(config)
        
        print("\nGenerated configuration:")
        print(json.dumps(config, indent=2))
    else:
        success = migrator.migrate(args.input, args.output)
        sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()