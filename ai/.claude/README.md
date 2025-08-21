# Claude Code Agent Workflow Migration

This directory contains your migrated agent workflow from OpenCode/Gemini to Claude Code format.

## Migration Summary

✅ **Successfully migrated**:
- 6 primary agents → custom slash commands in `/commands/`
- 8 core subagents → Claude Code subagents in `/agents/`
- Complete delegation-based workflow preserved
- Quality gates and testing protocols maintained
- Documentation structure and patterns preserved

## Directory Structure

```
.claude/
├── commands/           # Primary agents as custom slash commands
│   ├── plan.md        # Strategic Project Planner
│   ├── implement.md   # Test-Driven Implementation Executor  
│   ├── research.md    # Knowledge Investigator
│   ├── debug.md       # Systematic Issue Investigator
│   ├── test.md        # Comprehensive Testing Specialist
│   └── blueprint.md   # Technical Templating Specialist
├── agents/            # Specialized subagents
│   ├── executor.md    # Command and code execution
│   ├── documenter.md  # Documentation creation
│   ├── researcher.md  # Information gathering
│   ├── synthesizer.md # Analysis and consolidation
│   ├── reviewer.md    # Final quality validation
│   ├── test-analyzer.md    # Test scenario analysis
│   ├── test-generator.md   # Test implementation
│   └── validator.md   # Test execution and validation
└── README.md          # This file
```

## How to Use Your Migrated Workflow

### Primary Agent Commands (Slash Commands)

Use these as custom slash commands in Claude Code:

```bash
# Strategic planning
/plan "Add user authentication to the application"

# Implementation with test-driven approach  
/implement "User authentication system from plan"

# Research and investigation
/research "OAuth2 vs JWT authentication approaches"

# Issue debugging and resolution
/debug "Login failing with 500 error"

# Comprehensive testing
/test "Authentication module with edge cases"

# Template and pattern creation
/blueprint "Authentication service template"
```

### Subagent Delegation

Your primary agents automatically delegate to specialized subagents:

**Core Subagents**:
- `executor` - Runs commands, implements code
- `documenter` - Creates all documentation  
- `researcher` - Gathers external information
- `synthesizer` - Organizes and consolidates findings
- `reviewer` - Final quality validation

**Testing Subagents**:
- `test-analyzer` - Identifies test scenarios and coverage needs
- `test-generator` - Creates high-quality test implementations
- `validator` - Executes tests and quality checks

## Key Features Preserved

### 1. Delegation-Based Architecture
- Primary agents maintain 70-75% delegation ratios
- Specialized subagents handle specific tasks
- Clear separation of orchestration vs execution

### 2. Test-Driven Implementation
- Baseline test validation before any changes
- Phase-by-phase implementation with test gates
- Continuous working state maintenance

### 3. Quality Gates
- Mandatory validation at all convergence points
- Comprehensive testing and validation requirements
- Final review before completion

### 4. Documentation Standards
- Structured documentation in `/docs/` directory
- Consistent naming conventions (kebab-case)
- Context-appropriate documentation for each agent type

### 5. Parallel Execution Patterns
- Multiple research streams for comprehensive coverage
- Independent task execution where possible
- Systematic coordination and convergence

## Usage Examples

### Planning a New Feature
```bash
# Start with strategic planning
/plan "Add real-time notifications to the messaging system"

# The plan agent will:
# 1. Create todo list with delegation tasks
# 2. Use researcher subagent for best practices
# 3. Use synthesizer subagent for requirements organization  
# 4. Use documenter subagent to create /docs/plans/notifications-plan.md
# 5. Use reviewer subagent for final validation
```

### Implementing from a Plan
```bash
# Execute test-driven implementation
/implement "Real-time notifications from plan"

# The implement agent will:
# 1. Validate plan exists and baseline tests pass
# 2. Use test-analyzer subagent to identify testing strategy
# 3. Use test-generator subagent to create tests for each phase
# 4. Use executor subagent to implement code following patterns
# 5. Use validator subagent to run tests after each phase
# 6. Use reviewer subagent for final validation
```

### Research and Investigation
```bash
# Conduct comprehensive research
/research "WebSocket vs Server-Sent Events for real-time features"

# The research agent will:
# 1. Use researcher subagent for information gathering
# 2. Use synthesizer subagent to consolidate findings
# 3. Use documenter subagent to create /docs/research/realtime-comparison-research.md
# 4. Use reviewer subagent to validate research quality
```

## Migration Benefits

### Simplified Architecture
- Native Claude Code subagent management via `/agents` command
- Automatic subagent discovery and invocation
- Streamlined delegation patterns

### Enhanced Integration
- Works seamlessly with Claude Code's built-in tools
- Integrates with MCP servers for extended functionality
- Compatible with Claude Code hooks and automation

### Improved Maintainability
- Standard markdown format for all agents and commands
- Version control friendly configuration
- Easy to modify and extend

### Better User Experience
- Familiar slash command interface
- Clear delegation and progress tracking
- Comprehensive documentation and help

## Next Steps

1. **Test the workflow**: Try the slash commands with small tasks
2. **Customize as needed**: Modify agent descriptions and tools based on your specific needs
3. **Add MCP integration**: Connect external tools and services as needed
4. **Extend subagents**: Add project-specific subagents for specialized workflows

## Differences from Original

### What Changed
- **Format**: TOML → Markdown with YAML frontmatter
- **Invocation**: Custom commands → Built-in slash commands
- **Tool specification**: OpenCode tools → Claude Code tools
- **Agent management**: File-based → Built-in `/agents` command

### What Stayed the Same
- **Core workflow**: Delegation-based orchestration
- **Quality standards**: Comprehensive testing and validation
- **Documentation patterns**: Structured docs in `/docs/`
- **Agent roles**: Same responsibilities and constraints
- **Success criteria**: Same quality gates and completion requirements

## Troubleshooting

If you encounter issues:

1. **Command not found**: Run `/agents` to see available subagents
2. **Tool permissions**: Check `allowed-tools` in agent frontmatter
3. **Delegation issues**: Verify subagent names match file names
4. **Documentation**: Check `/docs/` directory structure and permissions

Your migrated workflow maintains all the sophisticated delegation patterns and quality assurance while being fully compatible with Claude Code's native architecture.