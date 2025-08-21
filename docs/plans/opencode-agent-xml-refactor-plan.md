# OpenCode Plan Agent XML Refactor Plan

## Executive Summary

### Problem Statement
The OpenCode plan agent currently uses a markdown-based structure that lacks the clarity and precision needed for reliable AI interpretation. The agent frequently fails to output required plan documents despite multiple emphatic instructions, indicating that the current markdown format may be ambiguous for agentic AI parsing.

### Proposed Solution
Refactor the plan agent from markdown format to XML-structured format using semantic XML tags to clearly delineate different sections, instructions, and execution requirements. This approach follows Anthropic's best practices for agentic AI prompting, providing clear boundaries between context, instructions, and examples.

### Expected Benefits
- **Improved Reliability**: XML tags provide unambiguous structure for AI interpretation
- **Enhanced Clarity**: Clear separation of different prompt components reduces confusion
- **Better Execution**: Explicit `<execution>` and `<critical_output>` sections ensure consistent behavior
- **Easier Maintenance**: Modular XML structure allows targeted updates without rewriting
- **Reduced Failures**: Structured approach should eliminate plan document output failures

## Current State Analysis

### Current Markdown Structure Weaknesses
1. **Ambiguous Boundaries**: Markdown headers don't clearly separate instructions from context
2. **Mixed Content Types**: Instructions, examples, and context are interwoven without clear delimiters
3. **Buried Critical Instructions**: Key requirements like "MUST output plan document" are embedded in long paragraphs
4. **Repetitive Emphasis**: Multiple attempts to stress requirements suggest parsing issues
5. **Sequential Processing**: Current structure doesn't clearly indicate parallel execution requirements

### Identified Failure Patterns
Based on the current agent definition (lines 253-278), common failure modes include:
- Agent describes plans without creating files
- Responses without confirming file existence
- Forgetting to report file location to users
- Creating plans in wrong locations
- Missing the @documenter delegation step

### Current Success Patterns to Preserve
- Comprehensive delegation strategy (80% minimum)
- Parallel execution with batching
- Quality gates and validation
- Progress monitoring and recovery mechanisms
- Structured orchestration patterns

## Proposed XML Structure

### Recommended XML Tag Hierarchy

#### Primary Container Tags
```xml
<agent_definition>
  <configuration>
    <!-- YAML frontmatter - preserved unchanged -->
  </configuration>
  
  <role>
    <!-- Core agent identity and purpose -->
  </role>
  
  <execution>
    <!-- Critical execution workflow -->
    <workflow>
      <!-- Step-by-step process -->
    </workflow>
    <critical_requirements>
      <!-- Non-negotiable behaviors -->
    </critical_requirements>
  </execution>
  
  <delegation>
    <!-- Subagent orchestration patterns -->
  </delegation>
  
  <quality_standards>
    <!-- Quality gates and validation -->
  </quality_standards>
  
  <monitoring>
    <!-- Progress tracking and recovery -->
  </monitoring>
  
  <examples>
    <!-- Concrete implementation examples -->
  </examples>
</agent_definition>
```

#### Secondary Support Tags
```xml
<batch_operations>
  <!-- Parallel execution patterns -->
</batch_operations>

<convergence_points>
  <!-- Synchronization requirements -->
</convergence_points>

<recovery_strategies>
  <!-- Error handling and fallback -->
</recovery_strategies>

<performance_targets>
  <!-- Specific metrics and goals -->
</performance_targets>
```

### Tag Naming Conventions
- Use semantic, descriptive names (not generic like `<section1>`)
- Maintain consistency across similar concepts
- Use nested tags for hierarchical relationships
- Employ clear action-oriented tags (`<execute>`, `<validate>`, `<monitor>`)

## Detailed Refactoring Plan

### Phase 1: Core Structure Transformation

#### Task 1.1: Create XML Framework
- [ ] Preserve YAML frontmatter (lines 1-18) unchanged
- [ ] Wrap main content in `<agent_definition>` root tag
- [ ] Create primary container tags (`<role>`, `<execution>`, `<delegation>`, etc.)
- [ ] Define semantic tag hierarchy
- **Acceptance Criteria**: Valid XML structure with clear hierarchy
- **Test Requirements**: Validate XML syntax and semantic meaning

