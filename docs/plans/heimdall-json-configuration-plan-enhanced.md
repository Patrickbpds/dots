# Heimdall JSON Configuration System Implementation Plan (Enhanced)

## Executive Summary

This enhanced plan extends the original implementation to include critical infrastructure for automatic shell initialization, version management, default configuration systems, and complete path flexibility. These additions ensure zero-configuration startup, seamless upgrades, and full user control over all system paths.

### Additional Key Deliverables
- Automatic shell initialization hooks for bash/zsh/fish
- Version-aware migration system with property injection
- Default configuration framework with automatic instantiation
- Complete path flexibility with XDG compliance
- Environment variable override system
- Multi-profile configuration support

### Enhanced Success Metrics
- Zero manual configuration required for new installations
- 100% backward compatibility across version upgrades
- Automatic recovery from missing/corrupted configurations
- Full XDG Base Directory specification compliance
- Sub-second shell initialization overhead

## Critical Requirements Implementation

### 1. Automatic Shell Initialization System

#### 1.1 Shell Hook Architecture

The system will automatically initialize configuration on every shell startup, ensuring the configuration exists and is valid before any Quickshell components launch.

##### Core Initialization Script
```bash
#!/bin/bash
# ~/.config/quickshell/heimdall/init/shell-init.sh

# XDG Base Directory compliance
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Heimdall configuration paths
export HEIMDALL_CONFIG_DIR="${HEIMDALL_CONFIG_DIR:-$XDG_CONFIG_HOME/quickshell/heimdall}"
export HEIMDALL_DEFAULTS_DIR="${HEIMDALL_DEFAULTS_DIR:-$HEIMDALL_CONFIG_DIR/defaults}"
export HEIMDALL_STATE_DIR="${HEIMDALL_STATE_DIR:-$XDG_STATE_HOME/quickshell/user/generated}"
export HEIMDALL_CACHE_DIR="${HEIMDALL_CACHE_DIR:-$XDG_CACHE_HOME/quickshell}"

# Profile support
export HEIMDALL_PROFILE="${HEIMDALL_PROFILE:-default}"
export HEIMDALL_CONFIG_FILE="${HEIMDALL_CONFIG_DIR}/profiles/${HEIMDALL_PROFILE}/shell.json"

# Version management
export HEIMDALL_VERSION_FILE="${HEIMDALL_STATE_DIR}/.version"
export HEIMDALL_CURRENT_VERSION="1.0.0"

# Initialize configuration system
heimdall_init() {
    local init_script="${HEIMDALL_CONFIG_DIR}/init/config-manager.sh"
    
    if [[ -f "$init_script" ]]; then
        source "$init_script"
        heimdall_verify_config
        heimdall_check_version
        heimdall_ensure_paths
    else
        echo "Warning: Heimdall initialization script not found" >&2
    fi
}

# Run initialization if not already done
if [[ -z "$HEIMDALL_INITIALIZED" ]]; then
    heimdall_init
    export HEIMDALL_INITIALIZED=1
fi
```

##### Configuration Manager
```bash
#!/bin/bash
# ~/.config/quickshell/heimdall/init/config-manager.sh

heimdall_verify_config() {
    local config_file="$HEIMDALL_CONFIG_FILE"
    local defaults_file="${HEIMDALL_DEFAULTS_DIR}/shell.json"
    
    # Create profile directory if needed
    mkdir -p "$(dirname "$config_file")"
    
    # If config doesn't exist, create from defaults
    if [[ ! -f "$config_file" ]]; then
        echo "Creating configuration from defaults..."
        
        if [[ -f "$defaults_file" ]]; then
            # Copy defaults and personalize
            cp "$defaults_file" "$config_file"
            
            # Inject user-specific values
            heimdall_personalize_config "$config_file"
        else
            # Generate minimal config if no defaults
            heimdall_generate_minimal_config > "$config_file"
        fi
    fi
    
    # Validate configuration
    if ! heimdall_validate_json "$config_file"; then
        echo "Configuration validation failed, restoring from backup..."
        heimdall_restore_config
    fi
}

heimdall_check_version() {
    local config_file="$HEIMDALL_CONFIG_FILE"
    local current_version="$HEIMDALL_CURRENT_VERSION"
    
    # Get config version
    local config_version=$(jq -r '.version // "0.0.0"' "$config_file" 2>/dev/null)
    
    # Compare versions and migrate if needed
    if [[ "$config_version" != "$current_version" ]]; then
        echo "Migrating configuration from v${config_version} to v${current_version}..."
        heimdall_migrate_config "$config_version" "$current_version"
    fi
    
    # Update version file
    echo "$current_version" > "$HEIMDALL_VERSION_FILE"
}

heimdall_ensure_paths() {
    # Create all required directories
    local paths=(
        "$HEIMDALL_CONFIG_DIR"
        "$HEIMDALL_DEFAULTS_DIR"
        "$HEIMDALL_STATE_DIR"
        "$HEIMDALL_CACHE_DIR"
        "${HEIMDALL_STATE_DIR}/wallpaper"
        "${HEIMDALL_STATE_DIR}/colors"
        "${HEIMDALL_STATE_DIR}/config"
        "${HEIMDALL_CONFIG_DIR}/profiles"
        "${HEIMDALL_CONFIG_DIR}/backups"
    )
    
    for path in "${paths[@]}"; do
        mkdir -p "$path"
    done
}

heimdall_personalize_config() {
    local config_file="$1"
    
    # Update user-specific paths
    jq --arg home "$HOME" \
       --arg user "$USER" \
       --arg config_dir "$XDG_CONFIG_HOME" \
       --arg data_dir "$XDG_DATA_HOME" \
       --arg state_dir "$XDG_STATE_HOME" \
       --arg cache_dir "$XDG_CACHE_HOME" \
       '.system.paths.home = $home |
        .system.paths.config = $config_dir |
        .system.paths.data = $data_dir |
        .system.paths.state = $state_dir |
        .system.paths.cache = $cache_dir |
        .system.user = $user |
        .metadata.created = now | todate |
        .metadata.hostname = env.HOSTNAME' \
       "$config_file" > "${config_file}.tmp" && \
    mv "${config_file}.tmp" "$config_file"
}

heimdall_validate_json() {
    local file="$1"
    jq empty "$file" 2>/dev/null
}

heimdall_generate_minimal_config() {
    cat <<EOF
{
  "version": "$HEIMDALL_CURRENT_VERSION",
  "metadata": {
    "created": "$(date -Iseconds)",
    "profile": "$HEIMDALL_PROFILE"
  },
  "system": {
    "paths": {
      "home": "$HOME",
      "config": "$XDG_CONFIG_HOME",
      "data": "$XDG_DATA_HOME",
      "state": "$XDG_STATE_HOME",
      "cache": "$XDG_CACHE_HOME"
    }
  }
}
EOF
}
```

