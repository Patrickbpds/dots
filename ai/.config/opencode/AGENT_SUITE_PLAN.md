# OpenCode Agent Suite Implementation Plan

## Overview
A comprehensive suite of specialized agents for staff software engineering workflows, designed to handle research, discovery, exploration, creation, and fixing tasks with granular subagent delegation.

## Core Workflow Architecture

### Primary Workflow: Plan → Implement → Verify
1. **Plan Agent** (primary): Analyzes requirements and creates structured plans
2. **Implement Agent** (primary): Executes plans phase-by-phase with continuous validation
3. **Verify Agent** (subagent): Validates each implementation phase

### Supporting Workflows
- **Debug Workflow**: Investigate → Diagnose → Fix → Verify
- **Refactor Workflow**: Analyze → Plan → Transform → Validate
- **Research Workflow**: Discover → Explore → Document → Synthesize

## Agent Hierarchy

### Primary Agents (Tab-switchable)

#### 1. Plan Agent
- **Purpose**: Strategic planning and architecture design
- **Tools**: Read-only access (no write/edit/bash)
- **Subagents Used**:
  - `architect`: System design and architecture decisions
  - `spec-writer`: Technical specification creation
  - `risk-analyzer`: Risk assessment and mitigation planning
  - `plan-documenter`: Creates structured plan documents

#### 2. Implement Agent
- **Purpose**: Execute plans with phase-by-phase implementation
- **Tools**: Full access with emphasis on incremental changes
- **Unique Features**:
  - Reads plan from `docs/plans/`
  - Marks tasks as completed in plan document
  - Maintains `docs/dev-log.md` for implementation history
- **Subagents Used**:
  - `code-generator`: Initial code creation
  - `integrator`: Integrates new code with existing
  - `test-writer`: Creates tests for new functionality
  - `validator`: Validates each phase doesn't break existing code

#### 3. Debug Agent
- **Purpose**: Investigate and fix issues
- **Tools**: Full access with emphasis on investigation
- **Subagents Used**:
  - `log-analyzer`: Analyzes logs and error messages
  - `tracer`: Traces execution flow
  - `reproducer`: Creates minimal reproductions
  - `fixer`: Applies targeted fixes

#### 4. Refactor Agent
- **Purpose**: Improve code quality and structure
- **Tools**: Full access with safety checks
- **Subagents Used**:
  - `code-analyzer`: Identifies improvement opportunities
  - `pattern-detector`: Finds code patterns and anti-patterns
  - `transformer`: Applies refactoring transformations
  - `regression-tester`: Ensures no functionality breaks

#### 5. Research Agent
- **Purpose**: Deep research and exploration
- **Tools**: Read access + web tools
- **Subagents Used**:
  - `explorer`: Explores codebase structure
  - `searcher`: Advanced code search
  - `documenter`: Documents findings
  - `synthesizer`: Synthesizes research into actionable insights

### Specialized Subagents

#### Planning & Documentation
1. **architect**: System design and architecture decisions
2. **spec-writer**: Technical specification creation
3. **risk-analyzer**: Risk assessment and mitigation
4. **plan-documenter**: Creates structured plan documents
5. **api-designer**: API design and documentation

#### Implementation & Integration
6. **code-generator**: Initial code creation from specs
7. **integrator**: Integrates new code with existing systems
8. **test-writer**: Creates comprehensive test suites
9. **validator**: Validates implementation phases
10. **migration-planner**: Plans data/schema migrations

#### Quality & Testing
11. **code-reviewer**: Reviews code for best practices
12. **security-auditor**: Security vulnerability detection
13. **performance-analyzer**: Performance optimization
14. **regression-tester**: Ensures no functionality breaks
15. **coverage-analyzer**: Test coverage analysis

#### Debugging & Analysis
16. **log-analyzer**: Analyzes logs and error messages
17. **tracer**: Traces execution flow
18. **reproducer**: Creates minimal reproductions
19. **fixer**: Applies targeted fixes
20. **profiler**: Performance profiling

#### Refactoring & Optimization
21. **code-analyzer**: Identifies improvement opportunities
22. **pattern-detector**: Finds patterns and anti-patterns
23. **transformer**: Applies refactoring transformations
24. **dependency-updater**: Updates and manages dependencies
25. **dead-code-eliminator**: Removes unused code

#### Documentation & Communication
26. **doc-writer**: Technical documentation
27. **comment-writer**: Inline code documentation
28. **changelog-writer**: Changelog generation
29. **readme-updater**: README maintenance
30. **example-creator**: Creates usage examples

## Plan Document Structure

### Standard Plan Template (`docs/plans/feature-name-summary.md`)

