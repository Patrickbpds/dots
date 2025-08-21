# Primary Agents XML Conversion Plan

## Context

### Problem Statement
Currently, only the plan agent successfully implements the XML delegation structure with proper 80% delegation enforcement, mandatory task tool usage, and clear visual separation. The remaining primary agents (implement, research, debug, test, blueprint) use inconsistent delegation patterns with varying levels of XML structure adoption, resulting in suboptimal delegation rates and inconsistent user experience.

### Current State
- **plan agent**: Fully XML-compliant with 80% delegation, task tool first action, and complete DELEGATE_TO sections
- **implement agent**: Partial delegation structure, lacks XML formatting, no task tool requirement
- **research agent**: Basic delegation mentions, no XML structure, minimal enforcement
- **debug agent**: Some delegation awareness, no XML formatting, inconsistent patterns  
- **test agent**: Delegation guidelines present, lacks XML structure and enforcement
- **blueprint agent**: Basic delegation structure, no XML formatting or strict enforcement

### Goals
- Convert all primary agents to use the proven XML delegation structure from plan agent
- Enforce minimum 80% delegation across all agents
- Ensure consistent task tool usage as mandatory first action
- Implement uniform visual separation and documentation standards
- Maintain agent-specific functionality while standardizing orchestration patterns

### Constraints
- Must preserve existing agent functionality and tool permissions
- Cannot break current workflows during transition
- Must maintain agent-specific delegation patterns and timeouts
- XML structure must be adapted to each agent's specific workflow requirements

## Specification

### Functional Requirements

#### FR1: XML Structure Consistency
All primary agents must implement the XML delegation structure with:
- `<agent_definition>` root element containing role, execution, and delegation sections
- `<immediate_first_action>` with mandatory task tool requirement
- `<workflow>` with numbered steps and clear delegation phases
- `<DELEGATE_TO>` sections with specific subagent assignments
- `<critical_requirements>` for 80% delegation enforcement

#### FR2: Delegation Enforcement
Each agent must achieve and maintain:
- Minimum 80% delegation of all work to subagents
- Clear orchestration-only responsibilities (20% retained)
- Prohibited direct actions explicitly documented
- Success criteria defined for all delegated tasks

#### FR3: Visual Consistency
All agents must use consistent visual elements:
- ═══ dividers to separate major sections
- 🎯 icons for orchestration tasks (agent responsibilities)
- 📋 icons for delegation tasks (subagent responsibilities)
- Consistent typography and structure formatting

#### FR4: Task Tool Mandate
Every primary agent must:
- Use task tool as absolute first action
- Create delegation-focused task breakdown structure
- Define 80%/20% split in task creation
- Document task completion tracking

### Non-Functional Requirements

#### NFR1: Performance
- XML structure must not impact execution speed
- Delegation patterns must achieve 40-70% time reduction targets
- Parallel stream coordination must maintain efficiency

#### NFR2: Maintainability  
- XML template must be reusable across agents with minimal customization
- Agent-specific patterns must be clearly documented
- Version control compatibility for all changes

#### NFR3: Validation
- Automated validation of 80% delegation compliance
- Clear pass/fail criteria for conversion acceptance
- Rollback capability if conversion fails

### Interfaces

#### Agent Configuration Interface
```yaml
agent:
  mode: primary
  delegation:
    minimum_percentage: 80
    orchestration_only: true
    task_tool_mandatory: true
  xml_structure:
    enabled: true
    template: "common_xml_template"
  visual:
    dividers: "═══"
    orchestration_icon: "🎯"
    delegation_icon: "📋"
```

## Implementation Plan

### Phase 1: Template Development and Validation

#### Task 1.1: Create Common XML Template
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - [ ] XML template based on successful plan.md structure created
  - [ ] Template includes all required sections with placeholders
  - [ ] Agent-specific customization points documented
  - [ ] Template validates against XML schema requirements
- **Deliverables**: `/templates/common-xml-delegation-template.xml`

#### Task 1.2: Define Agent-Specific Adaptations
- **Duration**: 3 hours  
- **Acceptance Criteria**:
  - [ ] Implement agent workflow patterns documented (sequential code, parallel validation)
  - [ ] Research agent parallel stream requirements mapped
  - [ ] Debug agent rapid iteration patterns (3-min checkpoints) defined
  - [ ] Test agent quality enforcement patterns specified
  - [ ] Blueprint agent pattern analysis requirements documented