#### 1.2 Shell Integration

##### Bash Integration
```bash
# ~/.bashrc addition
if [[ -f "$HOME/.config/quickshell/heimdall/init/shell-init.sh" ]]; then
    source "$HOME/.config/quickshell/heimdall/init/shell-init.sh"
fi
```

##### Zsh Integration
```zsh
# ~/.zshrc addition
if [[ -f "$HOME/.config/quickshell/heimdall/init/shell-init.sh" ]]; then
    source "$HOME/.config/quickshell/heimdall/init/shell-init.sh"
fi
```

##### Fish Integration
```fish
# ~/.config/fish/config.fish addition
if test -f "$HOME/.config/quickshell/heimdall/init/shell-init.fish"
    source "$HOME/.config/quickshell/heimdall/init/shell-init.fish"
end
```

```fish
# ~/.config/quickshell/heimdall/init/shell-init.fish
# XDG Base Directory compliance
set -gx XDG_CONFIG_HOME (test -n "$XDG_CONFIG_HOME"; and echo $XDG_CONFIG_HOME; or echo "$HOME/.config")
set -gx XDG_DATA_HOME (test -n "$XDG_DATA_HOME"; and echo $XDG_DATA_HOME; or echo "$HOME/.local/share")
set -gx XDG_STATE_HOME (test -n "$XDG_STATE_HOME"; and echo $XDG_STATE_HOME; or echo "$HOME/.local/state")
set -gx XDG_CACHE_HOME (test -n "$XDG_CACHE_HOME"; and echo $XDG_CACHE_HOME; or echo "$HOME/.cache")

# Heimdall configuration
set -gx HEIMDALL_CONFIG_DIR "$XDG_CONFIG_HOME/quickshell/heimdall"
set -gx HEIMDALL_PROFILE (test -n "$HEIMDALL_PROFILE"; and echo $HEIMDALL_PROFILE; or echo "default")

# Initialize
if not set -q HEIMDALL_INITIALIZED
    if test -f "$HEIMDALL_CONFIG_DIR/init/config-manager.fish"
        source "$HEIMDALL_CONFIG_DIR/init/config-manager.fish"
        heimdall_init
    end
    set -gx HEIMDALL_INITIALIZED 1
end
```

#### 1.3 Startup Hook System

```bash
#!/bin/bash
# ~/.config/quickshell/heimdall/init/pre-launch.sh

# Pre-launch hooks that run before quickshell starts
heimdall_pre_launch() {
    local hooks_dir="${HEIMDALL_CONFIG_DIR}/hooks/pre-launch"
    
    if [[ -d "$hooks_dir" ]]; then
        for hook in "$hooks_dir"/*.sh; do
            [[ -x "$hook" ]] && source "$hook"
        done
    fi
    
    # Ensure wallpaper daemon is ready
    heimdall_ensure_wallpaper_daemon
    
    # Restore previous state
    heimdall_restore_state
    
    # Validate runtime environment
    heimdall_validate_runtime
}

heimdall_ensure_wallpaper_daemon() {
    if ! pgrep -x "swww-daemon" > /dev/null; then
        swww-daemon --format xrgb &
        sleep 0.5
    fi
}

heimdall_restore_state() {
    local state_file="${HEIMDALL_STATE_DIR}/session.json"
    
    if [[ -f "$state_file" ]]; then
        # Restore wallpaper
        local wallpaper=$(jq -r '.wallpaper // ""' "$state_file")
        [[ -n "$wallpaper" && -f "$wallpaper" ]] && heimdall wallpaper -f "$wallpaper"
        
        # Restore other session state
        heimdall_restore_session_state "$state_file"
    fi
}
```