#### Task 1.2: Restructure Core Responsibilities
- [ ] Move core responsibilities (lines 22-28) into `<role><responsibilities>` tags
- [ ] Separate identity from specific tasks
- [ ] Add clear role definition
- **Acceptance Criteria**: Role clearly defined with specific responsibilities
- **Test Requirements**: Verify role clarity and completeness

#### Task 1.3: Transform Planning Methodology
- [ ] Convert planning methodology (lines 30-76) to `<execution><workflow>` structure
- [ ] Use nested tags for workflow steps
- [ ] Separate instructions from examples
- **Acceptance Criteria**: Clear workflow with sequential steps
- **Test Requirements**: Workflow completeness and logical order

### Phase 2: Execution Instructions (CRITICAL)

#### Task 2.1: Create Explicit Execution Section
- [ ] Create dedicated `<execution>` section at the top level
- [ ] Move critical output requirements (lines 253-278) to `<critical_requirements>` 
- [ ] Add explicit workflow steps with `<workflow><step>` tags
- [ ] Include self-task-creation instructions
- **Acceptance Criteria**: Execution section contains ALL critical requirements
- **Test Requirements**: No critical instruction should be missed

#### Task 2.2: Define Mandatory Workflow
```xml
<execution>
  <workflow>
    <step id="1">
      <action>Use task tool to create comprehensive task list</action>
      <details>Self-generate tasks for: gather information → check existing code → understand user needs → refine idea → create plan → use @documenter → use @reviewer</details>
    </step>
    <step id="2">
      <action>Gather information using parallel batch operations</action>
      <requirements>ALWAYS batch read operations, NEVER sequential</requirements>
    </step>
    <!-- Additional steps... -->
  </workflow>
  
  <critical_requirements>
    <requirement priority="highest">
      <description>MUST create plan document using @documenter</description>
      <verification>Confirm file exists at docs/plans/[topic]-plan.md before responding</verification>
    </requirement>
    <requirement priority="highest">
      <description>MUST delegate minimum 80% of work to subagents</description>
      <verification>Track delegation percentage throughout execution</verification>
    </requirement>
  </critical_requirements>
</execution>
```

#### Task 2.3: Add Self-Task Creation
- [ ] Add explicit instructions for agent to create its own task list
- [ ] Define standard task template
- [ ] Specify required task categories
- **Acceptance Criteria**: Agent creates comprehensive task list as first action
- **Test Requirements**: Verify task creation occurs before other work

### Phase 3: Delegation Patterns

#### Task 3.1: Structure Delegation Strategy
- [ ] Convert delegation section (lines 162-232) to `<delegation>` structure
- [ ] Use clear tags for parallel vs sequential delegation
- [ ] Separate delegation patterns from monitoring
- **Acceptance Criteria**: Clear delegation hierarchy with success criteria
- **Test Requirements**: Verify delegation patterns are actionable

#### Task 3.2: Define Parallel Execution Patterns
```xml
<delegation>
  <parallel_streams>
    <stream id="analysis" type="non_overlapping">
      <agents>@tracer, @analyzer</agents>
      <tasks>project_structure, dependencies, patterns</tasks>
      <timeout>600</timeout>
      <success_criteria>Structure analysis report completed</success_criteria>
    </stream>
    <stream id="research" type="non_overlapping">
      <agents>@researcher, @synthesizer</agents>
      <tasks>best_practices, documentation, technology_stack</tasks>
      <timeout>600</timeout>
      <success_criteria>Research findings document completed</success_criteria>
    </stream>
  </parallel_streams>
  
  <convergence_points>
    <point name="initial_analysis">
      <required_streams>analysis, research</required_streams>
      <action>synthesize_findings</action>
      <timeout>300</timeout>
    </point>
  </convergence_points>
</delegation>
```

#### Task 3.3: Add Success Criteria Tags
- [ ] Add `<success_criteria>` tags for each delegation
- [ ] Define measurable outcomes
- [ ] Specify timeout requirements
- **Acceptance Criteria**: All delegations have clear success criteria
- **Test Requirements**: Verify criteria are measurable and achievable

### Phase 4: Quality Requirements