- **Deliverables**: `/docs/agent-specific-xml-adaptations.md`

#### Task 1.3: Create Validation Framework
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - [ ] 80% delegation validation script created
  - [ ] XML structure compliance checker implemented  
  - [ ] Task tool usage validator developed
  - [ ] Visual consistency checker built
- **Deliverables**: `/validation/xml-delegation-validator.py`

**Test Requirements**:
- Template generates valid agent configurations
- Validation framework catches non-compliance accurately
- Agent-specific adaptations preserve functionality

---

### Phase 2: Individual Agent Conversions

#### Task 2.1: Convert implement.md
- **Duration**: 4 hours
- **Delegation Target**: 85% (highest complexity due to sequential/parallel hybrid)
- **Acceptance Criteria**:
  - [ ] XML structure implemented with all required sections
  - [ ] Task tool as mandatory first action configured
  - [ ] Sequential-parallel delegation pattern preserved
  - [ ] Dev log updating delegation maintained
  - [ ] Plan document orchestration retained
  - [ ] 80%+ delegation validated
  - [ ] Visual consistency (═══, 🎯, 📋) implemented
- **Specific Changes**:
  - Wrap existing content in XML structure
  - Add `<immediate_first_action>` with task tool requirement
  - Convert workflow steps to numbered XML steps with DELEGATE_TO
  - Add prohibited direct actions list
  - Implement 80% delegation enforcement constraints
- **Deliverables**: Updated `/ai/.config/opencode/agent/implement.md`

#### Task 2.2: Convert research.md  
- **Duration**: 3 hours
- **Delegation Target**: 82% (parallel research streams)
- **Acceptance Criteria**:
  - [ ] XML structure with parallel delegation patterns implemented
  - [ ] Batch operations preserved and enhanced
  - [ ] Research output documentation delegation enforced
  - [ ] External research and codebase analysis streams defined
  - [ ] 80%+ delegation validated with monitoring checkpoints
- **Specific Changes**:
  - Implement XML workflow with 3 parallel streams (discovery, analysis, knowledge)
  - Add DELEGATE_TO sections for @researcher, @tracer, @synthesizer
  - Convert batch operations examples to XML-compliant delegation
  - Add docs/research/ output requirement enforcement
- **Deliverables**: Updated `/ai/.config/opencode/agent/research.md`

#### Task 2.3: Convert debug.md
- **Duration**: 3 hours  
- **Delegation Target**: 83% (fast parallel hypothesis testing)
- **Acceptance Criteria**:
  - [ ] XML structure with rapid iteration patterns (3-min checkpoints)
  - [ ] Parallel hypothesis testing delegation preserved
  - [ ] Debug report creation delegation enforced
  - [ ] Fast timeout handling maintained
  - [ ] 80%+ delegation validated
- **Specific Changes**:
  - Implement XML with 4 parallel streams (diagnostic, hypothesis, logs, fix)
  - Add accelerated checkpoint intervals for debug workflows
  - Convert investigation processes to DELEGATE_TO patterns
  - Enforce docs/debug/ output delegation
- **Deliverables**: Updated `/ai/.config/opencode/agent/debug.md`

#### Task 2.4: Convert test.md
- **Duration**: 4 hours
- **Delegation Target**: 84% (comprehensive quality enforcement)
- **Acceptance Criteria**:
  - [ ] XML structure with quality gate enforcement implemented
  - [ ] No placeholder test prohibition maintained
  - [ ] Test generation and validation delegation patterns defined
  - [ ] Module-based parallel testing preserved
  - [ ] 80%+ delegation with test quality gates validated
- **Specific Changes**:
  - Implement XML with parallel test generation streams
  - Add strict quality enforcement delegation to @test-validator
  - Convert anti-pattern prevention to XML prohibited actions
  - Enforce docs/tests/ report delegation
- **Deliverables**: Updated `/ai/.config/opencode/agent/test.md`

#### Task 2.5: Convert blueprint.md
- **Duration**: 3 hours
- **Delegation Target**: 81% (pattern analysis and template creation)  
- **Acceptance Criteria**:
  - [ ] XML structure with pattern analysis delegation implemented
  - [ ] Template creation and validation streams defined
  - [ ] Blueprint documentation delegation enforced
  - [ ] Pattern discovery processes converted to DELEGATE_TO
  - [ ] 80%+ delegation validated