### 2. Version Management and Migration

#### 2.1 Version Detection and Migration Engine

```python
#!/usr/bin/env python3
# ~/.config/quickshell/heimdall/tools/version-manager.py

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, Optional
from datetime import datetime
import semver
import copy

class VersionManager:
    def __init__(self, config_path: str):
        self.config_path = Path(config_path)
        self.defaults_dir = self.config_path.parent / "defaults"
        self.migrations_dir = self.config_path.parent / "migrations"
        self.current_version = "1.0.0"
        
    def get_config_version(self, config: Dict[str, Any]) -> str:
        """Extract version from configuration"""
        return config.get("version", "0.0.0")
    
    def needs_migration(self, config: Dict[str, Any]) -> bool:
        """Check if configuration needs migration"""
        config_version = self.get_config_version(config)
        return semver.compare(config_version, self.current_version) < 0
    
    def migrate(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate configuration to current version"""
        config_version = self.get_config_version(config)
        
        # Create backup
        self.backup_config(config)
        
        # Apply migrations sequentially
        migrations = self.get_migration_chain(config_version, self.current_version)
        
        for migration in migrations:
            config = self.apply_migration(config, migration)
            
        # Update version
        config["version"] = self.current_version
        config["metadata"]["lastMigration"] = datetime.now().isoformat()
        
        return config
    
    def get_migration_chain(self, from_version: str, to_version: str) -> list:
        """Get list of migrations to apply"""
        migrations = []
        
        # Define migration map
        migration_map = {
            ("0.0.0", "0.1.0"): self.migrate_0_0_0_to_0_1_0,
            ("0.1.0", "0.2.0"): self.migrate_0_1_0_to_0_2_0,
            ("0.2.0", "1.0.0"): self.migrate_0_2_0_to_1_0_0,
        }
        
        current = from_version
        for (from_v, to_v), migration_func in migration_map.items():
            if semver.compare(current, from_v) >= 0 and \
               semver.compare(current, to_v) < 0 and \
               semver.compare(to_v, to_version) <= 0:
                migrations.append(migration_func)
                current = to_v
                
        return migrations
    
    def apply_migration(self, config: Dict[str, Any], migration_func) -> Dict[str, Any]:
        """Apply a single migration"""
        return migration_func(config)
    
    def inject_defaults(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Inject default values for missing properties"""
        defaults = self.load_defaults()
        return self.deep_merge(defaults, config)
    
    def deep_merge(self, base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
        """Deep merge two dictionaries"""
        result = copy.deepcopy(base)
        
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self.deep_merge(result[key], value)
            else:
                result[key] = value
                
        return result
    
    def load_defaults(self) -> Dict[str, Any]:
        """Load default configuration"""
        defaults_file = self.defaults_dir / f"v{self.current_version}.json"
        
        if defaults_file.exists():
            with open(defaults_file) as f:
                return json.load(f)
        
        return self.generate_defaults()
    
    def generate_defaults(self) -> Dict[str, Any]:
        """Generate default configuration"""
        return {
            "version": self.current_version,
            "metadata": {
                "created": datetime.now().isoformat(),
                "profile": "default"
            },
            "system": {
                "startup": {
                    "sequence": [
                        {"name": "display-init", "delay": 0},
                        {"name": "wallpaper-daemon", "delay": 500},
                        {"name": "quickshell", "delay": 1000}
                    ]
                },
                "paths": {
                    "home": os.environ.get("HOME"),
                    "config": os.environ.get("XDG_CONFIG_HOME", f"{os.environ['HOME']}/.config"),
                    "data": os.environ.get("XDG_DATA_HOME", f"{os.environ['HOME']}/.local/share"),
                    "state": os.environ.get("XDG_STATE_HOME", f"{os.environ['HOME']}/.local/state"),
                    "cache": os.environ.get("XDG_CACHE_HOME", f"{os.environ['HOME']}/.cache")
                }
            },
            "appearance": self.get_default_appearance(),
            "bar": self.get_default_bar(),
            "modules": self.get_default_modules(),
            "commands": self.get_default_commands()
        }
    
    def backup_config(self, config: Dict[str, Any]):
        """Create backup of configuration"""
        backup_dir = self.config_path.parent / "backups"
        backup_dir.mkdir(exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_file = backup_dir / f"shell_{timestamp}.json"
        
        with open(backup_file, 'w') as f:
            json.dump(config, f, indent=2)
    
    # Migration functions
    def migrate_0_0_0_to_0_1_0(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate from initial version to 0.1.0"""
        # Add system paths if missing
        if "system" not in config:
            config["system"] = {}
        
        if "paths" not in config["system"]:
            config["system"]["paths"] = self.generate_defaults()["system"]["paths"]
        
        return config
    
    def migrate_0_1_0_to_0_2_0(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate from 0.1.0 to 0.2.0"""
        # Add startup sequence
        if "startup" not in config.get("system", {}):
            config["system"]["startup"] = self.generate_defaults()["system"]["startup"]
        
        return config
    
    def migrate_0_2_0_to_1_0_0(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Migrate from 0.2.0 to 1.0.0"""
        # Add profile support
        if "metadata" not in config:
            config["metadata"] = {}
        
        if "profile" not in config["metadata"]:
            config["metadata"]["profile"] = "default"
        
        # Add environment variables
        if "environment" not in config.get("system", {}):
            config["system"]["environment"] = {}
        
        return config

def main():
    config_file = os.environ.get("HEIMDALL_CONFIG_FILE", 
                                 f"{os.environ['HOME']}/.config/quickshell/heimdall/shell.json")
    
    manager = VersionManager(config_file)
    
    # Load current configuration
    if Path(config_file).exists():
        with open(config_file) as f:
            config = json.load(f)
    else:
        config = {}
    
    # Check and migrate if needed
    if manager.needs_migration(config):
        print(f"Migrating configuration from v{manager.get_config_version(config)} to v{manager.current_version}")
        config = manager.migrate(config)
    
    # Inject defaults for missing properties
    config = manager.inject_defaults(config)
    
    # Save updated configuration
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"Configuration is up to date (v{manager.current_version})")

if __name__ == "__main__":
    main()
```