#### Task 4.1: Structure Quality Standards
- [ ] Move quality standards (lines 234-241) to `<quality_standards>` section
- [ ] Add specific quality gates
- [ ] Define validation requirements
- **Acceptance Criteria**: Quality standards are clear and measurable
- **Test Requirements**: Verify standards can be automatically validated

#### Task 4.2: Add Critical Output Section
```xml
<critical_output>
  <mandatory_actions>
    <action order="1">Create plan document via @documenter</action>
    <action order="2">Verify file exists using @reviewer</action>
    <action order="3">Report file location to user</action>
  </mandatory_actions>
  
  <failure_prevention>
    <anti_pattern>NEVER describe plans without creating files</anti_pattern>
    <anti_pattern>NEVER respond without confirming file exists</anti_pattern>
    <anti_pattern>NEVER create plans outside docs/plans/</anti_pattern>
  </failure_prevention>
  
  <success_pattern>
    <step>Gather requirements and research</step>
    <step>Create plan document via @documenter</step>
    <step>Verify file exists via @reviewer</step>
    <step>Report: "✅ Plan created at: docs/plans/[topic]-plan.md"</step>
  </success_pattern>
</critical_output>
```

## Implementation Strategy

### Phase 1: Core Structure (Week 1)
- Day 1-2: XML framework setup and validation
- Day 3-4: Role and responsibilities restructuring  
- Day 5-7: Basic workflow transformation and testing

### Phase 2: Execution Instructions (Week 1-2)
- Day 6-8: Critical execution section creation
- Day 9-10: Workflow definition and validation
- Day 11-12: Self-task creation integration

### Phase 3: Delegation Patterns (Week 2)
- Day 10-12: Delegation structure transformation
- Day 13-14: Parallel execution pattern definition
- Day 15: Success criteria and timeout specification

### Phase 4: Quality Requirements (Week 2)
- Day 13-15: Quality standards structuring
- Day 16: Critical output section completion
- Day 17: Final integration and validation

## XML Tag Schema

### Primary Tags
```xml
<agent_definition>          <!-- Root container -->
  <configuration>           <!-- YAML frontmatter -->
  <role>                    <!-- Agent identity and purpose -->
    <identity>              <!-- Who the agent is -->
    <responsibilities>      <!-- What the agent does -->
    <constraints>           <!-- What the agent must/must not do -->
  </role>
  
  <execution>               <!-- How the agent works -->
    <workflow>              <!-- Step-by-step process -->
      <step id="N">         <!-- Individual workflow step -->
        <action>            <!-- What to do -->
        <requirements>      <!-- How to do it -->
        <validation>        <!-- How to verify success -->
      </step>
    </workflow>
    <critical_requirements> <!-- Non-negotiable behaviors -->
      <requirement priority="high|medium|low">
        <description>       <!-- What is required -->
        <verification>      <!-- How to verify compliance -->
      </requirement>
    </critical_requirements>
  </execution>
</agent_definition>
```

### Secondary Tags
```xml
<delegation>                <!-- Subagent orchestration -->
  <parallel_streams>        <!-- Parallel execution patterns -->
    <stream id="name">      <!-- Individual execution stream -->
      <agents>              <!-- Which subagents to use -->
      <tasks>               <!-- What tasks to delegate -->
      <success_criteria>    <!-- How to measure success -->
      <timeout>             <!-- Time limits -->
    </stream>
  </parallel_streams>
  
  <convergence_points>      <!-- Synchronization points -->
    <point name="name">     <!-- Individual convergence point -->
      <required_streams>    <!-- Which streams must complete -->
      <action>              <!-- What to do at convergence -->
    </point>
  </convergence_points>
</delegation>

<quality_standards>         <!-- Quality requirements -->
  <standards>               <!-- Specific quality criteria -->
  <validation>              <!-- How to validate quality -->
</quality_standards>

<monitoring>                <!-- Progress and recovery -->
  <checkpoints>             <!-- Progress monitoring points -->
  <recovery_strategies>     <!-- How to handle failures -->
</monitoring>
```

### Nested Tag Patterns
```xml
<batch_operations>
  <file_operations>
    <pattern type="good">read_batch([file1, file2, file3])</pattern>
    <pattern type="bad">read(file1); read(file2); read(file3)</pattern>
  </file_operations>
</batch_operations>

<examples>
  <scenario name="parallel_planning">
    <description>Planning a new authentication system</description>
    <implementation>
      <!-- Concrete example with XML structure -->
    </implementation>
    <expected_outcome>Sequential: 45 min → Parallel: 15 min (67% reduction)</expected_outcome>
  </scenario>
</examples>
```

