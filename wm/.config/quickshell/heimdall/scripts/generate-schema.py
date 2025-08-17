#!/usr/bin/env python3
"""
Schema Generation System for Heimdall Configuration
Generates JSON Schema from QML configuration files
"""

import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, Any, List, Optional

class QMLSchemaGenerator:
    """Generates JSON Schema from QML configuration files"""
    
    def __init__(self, config_dir: str):
        self.config_dir = Path(config_dir)
        self.schema = {
            "$schema": "http://json-schema.org/draft-07/schema#",
            "title": "Heimdall Configuration Schema",
            "description": "Configuration schema for Heimdall quickshell",
            "type": "object",
            "properties": {
                "version": {
                    "type": "string",
                    "pattern": "^\\d+\\.\\d+\\.\\d+$",
                    "description": "Configuration version"
                },
                "meta": {
                    "type": "object",
                    "properties": {
                        "profile": {"type": "string"},
                        "created": {"type": "string", "format": "date-time"},
                        "modified": {"type": "string", "format": "date-time"}
                    }
                }
            },
            "required": ["version"],
            "definitions": {}
        }
    
    def parse_qml_file(self, filepath: Path) -> Dict[str, Any]:
        """Parse a QML file and extract configuration properties"""
        properties = {}
        
        with open(filepath, 'r') as f:
            content = f.read()
        
        # Extract QtObject blocks
        qt_object_pattern = r'property\s+QtObject\s+(\w+):?\s*QtObject\s*\{([^}]*)\}'
        qt_objects = re.findall(qt_object_pattern, content, re.DOTALL)
        
        for obj_name, obj_content in qt_objects:
            properties[obj_name] = self.parse_qt_object(obj_content)
        
        # Extract simple properties
        prop_pattern = r'property\s+(\w+)\s+(\w+):\s*([^\/\n]+)'
        simple_props = re.findall(prop_pattern, content)
        
        for prop_type, prop_name, default_value in simple_props:
            if prop_name not in properties:
                properties[prop_name] = self.qml_type_to_json_schema(prop_type, default_value.strip())
        
        return properties
    
    def parse_qt_object(self, content: str) -> Dict[str, Any]:
        """Parse QtObject content and extract properties"""
        schema = {
            "type": "object",
            "properties": {}
        }
        
        # Parse nested QtObjects
        qt_object_pattern = r'property\s+QtObject\s+(\w+):?\s*QtObject\s*\{([^}]*)\}'
        qt_objects = re.findall(qt_object_pattern, content, re.DOTALL)
        
        for obj_name, obj_content in qt_objects:
            schema["properties"][obj_name] = self.parse_qt_object(obj_content)
        
        # Parse simple properties
        prop_pattern = r'property\s+(\w+)\s+(\w+):\s*([^\/\n]+?)(?:\s*\/\/(.*))?$'
        for match in re.finditer(prop_pattern, content, re.MULTILINE):
            prop_type, prop_name, default_value, comment = match.groups()
            
            if prop_name not in schema["properties"]:
                prop_schema = self.qml_type_to_json_schema(prop_type, default_value.strip())
                if comment:
                    prop_schema["description"] = comment.strip()
                schema["properties"][prop_name] = prop_schema
        
        return schema
    
    def qml_type_to_json_schema(self, qml_type: str, default_value: str = "") -> Dict[str, Any]:
        """Convert QML type to JSON Schema type"""
        schema = {}
        
        # Clean default value
        default_value = default_value.strip().rstrip(';').strip()
        if default_value.startswith('"') and default_value.endswith('"'):
            default_value = default_value[1:-1]
        
        # Map QML types to JSON Schema types
        type_mapping = {
            'string': 'string',
            'int': 'integer',
            'real': 'number',
            'double': 'number',
            'bool': 'boolean',
            'var': 'object',
            'list': 'array',
            'color': 'string'
        }
        
        json_type = type_mapping.get(qml_type, 'string')
        schema['type'] = json_type
        
        # Add format for specific types
        if qml_type == 'color':
            schema['format'] = 'color'
            schema['pattern'] = '^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$'
        
        # Parse default value
        if default_value and default_value != '{}' and default_value != '[]':
            try:
                if json_type == 'integer':
                    schema['default'] = int(default_value)
                elif json_type == 'number':
                    schema['default'] = float(default_value)
                elif json_type == 'boolean':
                    schema['default'] = default_value.lower() in ['true', '1']
                elif json_type == 'array':
                    if default_value.startswith('['):
                        schema['default'] = json.loads(default_value)
                else:
                    schema['default'] = default_value
            except:
                pass  # Ignore parsing errors for complex defaults
        
        # Add constraints based on property name
        if 'duration' in qml_type.lower() or 'delay' in qml_type.lower():
            schema['minimum'] = 0
            schema['maximum'] = 10000
        elif 'opacity' in qml_type.lower():
            schema['minimum'] = 0
            schema['maximum'] = 1
        elif 'size' in qml_type.lower() and json_type in ['integer', 'number']:
            schema['minimum'] = 0
        
        return schema
    
    def generate_module_schema(self, module_name: str, filepath: Path) -> Dict[str, Any]:
        """Generate schema for a specific module"""
        properties = self.parse_qml_file(filepath)
        
        return {
            "type": "object",
            "description": f"Configuration for {module_name} module",
            "properties": properties
        }
    
    def scan_config_directory(self):
        """Scan configuration directory and generate complete schema"""
        modules_schema = {
            "type": "object",
            "properties": {}
        }
        
        # List of configuration files to process
        config_files = {
            "appearance": "AppearanceConfig.qml",
            "general": "GeneralConfig.qml",
            "background": "BackgroundConfig.qml",
            "bar": "BarConfig.qml",
            "border": "BorderConfig.qml",
            "dashboard": "DashboardConfig.qml",
            "controlCenter": "ControlCenterConfig.qml",
            "launcher": "LauncherConfig.qml",
            "notifications": "NotifsConfig.qml",
            "osd": "OsdConfig.qml",
            "session": "SessionConfig.qml",
            "lock": "LockConfig.qml",
            "uiComponents": "UIComponentsConfig.qml",
            "animation": "AnimationConfig.qml",
            "servicesIntegration": "ServicesIntegrationConfig.qml",
            "behavior": "BehaviorConfig.qml"
        }
        
        for module_name, filename in config_files.items():
            filepath = self.config_dir / filename
            if filepath.exists():
                print(f"Processing {filename}...")
                modules_schema["properties"][module_name] = self.generate_module_schema(
                    module_name, filepath
                )
            else:
                print(f"Warning: {filename} not found")
        
        self.schema["properties"]["modules"] = modules_schema
    
    def add_validation_rules(self):
        """Add advanced validation rules to schema"""
        # Add conditional requirements
        self.schema["allOf"] = [
            {
                "if": {
                    "properties": {
                        "modules": {
                            "properties": {
                                "animation": {
                                    "properties": {
                                        "enabled": {"const": False}
                                    }
                                }
                            }
                        }
                    }
                },
                "then": {
                    "properties": {
                        "modules": {
                            "properties": {
                                "animation": {
                                    "properties": {
                                        "durations": {
                                            "description": "Animation durations are ignored when animations are disabled"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        ]
        
        # Add cross-field validation
        self.schema["dependencies"] = {
            "modules": {
                "properties": {
                    "servicesIntegration": {
                        "dependencies": {
                            "weather": {
                                "properties": {
                                    "weather": {
                                        "dependencies": {
                                            "enabled": {
                                                "properties": {
                                                    "apiKey": {
                                                        "minLength": 1
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    
    def generate_typescript_definitions(self) -> str:
        """Generate TypeScript definitions from schema"""
        ts_def = "// Auto-generated TypeScript definitions for Heimdall configuration\n\n"
        ts_def += "export interface HeimdallConfig {\n"
        ts_def += "  version: string;\n"
        ts_def += "  meta?: {\n"
        ts_def += "    profile?: string;\n"
        ts_def += "    created?: string;\n"
        ts_def += "    modified?: string;\n"
        ts_def += "  };\n"
        ts_def += "  modules?: {\n"
        
        # Add module interfaces
        for module_name in self.schema["properties"].get("modules", {}).get("properties", {}).keys():
            ts_def += f"    {module_name}?: {module_name.capitalize()}Config;\n"
        
        ts_def += "  };\n"
        ts_def += "}\n"
        
        return ts_def
    
    def save_schema(self, output_path: str):
        """Save generated schema to file"""
        with open(output_path, 'w') as f:
            json.dump(self.schema, f, indent=2)
        print(f"Schema saved to {output_path}")
    
    def save_typescript(self, output_path: str):
        """Save TypeScript definitions to file"""
        ts_def = self.generate_typescript_definitions()
        with open(output_path, 'w') as f:
            f.write(ts_def)
        print(f"TypeScript definitions saved to {output_path}")

def main():
    """Main entry point"""
    if len(sys.argv) < 2:
        config_dir = Path(__file__).parent.parent / "config"
    else:
        config_dir = Path(sys.argv[1])
    
    if not config_dir.exists():
        print(f"Error: Configuration directory {config_dir} does not exist")
        sys.exit(1)
    
    generator = QMLSchemaGenerator(str(config_dir))
    
    print("Generating JSON Schema from QML configuration files...")
    generator.scan_config_directory()
    generator.add_validation_rules()
    
    # Save outputs
    output_dir = config_dir.parent / "docs"
    output_dir.mkdir(exist_ok=True)
    
    schema_path = output_dir / "configuration-schema.json"
    generator.save_schema(str(schema_path))
    
    ts_path = output_dir / "configuration.d.ts"
    generator.save_typescript(str(ts_path))
    
    print("\nSchema generation complete!")
    print(f"Files generated:")
    print(f"  - {schema_path}")
    print(f"  - {ts_path}")

if __name__ == "__main__":
    main()