#### 2.2 Property Addition System

```javascript
// ~/.config/quickshell/heimdall/tools/property-injector.js

const fs = require('fs');
const path = require('path');

class PropertyInjector {
    constructor(configPath) {
        this.configPath = configPath;
        this.propertyDefinitions = this.loadPropertyDefinitions();
    }
    
    loadPropertyDefinitions() {
        // Define all properties with their default values and versions
        return {
            "1.0.0": {
                "system.startup.retryOnFailure": true,
                "system.startup.maxRetries": 3,
                "system.paths.wallpaperDir": "~/Pictures/Wallpapers",
                "appearance.transparency.blur": true,
                "appearance.transparency.blurStrength": 20,
                "modules.dashboard.widgets": ["clock", "weather", "system"],
                "services.notifications.sound": true,
                "services.notifications.soundFile": "/usr/share/sounds/freedesktop/stereo/message.oga"
            },
            "1.1.0": {
                "system.profiles.autoSwitch": false,
                "system.profiles.conditions": [],
                "appearance.themes.auto": true,
                "appearance.themes.lightThreshold": "06:00",
                "appearance.themes.darkThreshold": "18:00"
            }
        };
    }
    
    injectProperties(config, targetVersion) {
        const configVersion = config.version || "0.0.0";
        
        // Get all properties to inject
        const propertiesToInject = this.getPropertiesToInject(configVersion, targetVersion);
        
        // Inject each property
        for (const [path, value] of Object.entries(propertiesToInject)) {
            if (!this.hasProperty(config, path)) {
                this.setProperty(config, path, value);
                console.log(`Added property: ${path} = ${JSON.stringify(value)}`);
            }
        }
        
        return config;
    }
    
    getPropertiesToInject(fromVersion, toVersion) {
        const properties = {};
        
        for (const [version, versionProperties] of Object.entries(this.propertyDefinitions)) {
            if (this.versionInRange(version, fromVersion, toVersion)) {
                Object.assign(properties, versionProperties);
            }
        }
        
        return properties;
    }
    
    hasProperty(obj, path) {
        const keys = path.split('.');
        let current = obj;
        
        for (const key of keys) {
            if (!current || typeof current !== 'object' || !(key in current)) {
                return false;
            }
            current = current[key];
        }
        
        return true;
    }
    
    setProperty(obj, path, value) {
        const keys = path.split('.');
        const lastKey = keys.pop();
        let current = obj;
        
        for (const key of keys) {
            if (!(key in current) || typeof current[key] !== 'object') {
                current[key] = {};
            }
            current = current[key];
        }
        
        current[lastKey] = value;
    }
    
    versionInRange(version, from, to) {
        // Simple version comparison
        return version > from && version <= to;
    }
}

module.exports = PropertyInjector;
```

### 3. Default Configuration System

#### 3.1 Default Configuration Structure

```
~/.config/quickshell/heimdall/defaults/
├── v1.0.0.json           # Complete default for v1.0.0
├── v1.1.0.json           # Complete default for v1.1.0
├── minimal.json          # Minimal working configuration
├── profiles/
│   ├── gaming.json       # Gaming-optimized profile
│   ├── productivity.json # Productivity profile
│   └── presentation.json # Presentation mode profile
└── components/
    ├── appearance.json   # Appearance defaults
    ├── bar.json         # Bar defaults
    ├── modules.json     # Module defaults
    └── services.json    # Service defaults
```

#### 3.2 Default Instantiation System