- **Specific Changes**:
  - Implement XML with 3 parallel streams (pattern, template, validation)
  - Convert pattern analysis to delegated discovery processes
  - Add DELEGATE_TO for @tracer, @executor, @documenter coordination
  - Enforce docs/blueprints/ output delegation
- **Deliverables**: Updated `/ai/.config/opencode/agent/blueprint.md`

**Test Requirements**:
- Each converted agent passes 80% delegation validation
- Task tool usage works as first action for all agents
- Agent-specific workflows remain functional
- All agents create proper documentation in their subdirectories

---

### Phase 3: Integration Testing and Validation

#### Task 3.1: Comprehensive Delegation Testing
- **Duration**: 2 hours
- **Acceptance Criteria**:
  - [ ] All 5 converted agents pass 80% delegation validation
  - [ ] Task tool first action verified for all agents
  - [ ] XML structure compliance confirmed
  - [ ] Visual consistency validated across all agents
- **Test Requirements**:
  - Automated validation suite runs against all agents
  - Manual testing of delegation workflows
  - Performance impact assessment

#### Task 3.2: Cross-Agent Consistency Validation  
- **Duration**: 1 hour
- **Acceptance Criteria**:
  - [ ] Consistent XML structure across all agents verified
  - [ ] Common delegation patterns work uniformly
  - [ ] Visual elements (═══, 🎯, 📋) consistently applied
  - [ ] Documentation standards met across all outputs
- **Test Requirements**:
  - Cross-agent structure comparison
  - Documentation output format validation

#### Task 3.3: Performance and Functionality Testing
- **Duration**: 2 hours  
- **Acceptance Criteria**:
  - [ ] No performance degradation from XML structure
  - [ ] All existing functionality preserved
  - [ ] Delegation efficiency meets performance targets
  - [ ] Error handling and recovery mechanisms functional
- **Test Requirements**:
  - Benchmark testing against pre-conversion performance
  - Functionality regression testing
  - Edge case handling verification

**Test Requirements**:
- All agents maintain functionality while achieving 80%+ delegation
- XML structure adds no significant performance overhead
- User experience remains consistent across all primary agents

---

## Validation Requirements

### 80% Delegation Enforcement

#### Automated Validation Script
```python
#!/usr/bin/env python3
"""XML Delegation Validator - Ensures 80% delegation compliance"""

def validate_delegation_percentage(agent_file_path):
    """Validate that agent achieves minimum 80% delegation"""
    
    with open(agent_file_path, 'r') as f:
        content = f.read()
    
    # Count orchestration vs delegation tasks
    orchestration_tasks = len(re.findall(r'🎯.*ORCHESTRATION', content))
    delegation_tasks = len(re.findall(r'📋.*DELEGATE', content))
    
    total_tasks = orchestration_tasks + delegation_tasks
    if total_tasks == 0:
        return False, "No tasks found"
    
    delegation_percentage = (delegation_tasks / total_tasks) * 100
    
    # Validate against 80% threshold
    if delegation_percentage < 80.0:
        return False, f"Delegation {delegation_percentage:.1f}% below 80% minimum"
    
    return True, f"Delegation {delegation_percentage:.1f}% meets requirements"

def validate_xml_structure(agent_file_path):
    """Validate required XML structure elements"""
    
    with open(agent_file_path, 'r') as f:
        content = f.read()
    
    required_elements = [
        '<agent_definition>',
        '<immediate_first_action>',
        '<workflow>',
        '<DELEGATE_TO',
        'MUST ALWAYS use the task tool',
        '═══',  # Visual dividers
        '🎯',   # Orchestration icon  
        '📋'    # Delegation icon
    ]
    
    missing_elements = []
    for element in required_elements:
        if element not in content:
            missing_elements.append(element)
    
    if missing_elements:
        return False, f"Missing required elements: {missing_elements}"
    
    return True, "All XML structure elements present"

def validate_task_tool_mandate(agent_file_path):
    """Validate task tool is mandatory first action"""
    
    with open(agent_file_path, 'r') as f:
        content = f.read()
    
    # Check for task tool first action requirement
    patterns = [
        r'MUST USE THE TASK TOOL AS YOUR VERY FIRST ACTION',
        r'task tool.*first action',
        r'mandatory.*task tool'
    ]
    
    for pattern in patterns:
        if re.search(pattern, content, re.IGNORECASE):
            return True, "Task tool mandate found"
    
    return False, "Task tool mandate not found or insufficient"

# Main validation function
def validate_agent_conversion(agent_file_path):
    """Complete validation of agent XML conversion"""
    
    results = []
    
    # Test delegation percentage
    passed, message = validate_delegation_percentage(agent_file_path)
    results.append(("Delegation Percentage", passed, message))
    
    # Test XML structure
    passed, message = validate_xml_structure(agent_file_path)
    results.append(("XML Structure", passed, message))
    
    # Test task tool mandate
    passed, message = validate_task_tool_mandate(agent_file_path)
    results.append(("Task Tool Mandate", passed, message))
    
    # Overall pass/fail
    overall_pass = all(result[1] for result in results)
    
    return overall_pass, results
```