## Testing & Validation

### Success Criteria
1. **XML Validity**: Document passes XML validation
2. **Semantic Clarity**: Each tag has clear, unambiguous meaning
3. **Execution Reliability**: Agent consistently creates plan documents
4. **Performance Maintained**: Parallel execution and delegation patterns preserved
5. **User Experience**: Clear workflow from user request to plan delivery

### Test Cases

#### Test Case 1: Basic Plan Creation
- **Input**: "Create a plan for implementing user authentication"
- **Expected**: Agent creates task list, delegates research, creates plan document
- **Success**: Plan file exists at `docs/plans/user-authentication-plan.md`
- **Failure Modes**: No file created, wrong location, incomplete content

#### Test Case 2: Complex Multi-Phase Planning
- **Input**: "Plan a complete system migration from Django to FastAPI"
- **Expected**: Parallel streams for analysis, research, design
- **Success**: Plan with multiple phases, clear dependencies, timeline
- **Failure Modes**: Sequential execution, missing phases, unclear dependencies

#### Test Case 3: Error Recovery
- **Input**: Plan request with incomplete context
- **Expected**: Agent asks for clarification, still creates plan with assumptions
- **Success**: Plan created with clear assumption statements
- **Failure Modes**: Agent fails to create plan, gets stuck in analysis

### Validation Methods
1. **XML Schema Validation**: Ensure syntactic correctness
2. **Semantic Review**: Verify each tag serves clear purpose
3. **Behavioral Testing**: Test actual agent execution with refactored format
4. **Performance Comparison**: Measure before/after reliability metrics
5. **User Acceptance**: Gather feedback on plan quality and consistency

### Rollback Plan
If refactored agent performs worse than current version:
1. **Immediate**: Revert to current markdown version
2. **Analysis**: Identify specific failure points in XML structure
3. **Iteration**: Address issues with targeted XML improvements
4. **Gradual Migration**: Test individual sections before full deployment

## Example Refactored Sections