```python
#!/usr/bin/env python3
# ~/.config/quickshell/heimdall/tools/default-manager.py

import json
import os
from pathlib import Path
from typing import Dict, Any, Optional

class DefaultManager:
    def __init__(self):
        self.defaults_dir = Path.home() / ".config/quickshell/heimdall/defaults"
        self.config_dir = Path.home() / ".config/quickshell/heimdall"
        
    def get_default_config(self, version: str = None, profile: str = "default") -> Dict[str, Any]:
        """Get default configuration for specified version and profile"""
        
        # Try version-specific default
        if version:
            version_file = self.defaults_dir / f"v{version}.json"
            if version_file.exists():
                return self.load_json(version_file)
        
        # Try profile-specific default
        profile_file = self.defaults_dir / "profiles" / f"{profile}.json"
        if profile_file.exists():
            return self.load_json(profile_file)
        
        # Fall back to minimal default
        minimal_file = self.defaults_dir / "minimal.json"
        if minimal_file.exists():
            return self.load_json(minimal_file)
        
        # Generate if nothing exists
        return self.generate_minimal_default()
    
    def instantiate_config(self, profile: str = "default") -> Path:
        """Create configuration from defaults"""
        config = self.get_default_config(profile=profile)
        
        # Personalize configuration
        config = self.personalize_config(config)
        
        # Create profile directory
        profile_dir = self.config_dir / "profiles" / profile
        profile_dir.mkdir(parents=True, exist_ok=True)
        
        # Write configuration
        config_file = profile_dir / "shell.json"
        self.save_json(config_file, config)
        
        return config_file
    
    def personalize_config(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Add user-specific values to configuration"""
        
        # Add user paths
        config.setdefault("system", {}).setdefault("paths", {}).update({
            "home": str(Path.home()),
            "config": os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config")),
            "data": os.environ.get("XDG_DATA_HOME", str(Path.home() / ".local/share")),
            "state": os.environ.get("XDG_STATE_HOME", str(Path.home() / ".local/state")),
            "cache": os.environ.get("XDG_CACHE_HOME", str(Path.home() / ".cache")),
            "wallpaperDir": str(Path.home() / "Pictures/Wallpapers")
        })
        
        # Add user info
        config.setdefault("system", {})["user"] = os.environ.get("USER", "")
        config.setdefault("system", {})["hostname"] = os.uname().nodename
        
        # Add metadata
        from datetime import datetime
        config.setdefault("metadata", {}).update({
            "created": datetime.now().isoformat(),
            "lastModified": datetime.now().isoformat()
        })
        
        return config
    
    def get_component_default(self, component: str) -> Dict[str, Any]:
        """Get default for specific component"""
        component_file = self.defaults_dir / "components" / f"{component}.json"
        
        if component_file.exists():
            return self.load_json(component_file)
        
        return {}
    
    def merge_with_defaults(self, config: Dict[str, Any]) -> Dict[str, Any]:
        """Merge user configuration with defaults"""
        version = config.get("version", "1.0.0")
        defaults = self.get_default_config(version)
        
        return self.deep_merge(defaults, config)
    
    def deep_merge(self, base: Dict[str, Any], override: Dict[str, Any]) -> Dict[str, Any]:
        """Deep merge dictionaries"""
        import copy
        result = copy.deepcopy(base)
        
        for key, value in override.items():
            if key in result and isinstance(result[key], dict) and isinstance(value, dict):
                result[key] = self.deep_merge(result[key], value)
            else:
                result[key] = value
        
        return result
    
    def generate_minimal_default(self) -> Dict[str, Any]:
        """Generate minimal working configuration"""
        return {
            "version": "1.0.0",
            "metadata": {
                "profile": "minimal"
            },
            "system": {
                "paths": {}
            },
            "appearance": {
                "rounding": {"normal": 12},
                "spacing": {"normal": 10},
                "font": {
                    "family": {"sans": "System Font"},
                    "size": {"normal": 12}
                }
            },
            "commands": {
                "terminal": "xterm",
                "logout": ["loginctl", "terminate-user", "$USER"]
            }
        }
    
    def load_json(self, path: Path) -> Dict[str, Any]:
        """Load JSON file"""
        with open(path) as f:
            return json.load(f)
    
    def save_json(self, path: Path, data: Dict[str, Any]):
        """Save JSON file"""
        with open(path, 'w') as f:
            json.dump(data, f, indent=2)
```

### 4. Path Safety and Standards

#### 4.1 Path Resolution System