#### Manual Validation Checklist

**For Each Agent:**
- [ ] XML structure properly implemented with all required sections
- [ ] 80%+ delegation validated by automated script
- [ ] Task tool mandatory first action requirement present
- [ ] Visual consistency (═══, 🎯, 📋) implemented throughout
- [ ] DELEGATE_TO sections specify clear success criteria
- [ ] Prohibited direct actions explicitly documented
- [ ] Agent-specific workflow patterns preserved
- [ ] Documentation output to correct subdirectory enforced

**Cross-Agent Consistency:**
- [ ] Common XML template structure used across all agents
- [ ] Delegation patterns consistent where applicable  
- [ ] Visual elements applied uniformly
- [ ] Task tool usage pattern identical across agents
- [ ] Error handling and recovery mechanisms consistent

### Testing Approach

#### Unit Testing for Each Agent

**Test Category 1: Structure Validation**
```python
def test_xml_structure_compliance(agent_name):
    """Test XML structure meets requirements"""
    agent_path = f"/ai/.config/opencode/agent/{agent_name}.md"
    
    # Test required XML elements present
    assert validate_xml_structure(agent_path)[0], "XML structure incomplete"
    
    # Test visual consistency
    content = read_file(agent_path)
    assert "═══" in content, "Missing section dividers"
    assert "🎯" in content, "Missing orchestration icons"
    assert "📋" in content, "Missing delegation icons"

def test_delegation_percentage(agent_name):
    """Test agent achieves 80%+ delegation"""
    agent_path = f"/ai/.config/opencode/agent/{agent_name}.md"
    
    passed, percentage = validate_delegation_percentage(agent_path)
    assert passed, f"Delegation below 80%: {percentage}"
    
def test_task_tool_mandate(agent_name):
    """Test task tool first action requirement"""
    agent_path = f"/ai/.config/opencode/agent/{agent_name}.md"
    
    passed, message = validate_task_tool_mandate(agent_path)
    assert passed, f"Task tool mandate not found: {message}"
```

**Test Category 2: Functional Preservation**
```python
def test_agent_specific_functionality(agent_name):
    """Test agent-specific functionality preserved"""
    
    if agent_name == "implement":
        # Test sequential-parallel hybrid pattern preserved
        assert_contains("sequential for code changes")
        assert_contains("parallel for validation")
        assert_contains("Dev Log")
        
    elif agent_name == "research":
        # Test batch operations and parallel streams
        assert_contains("ALWAYS PARALLEL")
        assert_contains("docs/research/")
        assert_contains("parallel_execute")
        
    elif agent_name == "debug":
        # Test rapid iteration and 3-minute checkpoints  
        assert_contains("3-minute checkpoints")
        assert_contains("parallel hypothesis")
        assert_contains("docs/debug/")
        
    elif agent_name == "test":
        # Test quality enforcement and no placeholders
        assert_contains("NEVER allow placeholder tests")
        assert_contains("80%+ coverage")
        assert_contains("docs/tests/")
        
    elif agent_name == "blueprint":
        # Test pattern analysis and template creation
        assert_contains("pattern analysis")
        assert_contains("template creation")
        assert_contains("docs/blueprints/")
```

