# OpenCode Agent Suite Usage Guide

## Quick Start

### Switching Between Primary Agents
- Use **Tab** key to cycle through primary agents (plan → implement → debug → refactor → research)
- Or use your configured `switch_agent` keybind
- Current agent shown in the interface

### Using Subagents
- Primary agents automatically delegate to subagents
- Manually invoke with `@subagent-name` in your message
- Example: `@code-reviewer please review this function`

## Common Workflows

### 1. Feature Development Workflow

#### Step 1: Planning
```
[Switch to Plan agent with Tab]

User: I need to add a shopping cart feature to our e-commerce site. Users should be able to add items, update quantities, remove items, and see the total price with tax calculation.

Plan Agent will:
- Use @architect to design the cart architecture
- Use @spec-writer to detail requirements
- Use @risk-analyzer to identify potential issues
- Use @plan-documenter to create docs/plans/shopping-cart.md
```

#### Step 2: Implementation
```
[Switch to Implement agent with Tab]

User: Let's implement the shopping cart plan

Implement Agent will:
- Read docs/plans/shopping-cart.md
- Execute Phase 1: Create cart data models
  - Use @code-generator for initial code
  - Use @validator to check it works
  - Mark tasks complete in plan
  - Update dev log in plan
- Continue through all phases
- Maintain continuous validation
```

#### Step 3: Debugging (if needed)
```
[Switch to Debug agent with Tab]

User: The cart total calculation is wrong when applying discounts

Debug Agent will:
- Use @log-analyzer to check for errors
- Trace the calculation logic
- Create minimal reproduction
- Apply targeted fix
- Add regression test
```

### 2. Bug Investigation Workflow

```
[Switch to Debug agent]

User: Users report that the search feature returns no results intermittently, especially during high traffic

Debug Agent will:
1. Gather information with @log-analyzer
2. Identify patterns in failures
3. Create reproduction steps
4. Trace execution flow
5. Identify root cause
6. Apply fix
7. Add monitoring
```

### 3. Code Improvement Workflow

```
[Switch to Refactor agent]

User: The user service has grown too large and complex. It needs refactoring.

Refactor Agent will:
1. Analyze current structure
2. Identify code smells
3. Plan refactoring approach
4. Apply transformations safely
5. Ensure no regression
6. Document improvements
```

### 4. Research Workflow

```
[Switch to Research agent]

User: We need to choose between Redis and Memcached for our caching layer. Research the best option for our use case.

Research Agent will:
1. Define evaluation criteria
2. Research both technologies
3. Compare features and performance
4. Analyze fit for use case
5. Provide recommendations
6. Document findings in docs/research/
```

## Advanced Usage

### Combining Agents in Complex Tasks

```
User: We have performance issues in our API. Research the problem, plan optimizations, and implement them.

Workflow:
1. [Research agent]: Investigate bottlenecks
2. [Plan agent]: Create optimization plan based on research
3. [Implement agent]: Execute the optimization plan
4. [Debug agent]: Fix any issues that arise
```

### Plan Document Lifecycle

1. **Creation** (Plan agent)
   - Creates docs/plans/feature-name.md
   - Status: Planning

2. **Execution** (Implement agent)
   - Status: In Progress
   - Tasks marked with [x] as completed
   - Dev log updated continuously

3. **Completion**
   - Status: Completed
   - All tasks marked complete
   - Dev log contains full history

### Subagent Chaining

Primary agents automatically chain subagents:

```
Plan Agent workflow:
User input → @architect → @spec-writer → @risk-analyzer → @plan-documenter → Final plan

Implement Agent workflow:
Read plan → @code-generator → @integrator → @test-writer → @validator → Update plan
```

## Best Practices

### 1. Always Start with Planning
- Even for "simple" features
- Plans prevent scope creep
- Clear requirements reduce bugs

### 2. Use the Right Agent
- Don't use Implement for planning
- Don't use Plan for debugging
- Each agent is optimized for its purpose

### 3. Let Agents Delegate
- Trust automatic subagent selection
- Only manually invoke when needed
- Agents know when to use subagents

### 4. Maintain Documentation
- Plans are living documents
- Dev logs provide history
- Research informs decisions

### 5. Validate Continuously
- Implement agent validates each phase
- Debug agent verifies fixes
- Refactor agent ensures no regression

## Tips and Tricks

### Quick Commands
```
# Quick planning
[Plan agent]: Create a plan for [feature]

# Quick implementation
[Implement agent]: Implement the plan in docs/plans/[name].md

# Quick debugging
[Debug agent]: Debug [error message or symptom]

# Quick refactoring
[Refactor agent]: Refactor [component] for better [quality]

# Quick research
[Research agent]: Research best practices for [topic]
```

### Effective Prompts

#### For Planning
- Include clear requirements
- Specify constraints
- Mention performance needs
- Note security concerns

#### For Implementation
- Reference the plan explicitly
- Specify priority if needed
- Mention testing requirements

#### For Debugging
- Provide error messages
- Describe symptoms clearly
- Include reproduction steps
- Mention frequency

#### For Refactoring
- Specify quality goals
- Identify problem areas
- Set performance targets

#### For Research
- Define evaluation criteria
- Specify constraints
- Request comparisons
- Ask for recommendations

## Troubleshooting

### Agent Not Switching
- Check keybind configuration
- Ensure agent is not disabled
- Verify agent files exist

### Subagent Not Invoked
- Check subagent description
- Ensure mode is "subagent"
- Verify @ mention syntax

### Plan Not Found
- Check docs/plans/ directory
- Verify plan name
- Ensure plan was created

### Validation Failing
- Check test commands
- Verify dependencies installed
- Review error messages

## Examples by Role

### For Staff Engineers
- Complex system design: Research → Plan → Implement
- Performance optimization: Debug → Research → Refactor
- Architecture evolution: Research → Plan → Refactor → Implement

### For Feature Development
- New feature: Plan → Implement → Debug
- Feature enhancement: Research → Plan → Implement
- Bug fix: Debug → Implement

### For Code Quality
- Technical debt: Refactor → Implement
- Code review: Use @code-reviewer subagent
- Security audit: Use @security-auditor subagent

## Monitoring Progress

### Check Plan Status
- Look for Status field in plan
- Review checked tasks
- Read dev log entries

### Track Implementation
- Monitor task completion
- Review validation results
- Check test coverage

### Measure Success
- Plans completed on time
- Fewer bugs in production
- Improved code metrics
- Better documentation

## Getting Help

### Agent Capabilities
- Each agent has a description
- Check agent markdown files
- Review temperature settings

### Workflow Support
- Start with simple workflows
- Build complexity gradually
- Learn agent patterns

### Customization
- Modify agent prompts
- Adjust temperatures
- Configure tool access
- Create custom subagents

Remember: The agent suite is designed to make you more productive. Start with basic workflows and gradually adopt more advanced patterns as you become comfortable with the system.