#!/usr/bin/env python3
"""
Configuration Documentation Generator for Heimdall
Generates comprehensive documentation from configuration schema
"""

import json
import os
import re
from pathlib import Path
from typing import Dict, Any, List, Optional

class ConfigDocumentationGenerator:
    """Generates documentation from configuration schema"""
    
    def __init__(self, schema_path: str):
        self.schema_path = Path(schema_path)
        with open(self.schema_path, 'r') as f:
            self.schema = json.load(f)
        
        self.documentation = []
        self.toc = []
    
    def generate_markdown(self) -> str:
        """Generate complete markdown documentation"""
        doc = []
        
        # Header
        doc.append("# Heimdall Configuration Reference\n")
        doc.append("This document provides a complete reference for all configuration options available in Heimdall quickshell.\n")
        doc.append(f"**Schema Version**: {self.schema.get('version', '2.0.0')}\n")
        
        # Table of Contents
        doc.append("\n## Table of Contents\n")
        self._generate_toc()
        doc.extend(self.toc)
        
        # Overview
        doc.append("\n## Overview\n")
        doc.append("The Heimdall configuration system uses a JSON format with the following structure:\n")
        doc.append("```json\n{\n  \"version\": \"2.0.0\",\n  \"modules\": {\n    // Module configurations\n  }\n}\n```\n")
        
        # Required Fields
        doc.append("\n## Required Fields\n")
        required = self.schema.get('required', [])
        if required:
            doc.append("The following fields are required in every configuration:\n")
            for field in required:
                doc.append(f"- **{field}**: {self._get_field_description(field)}\n")
        else:
            doc.append("No fields are strictly required, but `version` is recommended.\n")
        
        # Modules Documentation
        doc.append("\n## Modules\n")
        modules = self.schema.get('properties', {}).get('modules', {}).get('properties', {})
        
        for module_name, module_schema in modules.items():
            doc.append(f"\n### {self._format_module_name(module_name)}\n")
            doc.append(f"{module_schema.get('description', f'Configuration for {module_name} module')}\n")
            
            # Module properties
            if 'properties' in module_schema:
                doc.append("\n#### Properties\n")
                doc.extend(self._document_properties(module_schema['properties'], f"modules.{module_name}"))
            
            # Examples
            doc.append(f"\n#### Example\n")
            doc.append("```json\n")
            doc.append(self._generate_example(module_name, module_schema))
            doc.append("```\n")
        
        # Validation Rules
        doc.append("\n## Validation Rules\n")
        doc.extend(self._document_validation_rules())
        
        # Migration Guide
        doc.append("\n## Migration Guide\n")
        doc.extend(self._generate_migration_guide())
        
        # Best Practices
        doc.append("\n## Best Practices\n")
        doc.extend(self._generate_best_practices())
        
        return "\n".join(doc)
    
    def _generate_toc(self):
        """Generate table of contents"""
        self.toc.append("- [Overview](#overview)\n")
        self.toc.append("- [Required Fields](#required-fields)\n")
        self.toc.append("- [Modules](#modules)\n")
        
        modules = self.schema.get('properties', {}).get('modules', {}).get('properties', {})
        for module_name in modules.keys():
            formatted_name = self._format_module_name(module_name)
            anchor = formatted_name.lower().replace(" ", "-")
            self.toc.append(f"  - [{formatted_name}](#{anchor})\n")
        
        self.toc.append("- [Validation Rules](#validation-rules)\n")
        self.toc.append("- [Migration Guide](#migration-guide)\n")
        self.toc.append("- [Best Practices](#best-practices)\n")
    
    def _format_module_name(self, name: str) -> str:
        """Format module name for display"""
        # Convert camelCase to Title Case
        result = re.sub('([A-Z])', r' \1', name)
        return result.strip().title()
    
    def _get_field_description(self, field: str) -> str:
        """Get description for a field"""
        if field == "version":
            return "Configuration schema version (format: X.Y.Z)"
        
        field_schema = self.schema.get('properties', {}).get(field, {})
        return field_schema.get('description', f"The {field} field")
    
    def _document_properties(self, properties: Dict, path_prefix: str) -> List[str]:
        """Document properties recursively"""
        doc = []
        
        for prop_name, prop_schema in properties.items():
            full_path = f"{path_prefix}.{prop_name}"
            
            # Property header
            doc.append(f"\n##### `{prop_name}`\n")
            
            # Type
            prop_type = prop_schema.get('type', 'any')
            doc.append(f"- **Type**: `{prop_type}`\n")
            
            # Description
            if 'description' in prop_schema:
                doc.append(f"- **Description**: {prop_schema['description']}\n")
            
            # Default value
            if 'default' in prop_schema:
                default = prop_schema['default']
                if isinstance(default, str):
                    default = f'"{default}"'
                doc.append(f"- **Default**: `{default}`\n")
            
            # Constraints
            constraints = []
            if 'minimum' in prop_schema:
                constraints.append(f"min: {prop_schema['minimum']}")
            if 'maximum' in prop_schema:
                constraints.append(f"max: {prop_schema['maximum']}")
            if 'enum' in prop_schema:
                constraints.append(f"values: {', '.join(prop_schema['enum'])}")
            if 'pattern' in prop_schema:
                constraints.append(f"pattern: `{prop_schema['pattern']}`")
            
            if constraints:
                doc.append(f"- **Constraints**: {', '.join(constraints)}\n")
            
            # Nested properties
            if prop_schema.get('type') == 'object' and 'properties' in prop_schema:
                doc.append("\n**Nested Properties:**\n")
                doc.extend(self._document_properties(prop_schema['properties'], full_path))
        
        return doc
    
    def _generate_example(self, module_name: str, module_schema: Dict) -> str:
        """Generate example configuration for a module"""
        example = {}
        
        if 'properties' in module_schema:
            for prop_name, prop_schema in module_schema['properties'].items():
                # Use default if available
                if 'default' in prop_schema:
                    example[prop_name] = prop_schema['default']
                # Generate example based on type
                elif prop_schema.get('type') == 'boolean':
                    example[prop_name] = True
                elif prop_schema.get('type') == 'integer':
                    example[prop_name] = prop_schema.get('minimum', 0)
                elif prop_schema.get('type') == 'number':
                    example[prop_name] = prop_schema.get('minimum', 1.0)
                elif prop_schema.get('type') == 'string':
                    if 'enum' in prop_schema:
                        example[prop_name] = prop_schema['enum'][0]
                    else:
                        example[prop_name] = "example"
                elif prop_schema.get('type') == 'object':
                    example[prop_name] = {}
        
        config = {
            "modules": {
                module_name: example
            }
        }
        
        return json.dumps(config, indent=2)
    
    def _document_validation_rules(self) -> List[str]:
        """Document validation rules"""
        doc = []
        
        doc.append("The configuration system enforces the following validation rules:\n")
        
        doc.append("\n### Type Validation\n")
        doc.append("All properties are validated against their expected types:\n")
        doc.append("- `string`: Text values\n")
        doc.append("- `integer`: Whole numbers\n")
        doc.append("- `number`: Decimal numbers\n")
        doc.append("- `boolean`: true/false values\n")
        doc.append("- `object`: Nested configuration objects\n")
        doc.append("- `array`: Lists of values\n")
        
        doc.append("\n### Range Validation\n")
        doc.append("Numeric properties may have minimum and maximum constraints:\n")
        doc.append("- Duration values: 0-10000ms\n")
        doc.append("- Opacity values: 0.0-1.0\n")
        doc.append("- Size values: Must be positive\n")
        
        doc.append("\n### Cross-field Validation\n")
        doc.append("Some fields have dependencies on others:\n")
        doc.append("- Animation settings are ignored when `animation.enabled` is false\n")
        doc.append("- Service API keys are required when the service is enabled\n")
        doc.append("- Conflicting keyboard modes (vim/emacs) cannot be enabled simultaneously\n")
        
        return doc
    
    def _generate_migration_guide(self) -> List[str]:
        """Generate migration guide"""
        doc = []
        
        doc.append("### From Version 1.x to 2.0\n")
        doc.append("The configuration structure has changed significantly in version 2.0:\n")
        doc.append("\n**Key Changes:**\n")
        doc.append("1. All module configurations are now under the `modules` key\n")
        doc.append("2. `colours` has been renamed to `colors`\n")
        doc.append("3. New configuration modules added for animations, services, and behavior\n")
        doc.append("\n**Migration Example:**\n")
        doc.append("```json\n")
        doc.append("// Version 1.x\n")
        doc.append("{\n  \"launcher\": { ... },\n  \"colours\": { ... }\n}\n")
        doc.append("\n// Version 2.0\n")
        doc.append("{\n  \"version\": \"2.0.0\",\n  \"modules\": {\n    \"launcher\": { ... }\n  },\n  \"colors\": { ... }\n}\n")
        doc.append("```\n")
        
        doc.append("\n**Automatic Migration:**\n")
        doc.append("The configuration system will automatically migrate old configurations when detected.\n")
        doc.append("A backup is created before migration.\n")
        
        return doc
    
    def _generate_best_practices(self) -> List[str]:
        """Generate best practices section"""
        doc = []
        
        doc.append("### General Guidelines\n")
        doc.append("1. **Always specify version**: Include the `version` field for compatibility\n")
        doc.append("2. **Start with defaults**: Only override settings you need to change\n")
        doc.append("3. **Test incrementally**: Make small changes and test before adding more\n")
        doc.append("4. **Use comments**: JSON doesn't support comments, but you can document in a separate file\n")
        
        doc.append("\n### Performance Optimization\n")
        doc.append("- Disable unused services to reduce resource usage\n")
        doc.append("- Increase update intervals for non-critical services\n")
        doc.append("- Use `performance.reducedEffects` on lower-end hardware\n")
        doc.append("- Enable `performance.lazyLoading` for better startup times\n")
        
        doc.append("\n### Common Configurations\n")
        doc.append("\n**Minimal Configuration:**\n")
        doc.append("```json\n{\n  \"version\": \"2.0.0\"\n}\n```\n")
        
        doc.append("\n**Performance-Optimized:**\n")
        doc.append("```json\n")
        doc.append("{\n  \"version\": \"2.0.0\",\n  \"modules\": {\n")
        doc.append("    \"animation\": {\n      \"speedMultiplier\": 0.5\n    },\n")
        doc.append("    \"behavior\": {\n      \"performance\": {\n")
        doc.append("        \"reducedEffects\": true,\n        \"lazyLoading\": true\n")
        doc.append("      }\n    }\n  }\n}\n")
        doc.append("```\n")
        
        doc.append("\n**Accessibility-Focused:**\n")
        doc.append("```json\n")
        doc.append("{\n  \"version\": \"2.0.0\",\n  \"modules\": {\n")
        doc.append("    \"behavior\": {\n      \"accessibility\": {\n")
        doc.append("        \"enabled\": true,\n        \"largeText\": true,\n")
        doc.append("        \"textScale\": 1.5,\n        \"reducedMotion\": true\n")
        doc.append("      }\n    }\n  }\n}\n")
        doc.append("```\n")
        
        return doc
    
    def generate_interactive_html(self) -> str:
        """Generate interactive HTML documentation"""
        html = """<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Heimdall Configuration Reference</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        h2 { color: #34495e; margin-top: 30px; }
        h3 { color: #7f8c8d; }
        code {
            background: #f4f4f4;
            padding: 2px 6px;
            border-radius: 3px;
            font-family: 'Courier New', monospace;
        }
        pre {
            background: #2c3e50;
            color: #ecf0f1;
            padding: 15px;
            border-radius: 5px;
            overflow-x: auto;
        }
        .property {
            background: #ecf0f1;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            border-left: 4px solid #3498db;
        }
        .property-name {
            font-weight: bold;
            color: #2c3e50;
            font-size: 1.1em;
        }
        .property-type {
            color: #e74c3c;
            font-family: monospace;
        }
        .property-default {
            color: #27ae60;
        }
        .toc {
            background: #f8f9fa;
            padding: 20px;
            border-radius: 5px;
            margin-bottom: 30px;
        }
        .toc ul {
            list-style-type: none;
            padding-left: 20px;
        }
        .toc a {
            color: #3498db;
            text-decoration: none;
        }
        .toc a:hover {
            text-decoration: underline;
        }
        .search-box {
            width: 100%;
            padding: 10px;
            font-size: 16px;
            border: 2px solid #3498db;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .example {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 5px;
            padding: 15px;
            margin: 15px 0;
        }
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 0.85em;
            font-weight: bold;
            margin-left: 5px;
        }
        .badge-required { background: #e74c3c; color: white; }
        .badge-optional { background: #95a5a6; color: white; }
        .badge-deprecated { background: #f39c12; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Heimdall Configuration Reference</h1>
        <input type="text" class="search-box" placeholder="Search configuration options..." id="searchBox">
        <div id="content">
            <!-- Content will be inserted here -->
        </div>
    </div>
    <script>
        // Search functionality
        document.getElementById('searchBox').addEventListener('input', function(e) {
            const searchTerm = e.target.value.toLowerCase();
            const properties = document.querySelectorAll('.property');
            
            properties.forEach(prop => {
                const text = prop.textContent.toLowerCase();
                if (text.includes(searchTerm)) {
                    prop.style.display = 'block';
                } else {
                    prop.style.display = 'none';
                }
            });
        });
    </script>
</body>
</html>"""
        return html

def main():
    """Main entry point"""
    import sys
    
    # Find schema file
    if len(sys.argv) > 1:
        schema_path = Path(sys.argv[1])
    else:
        schema_path = Path(__file__).parent.parent / "docs" / "configuration-schema.json"
    
    if not schema_path.exists():
        print(f"Error: Schema file {schema_path} not found")
        print("Please run generate-schema.py first")
        sys.exit(1)
    
    generator = ConfigDocumentationGenerator(str(schema_path))
    
    print("Generating configuration documentation...")
    
    # Generate markdown documentation
    markdown = generator.generate_markdown()
    md_path = schema_path.parent / "configuration-reference.md"
    with open(md_path, 'w') as f:
        f.write(markdown)
    print(f"Markdown documentation saved to {md_path}")
    
    # Generate HTML documentation
    html = generator.generate_interactive_html()
    html_path = schema_path.parent / "configuration-reference.html"
    with open(html_path, 'w') as f:
        f.write(html)
    print(f"HTML documentation saved to {html_path}")
    
    print("\nDocumentation generation complete!")

if __name__ == "__main__":
    main()