**Test Category 3: Integration Testing**
```python
def test_cross_agent_consistency():
    """Test consistency across all converted agents"""
    
    agents = ["implement", "research", "debug", "test", "blueprint"]
    
    # Test common XML structure
    for agent in agents:
        assert_xml_structure_consistent(agent)
    
    # Test delegation patterns  
    for agent in agents:
        assert_delegation_percentage_meets_minimum(agent, 80.0)
    
    # Test visual consistency
    for agent in agents:
        assert_visual_elements_present(agent)

def test_performance_impact():
    """Test XML structure doesn't impact performance"""
    
    # Benchmark pre-conversion vs post-conversion
    baseline_times = get_baseline_performance()
    current_times = measure_current_performance()
    
    for agent in agents:
        # Allow 10% overhead maximum
        overhead = (current_times[agent] - baseline_times[agent]) / baseline_times[agent]
        assert overhead < 0.10, f"{agent} overhead {overhead*100:.1f}% exceeds 10% limit"
```

#### End-to-End Workflow Testing

**Test Scenario 1: Complete Agent Workflow**
- Execute each agent with realistic tasks
- Validate task tool first action occurs
- Confirm 80%+ work delegated to subagents  
- Verify correct documentation output location
- Check quality and completeness of results

**Test Scenario 2: Parallel Stream Coordination**
- Test multiple agents running simultaneously
- Validate no resource conflicts or race conditions
- Confirm convergence points work correctly
- Verify recovery mechanisms function properly

**Test Scenario 3: Error Handling and Recovery**
- Introduce deliberate failures in delegation
- Verify @guardian invocation works correctly
- Test fallback to sequential execution
- Confirm partial result preservation

#### Acceptance Testing

**Acceptance Criteria for Full Conversion:**
- [ ] All 5 primary agents pass automated validation (80%+ delegation, XML structure, task tool mandate)
- [ ] Manual functionality testing confirms no regressions
- [ ] Cross-agent consistency validated
- [ ] Performance impact within acceptable limits (<10% overhead)
- [ ] User experience remains consistent
- [ ] Documentation outputs correct and complete
- [ ] Error handling and recovery mechanisms functional

## Success Metrics

### Quantitative Metrics
- **Delegation Compliance**: 100% of agents achieve ≥80% delegation
- **Structural Consistency**: 100% of agents pass XML structure validation
- **Performance Impact**: <10% overhead from XML structure additions
- **Functionality Preservation**: 100% of existing features remain functional
- **Documentation Completeness**: 100% of agents create proper docs/ output

### Qualitative Metrics  
- **User Experience Consistency**: Uniform interaction patterns across all agents
- **Maintainability**: Clear, consistent structure for future modifications
- **Scalability**: Framework supports additional agents with minimal effort

## Risk Assessment and Mitigation

### High Risk: Agent Functionality Regression
- **Impact**: Existing workflows break after conversion  
- **Probability**: Medium
- **Mitigation**: 
  - Comprehensive functionality testing before and after conversion
  - Staged rollout with rollback capability
  - Preservation of agent-specific workflow patterns

### Medium Risk: Performance Degradation
- **Impact**: XML structure adds significant overhead
- **Probability**: Low
- **Mitigation**:
  - Performance benchmarking during development
  - XML structure optimization
  - Fallback to pre-conversion versions if needed

### Medium Risk: Delegation Enforcement Circumvention
- **Impact**: Agents don't achieve true 80% delegation despite passing validation
- **Probability**: Medium  
- **Mitigation**:
  - Robust validation framework with multiple validation methods
  - Manual verification during testing phase
  - Continuous monitoring post-deployment

### Low Risk: Cross-Agent Inconsistencies
- **Impact**: Inconsistent user experience between agents
- **Probability**: Low
- **Mitigation**:
  - Common XML template usage
  - Automated consistency validation
  - Thorough cross-agent testing

## Dev Log

### Planning Session - Initial Analysis
**Status**: Completed ✓  
**Implementation**:
- Analyzed all primary agent current structures vs plan.md XML pattern
- Identified delegation gaps: implement (65%), research (60%), debug (55%), test (70%), blueprint (50%)  
- Mapped XML structure requirements and agent-specific adaptations needed
- Created comprehensive conversion strategy with 3 implementation phases

**Validation**:
- Manual review of all agent files completed
- Gap analysis validated against plan.md successful pattern  
- Implementation approach verified for feasibility

**Key Decisions**:
- Use plan.md as reference template for all conversions
- Maintain agent-specific workflow patterns while standardizing XML structure
- Implement automated validation to ensure 80% delegation compliance
- Phase approach to allow testing and rollback if needed

**Next**: Phase 1 implementation - Template development and validation framework