### Complete Example: Execution Instructions Section
```xml
<execution>
  <workflow>
    <step id="1" phase="initialization">
      <action>Create comprehensive task list using task tool</action>
      <details>
        Self-generate tasks following this sequence:
        1. Gather information (batch read operations)
        2. Check existing code patterns  
        3. Understand user requirements
        4. Refine implementation approach
        5. Create structured plan
        6. Use @documenter to output plan file (CRITICAL)
        7. Use @reviewer to verify deliverables
      </details>
      <requirements>
        <requirement>Tasks must be created before any other work begins</requirement>
        <requirement>Each task must have clear acceptance criteria</requirement>
      </requirements>
    </step>
    
    <step id="2" phase="information_gathering">
      <action>Execute parallel batch operations for information gathering</action>
      <batch_operations>
        <operation type="read">
          <files>["package.json", "requirements.txt", "go.mod", "README.md", "docs/*.md"]</files>
          <execution>parallel</execution>
        </operation>
        <operation type="search">
          <patterns>["**/*.config.*", "**/test*/**", "TODO|FIXME|HACK", "deprecated|legacy"]</patterns>
          <execution>parallel</execution>
        </operation>
      </batch_operations>
      <requirements>
        <requirement>NEVER execute operations sequentially when they can be batched</requirement>
        <requirement>ALWAYS use batch operations for file access</requirement>
      </requirements>
    </step>
    
    <step id="3" phase="analysis_and_design">
      <action>Delegate analysis and design work to specialized subagents</action>
      <delegation>
        <parallel_streams>
          <stream id="analysis">
            <agents>@tracer, @analyzer</agents>
            <tasks>Map dependencies, identify patterns, analyze constraints</tasks>
            <success_criteria>Complete dependency graph and pattern analysis</success_criteria>
            <timeout>600</timeout>
          </stream>
          <stream id="research">
            <agents>@researcher, @synthesizer</agents>
            <tasks>External best practices, similar implementations, technology evaluation</tasks>
            <success_criteria>Comprehensive research document with recommendations</success_criteria>
            <timeout>600</timeout>
          </stream>
        </parallel_streams>
      </delegation>
    </step>
    
    <step id="4" phase="plan_creation">
      <action>Create plan document using @documenter</action>
      <critical_requirements>
        <requirement priority="highest">
          <description>MUST use @documenter to create plan file</description>
          <location>docs/plans/[topic]-plan.md</location>
          <verification>Verify file exists before proceeding</verification>
        </requirement>
      </critical_requirements>
    </step>
    
    <step id="5" phase="validation">
      <action>Verify deliverables using @reviewer</action>
      <validation>
        <check>Plan file exists at correct location</check>
        <check>All required sections are present</check>
        <check>Quality standards are met</check>
      </validation>
    </step>
    
    <step id="6" phase="completion">
      <action>Report plan location to user</action>
      <format>✅ Plan created at: docs/plans/[topic]-plan.md</format>
      <requirements>
        <requirement>NEVER respond without confirming file exists</requirement>
        <requirement>ALWAYS provide exact file path</requirement>
      </requirements>
    </step>
  </workflow>
  
  <critical_requirements>
    <requirement priority="highest">
      <description>MUST create plan document - NO EXCEPTIONS</description>
      <enforcement>
        <rule>NEVER describe plans without creating files</rule>
        <rule>NEVER respond without confirming file exists</rule>
        <rule>NEVER create plans outside docs/plans/ directory</rule>
      </enforcement>
      <verification>
        <step>Use @documenter to create file</step>
        <step>Use @reviewer to verify file exists</step>
        <step>Report exact file path to user</step>
      </verification>
    </requirement>
    
    <requirement priority="high">
      <description>MUST delegate minimum 80% of work to subagents</description>
      <measurement>Track delegation percentage throughout execution</measurement>
      <verification>Document delegation strategy in plan</verification>
    </requirement>
  </critical_requirements>
  
  <failure_prevention>
    <anti_patterns>
      <pattern>❌ NEVER just describe what you would plan without creating the file</pattern>
      <pattern>❌ NEVER respond without confirming the file exists</pattern>
      <pattern>❌ NEVER forget to report the file location to the user</pattern>
      <pattern>❌ NEVER create plans in any location other than docs/plans/</pattern>
    </anti_patterns>
    
    <recovery_protocol>
      <condition>If plan document creation fails</condition>
      <actions>
        <action>DO NOT respond to the user</action>
        <action>Retry with @documenter</action>
        <action>If still failing, use @guardian to resolve</action>
        <action>Only respond when file is confirmed to exist</action>
      </actions>
    </recovery_protocol>
  </failure_prevention>
</execution>
```

### Example: Delegation Strategy in XML
```xml
<delegation>
  <orchestration_rules>
    <rule>Delegate minimum 80% of work to specialized subagents</rule>
    <rule>Retain only high-level coordination and convergence management</rule>
    <rule>Execute delegated work in parallel streams where possible</rule>
  </orchestration_rules>
  
  <parallel_delegation_patterns>
    <batch id="1" name="discovery" execution="parallel">
      <delegation>
        <agent>@researcher</agent>
        <task>External research and best practices</task>
        <success_criteria>5+ relevant sources found</success_criteria>
        <timeout>300</timeout>
      </delegation>
      <delegation>
        <agent>@tracer</agent>
        <task>Map dependencies and requirements</task>
        <success_criteria>Complete dependency graph created</success_criteria>
        <timeout>300</timeout>
      </delegation>
      <delegation>
        <agent>@synthesizer</agent>
        <task>Structure initial content</task>
        <success_criteria>Outline with all sections defined</success_criteria>
        <timeout>300</timeout>
      </delegation>
    </batch>
    
    <batch id="2" name="design" execution="parallel" depends_on="1">
      <delegation>
        <agent>@architect</agent>
        <task>System design if needed</task>
        <success_criteria>Architecture diagrams and interfaces defined</success_criteria>
        <timeout>600</timeout>
      </delegation>
      <delegation>
        <agent>@validator</agent>
        <task>Check feasibility</task>
        <success_criteria>All risks identified with mitigations</success_criteria>
        <timeout>300</timeout>
      </delegation>
    </batch>
    
    <batch id="3" name="documentation" execution="parallel" depends_on="2">
      <delegation>
        <agent>@documenter</agent>
        <task>Create docs/plans/[topic]-plan.md</task>
        <success_criteria>Complete plan document created</success_criteria>
        <timeout>300</timeout>
      </delegation>
      <delegation>
        <agent>@formatter</agent>
        <task>Clean structure and format</task>
        <success_criteria>Consistent formatting applied</success_criteria>
        <timeout>120</timeout>
      </delegation>
    </batch>
    
    <batch id="4" name="quality" execution="sequential" depends_on="3">
      <delegation>
        <agent>@reviewer</agent>
        <task>Verify completeness and quality</task>
        <success_criteria>All requirements addressed</success_criteria>
        <timeout>180</timeout>
      </delegation>
    </batch>
  </parallel_delegation_patterns>
  
  <monitoring>
    <checkpoints>
      <checkpoint interval="300">Check subagent progress every 5 minutes</checkpoint>
      <checkpoint condition="timeout">If timeout exceeded: invoke @guardian for recovery</checkpoint>
      <checkpoint condition="failure">If success criteria not met: refine and retry (max 2 attempts)</checkpoint>
    </checkpoints>
    <recovery>
      <strategy>Document all delegation outcomes in plan</strategy>
    </recovery>
  </monitoring>
</delegation>
```

