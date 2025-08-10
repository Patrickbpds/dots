# OpenCode Agent Suite

A comprehensive collection of specialized AI agents for professional software engineering workflows.

## Overview

This agent suite provides a structured approach to software development with specialized agents for planning, implementation, debugging, refactoring, and research. Each agent is optimized for its specific domain with appropriate tools and temperature settings.

## Primary Agents (Tab-switchable)

| Agent | Purpose | Key Features |
|-------|---------|--------------|
| **plan** | Strategic planning and architecture | Read-only, creates structured plans in `docs/plans/` |
| **implement** | Phase-by-phase execution | Follows plans, validates continuously, updates progress |
| **debug** | Issue investigation and fixing | Systematic debugging, root cause analysis |
| **refactor** | Code quality improvement | Safety-first transformations, zero regression |
| **research** | Deep exploration and discovery | Technology evaluation, best practices research |

## Subagents (Auto-delegated or @-invokable)

### Planning Subagents
- **architect**: System design and architecture decisions
- **spec-writer**: Technical specification creation
- **risk-analyzer**: Risk assessment and mitigation
- **plan-documenter**: Structured plan document creation

### Implementation Subagents
- **code-generator**: Initial code creation from specs
- **integrator**: System integration specialist
- **test-writer**: Comprehensive test suite creation
- **validator**: Phase validation and testing

### Debugging Subagents
- **log-analyzer**: Log analysis and pattern detection
- **reproducer**: Minimal bug reproduction
- **fixer**: Targeted issue resolution

### Refactoring Subagents
- **transformer**: Safe code transformations
- **code-reviewer**: Quality and security review

## Quick Start

1. **Switch agents**: Use Tab key to cycle through primary agents
2. **Invoke subagents**: Use @subagent-name or let primary agents auto-delegate
3. **Follow workflows**: Plan → Implement → Debug/Refactor as needed

## Key Workflows

### Feature Development
```
Plan agent → Creates plan in docs/plans/
Implement agent → Executes plan phases
Debug agent → Fixes any issues
```

### Bug Investigation
```
Debug agent → Analyzes issue
@reproducer → Creates minimal repro
@fixer → Applies targeted fix
```

### Code Improvement
```
Research agent → Investigates options
Refactor agent → Applies improvements
@code-reviewer → Validates changes
```

## Plan Document Structure

Plans are created in `docs/plans/feature-name.md` with:
- Context and requirements
- Detailed specifications
- Phased implementation plan
- Risk mitigation strategies
- Dev log for progress tracking

## Configuration

All agents are configured in:
- `opencode.json`: Main configuration with agent registry
- `agent/primary/`: Primary agent definitions
- `agent/subagents/`: Subagent definitions by category

## Best Practices

1. **Always start with planning** for non-trivial tasks
2. **Use the right agent** for each task type
3. **Let agents delegate** to subagents automatically
4. **Maintain documentation** through plan updates
5. **Validate continuously** during implementation

## Documentation

- `AGENT_SUITE_PLAN.md`: Complete implementation plan
- `AGENT_USAGE_GUIDE.md`: Detailed usage instructions
- Individual agent files: Specific agent documentation

## Customization

Agents can be customized by:
- Modifying temperature settings
- Adjusting tool permissions
- Editing prompt files
- Creating new subagents

## Support

For issues or questions:
- Review the usage guide
- Check agent descriptions
- Examine example workflows
- Modify prompts as needed

---

*This agent suite is designed for staff-level software engineering workflows with emphasis on quality, documentation, and systematic development practices.*