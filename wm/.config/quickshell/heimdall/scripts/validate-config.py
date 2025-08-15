#!/usr/bin/env python3
"""
Configuration validator for Quickshell Heimdall JSON configuration
Validates shell.json against the defined schema
"""

import json
import sys
import os
from pathlib import Path
from typing import Dict, Any, List, Tuple

class ConfigValidator:
    def __init__(self):
        self.errors: List[str] = []
        self.warnings: List[str] = []
        
    def validate_file(self, filepath: str) -> bool:
        """Validate a JSON configuration file"""
        try:
            with open(filepath, 'r') as f:
                config = json.load(f)
        except FileNotFoundError:
            self.errors.append(f"Configuration file not found: {filepath}")
            return False
        except json.JSONDecodeError as e:
            self.errors.append(f"Invalid JSON: {e}")
            return False
        
        return self.validate_config(config)
    
    def validate_config(self, config: Dict[str, Any]) -> bool:
        """Validate configuration structure and values"""
        
        # Required fields
        if 'version' not in config:
            self.errors.append("Missing required field: 'version'")
            return False
        
        # Validate version format
        import re
        if not re.match(r'^\d+\.\d+\.\d+$', config['version']):
            self.errors.append(f"Invalid version format: {config['version']}")
            return False
        
        # Validate sections
        self._validate_system(config.get('system', {}))
        self._validate_appearance(config.get('appearance', {}))
        self._validate_bar(config.get('bar', {}))
        self._validate_modules(config.get('modules', {}))
        self._validate_services(config.get('services', {}))
        self._validate_commands(config.get('commands', {}))
        self._validate_wallpaper(config.get('wallpaper', {}))
        self._validate_hot_reload(config.get('hotReload', {}))
        
        return len(self.errors) == 0
    
    def _validate_system(self, system: Dict[str, Any]):
        """Validate system configuration"""
        if 'paths' in system:
            paths = system['paths']
            for key, path in paths.items():
                if not isinstance(path, str):
                    self.errors.append(f"system.paths.{key} must be a string")
                elif not path:
                    self.warnings.append(f"system.paths.{key} is empty")
        
        if 'startup' in system:
            startup = system['startup']
            if 'sequence' in startup:
                for i, item in enumerate(startup['sequence']):
                    if 'name' not in item:
                        self.errors.append(f"system.startup.sequence[{i}] missing 'name'")
                    if 'delay' not in item:
                        self.errors.append(f"system.startup.sequence[{i}] missing 'delay'")
                    elif not isinstance(item['delay'], (int, float)) or item['delay'] < 0:
                        self.errors.append(f"system.startup.sequence[{i}].delay must be non-negative number")
    
    def _validate_appearance(self, appearance: Dict[str, Any]):
        """Validate appearance configuration"""
        if 'rounding' in appearance:
            self._validate_numeric_dict(appearance['rounding'], 'appearance.rounding')
        if 'spacing' in appearance:
            self._validate_numeric_dict(appearance['spacing'], 'appearance.spacing')
        if 'padding' in appearance:
            self._validate_numeric_dict(appearance['padding'], 'appearance.padding')
        
        if 'font' in appearance:
            font = appearance['font']
            if 'size' in font:
                self._validate_numeric_dict(font['size'], 'appearance.font.size', min_val=1)
    
    def _validate_bar(self, bar: Dict[str, Any]):
        """Validate bar configuration"""
        if 'height' in bar:
            if not isinstance(bar['height'], (int, float)) or bar['height'] <= 0:
                self.errors.append("bar.height must be a positive number")
        
        if 'position' in bar:
            if bar['position'] not in ['top', 'bottom']:
                self.errors.append(f"bar.position must be 'top' or 'bottom', got '{bar['position']}'")
    
    def _validate_modules(self, modules: Dict[str, Any]):
        """Validate modules configuration"""
        for module_name, module_config in modules.items():
            if not isinstance(module_config, dict):
                self.errors.append(f"modules.{module_name} must be an object")
                continue
            
            if 'enabled' in module_config:
                if not isinstance(module_config['enabled'], bool):
                    self.errors.append(f"modules.{module_name}.enabled must be boolean")
    
    def _validate_services(self, services: Dict[str, Any]):
        """Validate services configuration"""
        if 'audio' in services:
            audio = services['audio']
            if 'increment' in audio:
                if not isinstance(audio['increment'], (int, float)) or audio['increment'] <= 0:
                    self.errors.append("services.audio.increment must be positive number")
    
    def _validate_commands(self, commands: Dict[str, Any]):
        """Validate commands configuration"""
        for cmd_name, cmd_value in commands.items():
            if not isinstance(cmd_value, (str, list)):
                self.errors.append(f"commands.{cmd_name} must be string or array")
            elif isinstance(cmd_value, list):
                for i, part in enumerate(cmd_value):
                    if not isinstance(part, str):
                        self.errors.append(f"commands.{cmd_name}[{i}] must be string")
    
    def _validate_wallpaper(self, wallpaper: Dict[str, Any]):
        """Validate wallpaper configuration"""
        if 'current' in wallpaper:
            path = os.path.expanduser(wallpaper['current'])
            if not os.path.exists(path):
                self.warnings.append(f"Wallpaper file not found: {wallpaper['current']}")
        
        if 'mode' in wallpaper:
            valid_modes = ['fill', 'fit', 'stretch', 'center', 'tile']
            if wallpaper['mode'] not in valid_modes:
                self.errors.append(f"wallpaper.mode must be one of {valid_modes}")
    
    def _validate_hot_reload(self, hot_reload: Dict[str, Any]):
        """Validate hot-reload configuration"""
        if 'debounceMs' in hot_reload:
            if not isinstance(hot_reload['debounceMs'], (int, float)) or hot_reload['debounceMs'] < 0:
                self.errors.append("hotReload.debounceMs must be non-negative number")
        
        if 'enabled' in hot_reload:
            if not isinstance(hot_reload['enabled'], bool):
                self.errors.append("hotReload.enabled must be boolean")
    
    def _validate_numeric_dict(self, d: Dict[str, Any], path: str, min_val: float = 0):
        """Validate a dictionary containing numeric values"""
        for key, value in d.items():
            if not isinstance(value, (int, float)):
                self.errors.append(f"{path}.{key} must be a number")
            elif value < min_val:
                self.errors.append(f"{path}.{key} must be >= {min_val}")
    
    def print_results(self):
        """Print validation results"""
        if self.errors:
            print("❌ Validation FAILED\n")
            print("Errors:")
            for error in self.errors:
                print(f"  • {error}")
        else:
            print("✅ Validation PASSED")
        
        if self.warnings:
            print("\nWarnings:")
            for warning in self.warnings:
                print(f"  ⚠ {warning}")
        
        print(f"\nSummary: {len(self.errors)} errors, {len(self.warnings)} warnings")

def main():
    if len(sys.argv) < 2:
        config_path = os.path.expanduser("~/.config/quickshell/heimdall/shell.json")
    else:
        config_path = sys.argv[1]
    
    print(f"Validating configuration: {config_path}\n")
    
    validator = ConfigValidator()
    valid = validator.validate_file(config_path)
    validator.print_results()
    
    sys.exit(0 if valid else 1)

if __name__ == "__main__":
    main()