### Example: Critical Output Requirements
```xml
<critical_output>
  <mandatory_workflow>
    <phase name="preparation">
      <step>Create comprehensive task list using task tool</step>
      <step>Gather information using parallel batch operations</step>
      <step>Understand user requirements through clarifying questions if needed</step>
    </phase>
    
    <phase name="execution">
      <step>Delegate research and analysis to subagents in parallel</step>
      <step>Monitor progress and coordinate convergence points</step>
      <step>Synthesize findings into structured plan content</step>
    </phase>
    
    <phase name="output" criticality="highest">
      <step priority="critical">Use @documenter to create plan file at docs/plans/[topic]-plan.md</step>
      <step priority="critical">Use @reviewer to verify file exists and is complete</step>
      <step priority="critical">Report exact file location to user: "✅ Plan created at: docs/plans/[topic]-plan.md"</step>
    </phase>
  </mandatory_workflow>
  
  <verification_gates>
    <gate id="pre_response">
      <description>Before responding to user</description>
      <checks>
        <check>VERIFY the plan file exists at docs/plans/[topic]-plan.md</check>
        <check>CONFIRM it contains all required sections</check>
        <check>PREPARE exact path report for user</check>
      </checks>
    </gate>
  </verification_gates>
  
  <failure_modes>
    <mode name="no_file_created">
      <description>Plan described but no file created</description>
      <prevention>ALWAYS use @documenter, NEVER just describe</prevention>
      <recovery>Retry with @documenter before responding</recovery>
    </mode>
    <mode name="wrong_location">
      <description>Plan created in wrong directory</description>
      <prevention>ALWAYS use docs/plans/ directory</prevention>
      <recovery>Move file to correct location</recovery>
    </mode>
    <mode name="missing_confirmation">
      <description>Response without file existence confirmation</description>
      <prevention>ALWAYS verify file exists before responding</prevention>
      <recovery>Check file existence and report location</recovery>
    </mode>
  </failure_modes>
  
  <success_indicators>
    <indicator>✅ Plan document exists at docs/plans/[topic]-plan.md</indicator>
    <indicator>✅ User receives exact file path confirmation</indicator>
    <indicator>✅ Plan contains all required sections and detail</indicator>
    <indicator>✅ 80%+ of work was delegated to subagents</indicator>
    <indicator>✅ Parallel execution was used for independent tasks</indicator>
  </success_indicators>
</critical_output>
```

## Best Practices Integration

### Maintaining Consistency
1. **Tag Naming**: Use consistent, semantic tag names throughout
2. **Hierarchy**: Maintain logical nesting relationships
3. **Attributes**: Use attributes for metadata, content for instructions
4. **Documentation**: Comment complex tag structures for maintainability

### Future Extensibility Considerations
1. **Modular Design**: Each section can be updated independently
2. **Version Control**: XML structure allows tracking of specific changes
3. **Schema Evolution**: New tags can be added without breaking existing structure
4. **Tool Integration**: XML format enables automated validation and processing

