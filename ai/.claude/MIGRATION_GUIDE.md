# Migration Guide: OpenCode/Gemini → Claude Code

## Quick Reference

### Before (OpenCode/Gemini)
```bash
# Gemini commands
gemini plan "Add authentication"
gemini implement "User login system"
gemini research "OAuth vs JWT"

# OpenCode agent files
.config/opencode/agent/plan.md
.config/opencode/agent/execution/executor.md
```

### After (Claude Code)
```bash
# Claude Code slash commands  
/plan "Add authentication"
/implement "User login system"
/research "OAuth vs JWT"

# Claude Code native files
.claude/commands/plan.md
.claude/agents/executor.md
```

## Key Changes

### 1. Command Invocation
- **Old**: `gemini plan "task"` → **New**: `/plan "task"`
- **Old**: Custom command format → **New**: Native slash commands
- **Old**: TOML configuration → **New**: Markdown with YAML frontmatter

### 2. Agent Management
- **Old**: Manual file management → **New**: Built-in `/agents` command
- **Old**: Complex XML templates → **New**: Simple markdown format
- **Old**: Tool configuration in separate files → **New**: Tools in frontmatter

### 3. Delegation Patterns
- **Old**: `@subagent` references → **New**: `task` tool with subagent_type
- **Old**: Complex role enforcement → **New**: Simplified but maintained delegation
- **Old**: Manual subagent discovery → **New**: Automatic discovery

## Migration Benefits

### Simplified Management
- Use `/agents` to view and manage all subagents
- Automatic discovery of available subagents
- Native integration with Claude Code tools

### Better Integration
- Works with Claude Code hooks and automation
- Compatible with MCP servers for extended functionality
- Seamless integration with Claude Code settings

### Improved Developer Experience
- Familiar slash command interface for primary agents
- Clear markdown documentation format
- Easy to version control and collaborate on

## Preserved Features

✅ **Complete delegation workflow** - All orchestration patterns maintained
✅ **Quality gates and testing** - Test-driven approach fully preserved  
✅ **Documentation standards** - Same structure and naming conventions
✅ **Parallel execution** - Multi-stream coordination maintained
✅ **Role enforcement** - Agent boundaries and responsibilities preserved
✅ **Error handling** - Escalation and recovery protocols maintained

## Usage Patterns

### Planning Phase
```bash
# Same workflow, different syntax
/plan "Build user dashboard with analytics"

# Agent automatically:
# 1. Creates todo list via todowrite
# 2. Delegates research to researcher subagent  
# 3. Delegates analysis to synthesizer subagent
# 4. Delegates documentation to documenter subagent
# 5. Uses reviewer subagent for final validation
```

### Implementation Phase  
```bash
# Test-driven implementation maintained
/implement "User dashboard from plan"

# Agent automatically:
# 1. Validates plan exists and baseline tests pass
# 2. Uses test-analyzer for testing strategy
# 3. Uses test-generator for test creation
# 4. Uses executor for code implementation
# 5. Uses validator for test execution
# 6. Maintains working state throughout
```

## Configuration Differences

### Tool Configuration
```yaml
# Old (OpenCode)
tools:
  write: true
  edit: true
  bash: false

# New (Claude Code)  
tools: write, edit, read, grep, glob, list
# (bash excluded for safety)
```

### Agent Definition
```yaml
# Old (OpenCode)
---
mode: subagent
description: "Long description"
tools: [complex configuration]
---

# New (Claude Code)
---
name: agent-name
description: "When to use this agent (concise)"
tools: tool1, tool2, tool3
---
```

## Troubleshooting

### Common Issues

1. **Command not found**
   - Solution: Ensure markdown files are in `.claude/commands/`
   - Check YAML frontmatter format

2. **Subagent not available**  
   - Solution: Run `/agents` to verify subagent exists
   - Check file naming (kebab-case) and location

3. **Tool permissions**
   - Solution: Review `allowed-tools` in command frontmatter
   - Update tools list as needed

4. **Delegation not working**
   - Solution: Check subagent name matches file name
   - Verify `task` tool is available in allowed-tools

### Validation Commands
```bash
# Check structure
ls -la .claude/commands/
ls -la .claude/agents/

# Test command availability
# (Use /help to see available commands)

# Test subagent availability  
# (Use /agents to see available subagents)
```

## Migration Checklist

- [x] Primary agents migrated to slash commands
- [x] Core subagents migrated to Claude Code format  
- [x] Specialized subagents created
- [x] Tool permissions configured appropriately
- [x] Documentation structure preserved
- [x] Quality gates and validation maintained
- [x] Testing workflow preserved
- [x] Delegation patterns maintained

Your workflow is now fully migrated and ready to use with Claude Code!