```python
#!/usr/bin/env python3
# ~/.config/quickshell/heimdall/tools/path-resolver.py

import os
import re
from pathlib import Path
from typing import Union, Optional

class PathResolver:
    def __init__(self):
        self.xdg_defaults = {
            "XDG_CONFIG_HOME": Path.home() / ".config",
            "XDG_DATA_HOME": Path.home() / ".local/share",
            "XDG_STATE_HOME": Path.home() / ".local/state",
            "XDG_CACHE_HOME": Path.home() / ".cache",
            "XDG_RUNTIME_DIR": Path(f"/run/user/{os.getuid()}") if os.path.exists(f"/run/user/{os.getuid()}") else Path("/tmp")
        }
        
    def resolve(self, path: Union[str, Path]) -> Path:
        """Resolve path with full expansion"""
        if isinstance(path, Path):
            path = str(path)
        
        # Expand environment variables
        path = self.expand_env_vars(path)
        
        # Expand tilde
        path = os.path.expanduser(path)
        
        # Expand XDG variables
        path = self.expand_xdg_vars(path)
        
        # Make absolute
        path = Path(path).resolve()
        
        return path
    
    def expand_env_vars(self, path: str) -> str:
        """Expand environment variables in path"""
        # Match $VAR or ${VAR}
        pattern = re.compile(r'\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?')
        
        def replacer(match):
            var_name = match.group(1)
            return os.environ.get(var_name, match.group(0))
        
        return pattern.sub(replacer, path)
    
    def expand_xdg_vars(self, path: str) -> str:
        """Expand XDG base directory variables"""
        for var, default in self.xdg_defaults.items():
            if f"${var}" in path or f"${{{var}}}" in path:
                value = os.environ.get(var, str(default))
                path = path.replace(f"${{{var}}}", value)
                path = path.replace(f"${var}", value)
        
        return path
    
    def make_relative_to_xdg(self, path: Path, xdg_var: str) -> str:
        """Express path relative to XDG directory"""
        xdg_path = Path(os.environ.get(xdg_var, str(self.xdg_defaults.get(xdg_var))))
        
        try:
            relative = path.relative_to(xdg_path)
            return f"${{{xdg_var}}}/{relative}"
        except ValueError:
            return str(path)
    
    def validate_path(self, path: Union[str, Path], must_exist: bool = False) -> bool:
        """Validate path safety and optionally existence"""
        try:
            resolved = self.resolve(path)
            
            # Check for path traversal attempts
            if ".." in resolved.parts:
                return False
            
            # Check existence if required
            if must_exist and not resolved.exists():
                return False
            
            return True
        except Exception:
            return False
    
    def ensure_parent_dirs(self, path: Union[str, Path]) -> Path:
        """Ensure parent directories exist"""
        resolved = self.resolve(path)
        resolved.parent.mkdir(parents=True, exist_ok=True)
        return resolved
```

#### 4.2 XDG Compliance Layer

```qml
// ~/.config/quickshell/heimdall/config/XDGPaths.qml
pragma Singleton
import Quickshell

Singleton {
    // XDG Base Directory paths
    readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || `${Quickshell.env("HOME")}/.config`
    readonly property string dataHome: Quickshell.env("XDG_DATA_HOME") || `${Quickshell.env("HOME")}/.local/share`
    readonly property string stateHome: Quickshell.env("XDG_STATE_HOME") || `${Quickshell.env("HOME")}/.local/state`
    readonly property string cacheHome: Quickshell.env("XDG_CACHE_HOME") || `${Quickshell.env("HOME")}/.cache`
    readonly property string runtimeDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp"
    
    // Heimdall-specific paths (all configurable via environment)
    readonly property string heimdallConfig: Quickshell.env("HEIMDALL_CONFIG_DIR") || `${configHome}/quickshell/heimdall`
    readonly property string heimdallState: Quickshell.env("HEIMDALL_STATE_DIR") || `${stateHome}/quickshell/user/generated`
    readonly property string heimdallCache: Quickshell.env("HEIMDALL_CACHE_DIR") || `${cacheHome}/quickshell`
    readonly property string heimdallData: Quickshell.env("HEIMDALL_DATA_DIR") || `${dataHome}/quickshell`
    
    // Profile support
    readonly property string currentProfile: Quickshell.env("HEIMDALL_PROFILE") || "default"
    readonly property string profileDir: `${heimdallConfig}/profiles/${currentProfile}`
    readonly property string configFile: `${profileDir}/shell.json`
    
    // Path resolution function
    function resolve(path) {
        if (!path) return ""
        
        // Expand ~ to home
        if (path.startsWith("~/")) {
            path = Quickshell.env("HOME") + path.substring(1)
        }
        
        // Expand environment variables
        path = path.replace(/\$\{?([A-Za-z_][A-Za-z0-9_]*)\}?/g, (match, varName) => {
            return Quickshell.env(varName) || match
        })
        
        // Expand XDG shortcuts
        path = path.replace("$XDG_CONFIG_HOME", configHome)
        path = path.replace("$XDG_DATA_HOME", dataHome)
        path = path.replace("$XDG_STATE_HOME", stateHome)
        path = path.replace("$XDG_CACHE_HOME", cacheHome)
        
        return path
    }
    
    // Ensure directory exists
    function ensureDir(path) {
        const resolved = resolve(path)
        Process.execute(["mkdir", "-p", resolved])
        return resolved
    }
}
```

### 5. Configuration Flexibility

#### 5.1 Environment Variable Override System