```markdown
# Plan: [Feature Name]
Date: YYYY-MM-DD
Status: [Planning|In Progress|Completed]
Agent: plan
Implementer: implement

## Context
### Problem Statement
[Clear description of the problem being solved]

### Current State
[Description of existing system/code]

### Goals
- [ ] Primary goal 1
- [ ] Primary goal 2

### Constraints
- Technical constraints
- Business constraints
- Time constraints

## Specification
### Functional Requirements
1. [ ] Requirement 1
2. [ ] Requirement 2

### Non-Functional Requirements
- Performance targets
- Security requirements
- Scalability needs

### API Design
[API specifications if applicable]

### Data Model
[Data structure changes if applicable]

## Implementation Plan
### Phase 1: Foundation
- [ ] Task 1.1: Description
  - Acceptance criteria
  - Test requirements
- [ ] Task 1.2: Description

### Phase 2: Core Features
- [ ] Task 2.1: Description
- [ ] Task 2.2: Description

### Phase 3: Integration
- [ ] Task 3.1: Description
- [ ] Task 3.2: Description

### Phase 4: Testing & Validation
- [ ] Task 4.1: Unit tests
- [ ] Task 4.2: Integration tests
- [ ] Task 4.3: Performance validation

## Risk Mitigation
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Risk 1 | High | Medium | Strategy |

## Success Metrics
- Metric 1: Target value
- Metric 2: Target value

## Dev Log
[Implementation notes added by implement agent throughout execution]

### [Date] - Phase 1: Foundation
- [x] Task 1.1: Description
  - Implementation approach: How it was implemented
  - Challenges: Any issues encountered
  - Test results: X/Y tests passing
  - Performance: Metrics if relevant

### [Date] - Phase 2: Core Features
- [ ] Task 2.1: Description
  - Notes: Work in progress...
```

## Example Workflows

### Workflow 1: Feature Development
```
User: "I need to add user authentication to the app"

1. Plan Agent:
   - @architect: Designs auth architecture
   - @spec-writer: Creates detailed specs
   - @risk-analyzer: Identifies security risks
   - @plan-documenter: Creates docs/plans/user-authentication.md

2. Implement Agent:
   - Reads plan document
   - Phase 1: @code-generator creates auth models
   - @validator: Checks models work
   - Marks Phase 1 tasks complete in plan
   - Updates dev-log section in plan
   - Phase 2: @integrator adds auth middleware
   - @test-writer: Creates auth tests
   - @validator: Runs tests
   - Updates dev-log section with progress

3. Debug Agent (if issues):
   - @log-analyzer: Checks error logs
   - @reproducer: Creates minimal repro
   - @fixer: Applies fix
```

### Workflow 2: Performance Optimization
```
User: "The API is slow, needs optimization"

1. Research Agent:
   - @explorer: Maps API structure
   - @profiler: Identifies bottlenecks
   - @synthesizer: Creates optimization plan

2. Plan Agent:
   - @architect: Designs optimization strategy
   - @plan-documenter: Creates optimization plan

3. Refactor Agent:
   - @transformer: Applies optimizations
   - @performance-analyzer: Validates improvements
   - @regression-tester: Ensures no breaks
```

### Workflow 3: Bug Investigation
```
User: "Users report login fails intermittently"

1. Debug Agent:
   - @log-analyzer: Analyzes error patterns
   - @tracer: Traces auth flow
   - @reproducer: Creates reproduction steps
   - @fixer: Implements fix
   - @test-writer: Adds regression test
```

## Implementation Strategy

### Phase 1: Core Agents (Week 1)
1. Create Plan agent with planning subagents
2. Create Implement agent with plan-reading capability
3. Create basic validation subagents

### Phase 2: Supporting Agents (Week 2)
1. Create Debug agent and debugging subagents
2. Create Refactor agent and refactoring subagents
3. Create Research agent and research subagents

### Phase 3: Specialized Subagents (Week 3)
1. Implement all quality/testing subagents
2. Implement documentation subagents
3. Implement optimization subagents

### Phase 4: Integration & Testing (Week 4)
1. Test agent interactions
2. Refine prompts based on usage
3. Create example workflows
4. Document best practices

## Configuration Structure

```
ai/.config/opencode/
├── opencode.json          # Main config with agent definitions
├── agent/                 # Agent markdown definitions
│   ├── primary/
│   │   ├── plan.md
│   │   ├── implement.md
│   │   ├── debug.md
│   │   ├── refactor.md
│   │   └── research.md
│   └── subagents/
│       ├── planning/
│       │   ├── architect.md
│       │   ├── spec-writer.md
│       │   └── ...
│       ├── implementation/
│       │   ├── code-generator.md
│       │   ├── integrator.md
│       │   └── ...
│       └── ...
└── prompts/              # Shared prompt templates
    ├── planning.txt
    ├── implementation.txt
    └── ...
```

## Success Metrics
- Reduced time from planning to implementation
- Fewer bugs introduced during development
- Consistent documentation quality
- Improved code review efficiency
- Better test coverage
- Faster debugging cycles

## Next Steps
1. Review and refine this plan
2. Create the agent configuration files
3. Test with simple workflows
4. Iterate based on usage patterns
5. Document best practices