### Documentation Standards
1. **Tag Documentation**: Each tag should have clear purpose and usage
2. **Example Library**: Maintain examples for each major tag pattern
3. **Schema Reference**: Formal schema definition for validation
4. **Migration Guide**: Instructions for updating agent definitions

## Migration Checklist

### Pre-Migration Backup
- [ ] Create backup of current plan.md agent file
- [ ] Document current agent behavior baseline
- [ ] Save example outputs from current agent
- [ ] Note any known issues or workarounds

### Step-by-Step Migration Tasks

#### Week 1: Structure Creation
- [ ] Create XML framework with root `<agent_definition>` tag
- [ ] Preserve YAML frontmatter unchanged
- [ ] Create primary container tags (`<role>`, `<execution>`, `<delegation>`)
- [ ] Validate XML syntax
- [ ] Test basic agent loading

#### Week 1-2: Critical Execution
- [ ] Move critical output requirements to `<execution><critical_requirements>`
- [ ] Create explicit workflow steps with `<workflow><step>` tags
- [ ] Add self-task creation instructions
- [ ] Define mandatory action sequences
- [ ] Test execution reliability

#### Week 2: Delegation and Quality
- [ ] Convert delegation patterns to structured `<delegation>` section
- [ ] Add parallel execution patterns with proper tags
- [ ] Define convergence points and success criteria
- [ ] Structure quality standards and validation
- [ ] Test delegation behavior

#### Week 2: Examples and Documentation
- [ ] Convert examples to structured `<examples><scenario>` format
- [ ] Add concrete XML-based examples
- [ ] Update documentation with new structure
- [ ] Create migration documentation

### Post-Migration Validation

#### Functional Testing
- [ ] Test basic plan creation (simple request)
- [ ] Test complex multi-phase planning
- [ ] Test error handling and recovery
- [ ] Test parallel execution behavior
- [ ] Test delegation to subagents

#### Performance Validation
- [ ] Measure plan creation success rate
- [ ] Compare execution time vs baseline
- [ ] Validate delegation percentage
- [ ] Check quality of generated plans
- [ ] Monitor user satisfaction

#### Quality Assurance
- [ ] XML schema validation passes
- [ ] All critical requirements preserved
- [ ] No regression in plan quality
- [ ] Parallel execution maintained
- [ ] Error recovery functions correctly

### Success Metrics
1. **Plan Creation Success Rate**: >95% (vs current rate)
2. **File Location Accuracy**: 100% (plans in docs/plans/)
3. **User Reporting**: 100% (exact path always provided)
4. **Delegation Percentage**: ≥80% (maintained from current)
5. **Execution Time**: ≤ current baseline (no performance loss)

### Rollback Triggers
- Plan creation success rate drops below 90%
- Agent fails to create files consistently  
- Performance significantly degraded
- XML parsing errors prevent agent loading
- User experience notably worse than baseline

This comprehensive plan provides a structured approach to refactoring the OpenCode plan agent from markdown to XML format, with clear phases, specific tasks, and detailed examples to ensure reliable execution and improved AI interpretation.

## Dev Log

### 2025-08-17 - Initial Plan Creation

#### Task 1.1: Problem Analysis and Research
**Status**: Completed ✓
- **Actions Taken**: 
  - Analyzed current plan agent structure (280 lines of markdown)
  - Identified failure patterns: no file creation, wrong locations, missing confirmations
  - Researched Anthropic XML best practices for agentic AI
  - Reviewed similar agent structures (implement.md, research.md)
- **Key Findings**:
  - Current markdown structure mixes instructions with context
  - Critical requirements (lines 253-278) are buried in large sections
  - Agent frequently fails despite emphatic instructions
  - XML tags provide clear boundaries for AI interpretation
- **Next Steps**: Begin XML structure design

#### Task 1.2: XML Structure Design
**Status**: Completed ✓
- **Actions Taken**:
  - Designed hierarchical XML tag schema
  - Created primary container tags: role, execution, delegation, quality_standards
  - Defined semantic naming conventions
  - Planned nested tag patterns for complex workflows
- **Deliverables**:
  - Complete XML tag hierarchy
  - Tag naming conventions
  - Schema documentation
- **Next Steps**: Create detailed refactoring implementation plan