```bash
#!/bin/bash
# ~/.config/quickshell/heimdall/init/env-overrides.sh

# Allow any configuration value to be overridden via environment
# Format: HEIMDALL_OVERRIDE_<path_with_underscores>=value
# Example: HEIMDALL_OVERRIDE_bar_height=40

heimdall_apply_env_overrides() {
    local config_file="$1"
    local temp_file="${config_file}.tmp"
    
    # Get all HEIMDALL_OVERRIDE variables
    env | grep "^HEIMDALL_OVERRIDE_" | while IFS='=' read -r var value; do
        # Convert variable name to JSON path
        # HEIMDALL_OVERRIDE_bar_height -> bar.height
        local path="${var#HEIMDALL_OVERRIDE_}"
        path="${path//_/.}"
        path="${path,,}"  # Convert to lowercase
        
        echo "Applying override: $path = $value"
        
        # Apply override using jq
        jq --arg path "$path" --arg value "$value" \
           'setpath($path | split("."); 
            if ($value | test("^[0-9]+$")) then ($value | tonumber)
            elif ($value | test("^(true|false)$")) then ($value | test("true"))
            else $value end)' \
           "$config_file" > "$temp_file" && mv "$temp_file" "$config_file"
    done
}

# Apply overrides on initialization
if [[ -f "$HEIMDALL_CONFIG_FILE" ]]; then
    heimdall_apply_env_overrides "$HEIMDALL_CONFIG_FILE"
fi
```

#### 5.2 Profile System

```python
#!/usr/bin/env python3
# ~/.config/quickshell/heimdall/tools/profile-manager.py

import json
import os
import sys
from pathlib import Path
from typing import Dict, Any, List, Optional
import argparse

class ProfileManager:
    def __init__(self):
        self.config_dir = Path.home() / ".config/quickshell/heimdall"
        self.profiles_dir = self.config_dir / "profiles"
        self.profiles_dir.mkdir(parents=True, exist_ok=True)
        
    def list_profiles(self) -> List[str]:
        """List all available profiles"""
        profiles = []
        
        for profile_dir in self.profiles_dir.iterdir():
            if profile_dir.is_dir() and (profile_dir / "shell.json").exists():
                profiles.append(profile_dir.name)
        
        return sorted(profiles)
    
    def get_active_profile(self) -> str:
        """Get currently active profile"""
        return os.environ.get("HEIMDALL_PROFILE", "default")
    
    def set_active_profile(self, profile: str) -> bool:
        """Set active profile"""
        profile_dir = self.profiles_dir / profile
        
        if not profile_dir.exists():
            print(f"Profile '{profile}' does not exist")
            return False
        
        # Update shell initialization
        init_file = self.config_dir / "init" / "active-profile"
        init_file.parent.mkdir(parents=True, exist_ok=True)
        init_file.write_text(profile)
        
        print(f"Active profile set to '{profile}'")
        print("Restart your shell for changes to take effect")
        return True
    
    def create_profile(self, name: str, base: Optional[str] = None) -> bool:
        """Create new profile"""
        profile_dir = self.profiles_dir / name
        
        if profile_dir.exists():
            print(f"Profile '{name}' already exists")
            return False
        
        profile_dir.mkdir(parents=True, exist_ok=True)
        
        # Copy from base profile or create from defaults
        if base:
            base_config = self.load_profile(base)
            if not base_config:
                print(f"Base profile '{base}' not found")
                return False
            config = base_config.copy()
        else:
            config = self.create_default_config()
        
        # Update metadata
        config["metadata"]["profile"] = name
        
        # Save profile
        config_file = profile_dir / "shell.json"
        with open(config_file, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"Profile '{name}' created successfully")
        return True
    
    def delete_profile(self, name: str) -> bool:
        """Delete profile"""
        if name == "default":
            print("Cannot delete default profile")
            return False
        
        profile_dir = self.profiles_dir / name
        
        if not profile_dir.exists():
            print(f"Profile '{name}' does not exist")
            return False
        
        # Remove profile directory
        import shutil
        shutil.rmtree(profile_dir)
        
        print(f"Profile '{name}' deleted")
        return True
    
    def load_profile(self, name: str) -> Optional[Dict[str, Any]]:
        """Load profile configuration"""
        config_file = self.profiles_dir / name / "shell.json"
        
        if not config_file.exists():
            return None
        
        with open(config_file) as f:
            return json.load(f)
    
    def switch_profile(self, name: str) -> bool:
        """Switch to different profile"""
        if name not in self.list_profiles():
            print(f"Profile '{name}' does not exist")
            return False
        
        # Set as active
        self.set_active_profile(name)
        
        # Reload quickshell if running
        os.system("heimdall shell -r")
        
        return True
    
    def create_default_config(self) -> Dict[str, Any]:
        """Create default configuration"""
        return {
            "version": "1.0.0",
            "metadata": {
                "profile": "default"
            },
            "system": {
                "paths": {}
            }
        }

def main():
    parser = argparse.ArgumentParser(description="Heimdall Profile Manager")
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # List profiles
    subparsers.add_parser("list", help="List all profiles")
    
    # Get active profile
    subparsers.add_parser("active", help="Show active profile")
    
    # Create profile
    create_parser = subparsers.add_parser("create", help="Create new profile")
    create_parser.add_argument("name", help="Profile name")
    create_parser.add_argument("--base", help="Base profile to copy from")
    
    # Delete profile
    delete_parser = subparsers.add_parser("delete", help="Delete profile")
    delete_parser.add_argument("name", help="Profile name")
    
    # Switch profile
    switch_parser = subparsers.add_parser("switch", help="Switch to profile")
    switch_parser.add_argument("name", help="Profile name")
    
    args = parser.parse_args()
    
    manager = ProfileManager()
    
    if args.command == "list":
        profiles = manager.list_profiles()
        active = manager.get_active_profile()
        for profile in profiles:
            marker = " (active)" if profile == active else ""
            print(f"  {profile}{marker}")
    
    elif args.command == "active":
        print(manager.get_active_profile())
    
    elif args.command == "create":
        manager.create_profile(args.name, args.base)
    
    elif args.command == "delete":
        manager.delete_profile(args.name)
    
    elif args.command == "switch":
        manager.switch_profile(args.name)
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
```

## Implementation Task Order

### Phase 0: Infrastructure Setup (Day 0 - 4 hours)

1. **Create Directory Structure**
   ```bash
   mkdir -p ~/.config/quickshell/heimdall/{init,tools,defaults,profiles,migrations,hooks}
   mkdir -p ~/.config/quickshell/heimdall/defaults/{profiles,components}
   mkdir -p ~/.config/quickshell/heimdall/hooks/{pre-launch,post-launch}
   ```

2. **Deploy Core Scripts**
   - [ ] Install shell-init.sh and shell-init.fish
   - [ ] Install config-manager.sh
   - [ ] Install version-manager.py
   - [ ] Install default-manager.py
   - [ ] Install path-resolver.py
   - [ ] Install profile-manager.py

3. **Create Default Configurations**
   - [ ] Generate v1.0.0.json default
   - [ ] Create minimal.json fallback
   - [ ] Create component defaults
   - [ ] Create profile templates

4. **Shell Integration**
   - [ ] Add initialization to .bashrc
   - [ ] Add initialization to .zshrc
   - [ ] Add initialization to config.fish
   - [ ] Test shell startup

### Phase 1: Enhanced Critical Fixes (Day 1)

Building on original Phase 1, add:

1. **Automatic Configuration Creation**
   - [ ] Test auto-creation on fresh install
   - [ ] Verify default injection
   - [ ] Test path personalization

2. **Version Detection**
   - [ ] Implement version checking
   - [ ] Test migration scenarios
   - [ ] Verify property injection

### Testing Procedures

#### Test 1: Fresh Installation
```bash
#!/bin/bash
# test-fresh-install.sh

# Remove all configuration
rm -rf ~/.config/quickshell/heimdall
rm -rf ~/.local/state/quickshell

# Start new shell
bash --login

# Verify configuration created
[[ -f "$HEIMDALL_CONFIG_FILE" ]] && echo "✓ Config auto-created" || echo "✗ Config missing"

# Verify paths personalized
grep -q "$HOME" "$HEIMDALL_CONFIG_FILE" && echo "✓ Paths personalized" || echo "✗ Paths not personalized"
```

#### Test 2: Version Migration
```bash
#!/bin/bash
# test-version-migration.sh

# Create old version config
cat > ~/.config/quickshell/heimdall/shell.json <<EOF
{
  "version": "0.1.0",
  "appearance": {}
}
EOF

# Trigger migration
python3 ~/.config/quickshell/heimdall/tools/version-manager.py

# Verify migration
jq -r '.version' ~/.config/quickshell/heimdall/shell.json | grep "1.0.0" && echo "✓ Version migrated"
```

#### Test 3: Profile Switching
```bash
#!/bin/bash
# test-profile-switching.sh

# Create profiles
heimdall-profile create gaming
heimdall-profile create presentation

# Switch profile
heimdall-profile switch gaming

# Verify active profile
[[ "$HEIMDALL_PROFILE" == "gaming" ]] && echo "✓ Profile switched"
```

#### Test 4: Path Resolution
```python
#!/usr/bin/env python3
# test-path-resolution.py

from path_resolver import PathResolver

resolver = PathResolver()

# Test cases
tests = [
    ("~/Documents", f"{os.environ['HOME']}/Documents"),
    ("$HOME/Pictures", f"{os.environ['HOME']}/Pictures"),
    ("${XDG_CONFIG_HOME}/app", f"{os.environ.get('XDG_CONFIG_HOME', os.environ['HOME'] + '/.config')}/app"),
    ("$XDG_DATA_HOME/data", f"{os.environ.get('XDG_DATA_HOME', os.environ['HOME'] + '/.local/share')}/data")
]

for input_path, expected in tests:
    resolved = str(resolver.resolve(input_path))
    assert resolved == expected, f"Failed: {input_path} -> {resolved} (expected {expected})"
    print(f"✓ {input_path} -> {resolved}")
```

## Conclusion

This enhanced implementation plan provides a robust, zero-configuration system that automatically handles initialization, versioning, and path management. The system ensures that users never need to manually configure Heimdall while maintaining full flexibility for customization through environment variables and profiles. The automatic shell initialization guarantees that configuration is always valid before Quickshell starts, eliminating startup failures and configuration-related issues.