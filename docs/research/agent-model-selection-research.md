# Agent Model Selection Research

## Executive Summary

### Key Recommendations
- **Orchestration & Planning**: Claude Opus 3 for complex strategy, Sonnet 3.5 for balanced performance
- **Code Generation**: Claude Sonnet 3.5 or GPT-4 Turbo for complex code, Haiku for utilities
- **Research & Discovery**: Claude Sonnet 3.5 with 200k context, GPT-4 for web search integration
- **Testing & Validation**: Haiku for fast parallel checks, Sonnet 3.5 for nuanced reasoning
- **Documentation**: Sonnet 3.5 for quality writing, Haiku for quick summaries
- **Quick Utilities**: Claude Haiku for maximum speed/cost efficiency

### Cost Optimization Strategy
1. Default to mid-tier models (Sonnet 3.5)
2. Auto-escalate for complexity signals
3. De-escalate for routine tasks
4. Use prompt caching for system prompts
5. Batch operations with smaller models

### Performance Targets
- Response time: <5s for utilities, <30s for complex tasks
- Cost per task: <$0.10 average, <$1.00 for complex orchestration
- Context utilization: 70% efficiency target
- Parallel execution: Haiku for high-throughput operations

## Model Selection Principles

### Task Complexity Matching

#### High Complexity (Opus 3 / GPT-4)
- Multi-step reasoning with uncertainty
- Cross-domain synthesis
- Architectural design decisions
- Complex debugging scenarios
- Safety-critical code review

#### Medium Complexity (Sonnet 3.5 / GPT-4 Turbo)
- Standard code generation
- Research synthesis
- Test creation
- Documentation writing
- Plan execution

#### Low Complexity (Haiku / GPT-3.5 Turbo)
- Code formatting
- Simple transformations
- Validation checks
- File organization
- Commit messages

### Cost Optimization Strategies

#### Tiered Cascade Pattern
```yaml
cascade_strategy:
  initial_attempt: haiku
  confidence_threshold: 0.8
  escalation_triggers:
    - confidence < 0.8
    - error_count > 2
    - ambiguity_detected: true
  escalation_path:
    - sonnet_3.5
    - opus_3
  de_escalation_after: task_completion
```

#### Prompt Caching Strategy
- Cache system prompts (save 90% on repeated calls)
- Cache common contexts (project structure, dependencies)
- Cache research corpus for synthesis tasks
- Refresh cache every 5 minutes for dynamic content

### Performance Requirements

#### Latency Targets by Agent Type
| Agent Type | P50 Latency | P95 Latency | Max Latency |
|------------|-------------|-------------|-------------|
| Planning   | 10s         | 20s         | 30s         |
| Implementation | 5s      | 15s         | 25s         |
| Research   | 15s         | 30s         | 45s         |
| Debug      | 3s          | 8s          | 15s         |
| Test       | 5s          | 12s         | 20s         |
| Utility    | 1s          | 3s          | 5s          |

### Context Window Needs

#### Context Requirements by Task
| Task Type | Typical Context | Maximum Context | Recommended Model |
|-----------|-----------------|-----------------|-------------------|
| Architecture Planning | 50-100k | 200k | Sonnet 3.5 / Opus 3 |
| Multi-file Refactoring | 30-80k | 150k | Sonnet 3.5 |
| Research Synthesis | 100-200k | 1M (beta) | Sonnet 3.5 with chunking |
| Code Generation | 10-50k | 100k | Sonnet 3.5 / GPT-4 |
| Testing | 5-20k | 50k | Haiku / Sonnet 3.5 |
| Documentation | 20-60k | 150k | Sonnet 3.5 |
| Utilities | <5k | 10k | Haiku |

## Primary Agent Recommendations

### 1. Plan Agent (Orchestration/Strategic Thinking)

**Primary Model**: Claude Sonnet 3.5
- Excellent reasoning capabilities
- 200k context window for complex plans
- Good balance of speed and intelligence
- Cost-effective for iterative planning

**Premium Model**: Claude Opus 3
- Use for: Critical architecture decisions, complex multi-constraint problems
- Triggers: Failed attempts with Sonnet, high ambiguity, safety-critical planning

**Budget Model**: Claude Haiku
- Use for: Quick plan outlines, simple task decomposition
- Acceptable when: Clear requirements, well-defined scope

**Configuration**:
```yaml
plan_agent:
  default_model: claude-3-5-sonnet-20241022
  premium_model: claude-3-opus-20240229
  budget_model: claude-3-haiku-20240307
  context_window: 200000
  temperature: 0.7
  enable_caching: true
  escalation_triggers:
    - complexity_score > 0.8
    - retry_count > 2
```

### 2. Implement Agent (Code Execution)

**Primary Model**: Claude Sonnet 3.5
- Superior code generation
- Understands complex codebases
- Good at following patterns
- Excellent tool use

**Alternative**: GPT-4 Turbo
- Strong coding capabilities
- Good for web technologies
- Fast response times

**Budget Model**: Claude Haiku
- Use for: Boilerplate, simple functions, config files
- Parallel execution for bulk changes

**Configuration**:
```yaml
implement_agent:
  default_model: claude-3-5-sonnet-20241022
  alternative_model: gpt-4-turbo-preview
  budget_model: claude-3-haiku-20240307
  context_window: 150000
  temperature: 0.3
  max_tokens: 4000
  enable_streaming: true
```

### 3. Research Agent (Deep Exploration)

**Primary Model**: Claude Sonnet 3.5
- Excellent synthesis capabilities
- 200k-1M context (beta)
- Strong citation practices
- Good at finding patterns

**Web Search Model**: GPT-4 with browsing
- Better web integration
- Real-time information access
- Good at following links

**Budget Model**: Claude Haiku
- Use for: Quick lookups, simple searches
- Parallel search operations

**Configuration**:
```yaml
research_agent:
  default_model: claude-3-5-sonnet-20241022
  search_model: gpt-4-turbo-preview
  budget_model: claude-3-haiku-20240307
  context_window: 200000
  enable_web_search: true
  enable_citations: true
  chunk_size: 50000
```

### 4. Debug Agent (Systematic Investigation)

**Primary Model**: Claude Sonnet 3.5
- Excellent at pattern recognition
- Good hypothesis generation
- Strong reasoning about causality

**Fast Model**: Claude Haiku
- Quick error pattern matching
- Parallel log analysis
- Rapid hypothesis testing

**Configuration**:
```yaml
debug_agent:
  default_model: claude-3-5-sonnet-20241022
  fast_model: claude-3-haiku-20240307
  context_window: 100000
  temperature: 0.2
  enable_chain_of_thought: true
  parallel_hypothesis_testing: true
```

### 5. Test Agent (Comprehensive Testing)

**Primary Model**: Claude Sonnet 3.5
- Excellent test case generation
- Good at edge case identification
- Strong coverage analysis

**Fast Model**: Claude Haiku
- Bulk test generation
- Quick validation checks
- Parallel test execution

**Specialized**: GPT-4 for web/API testing
- Better at HTTP/REST patterns
- Good mock generation

**Configuration**:
```yaml
test_agent:
  default_model: claude-3-5-sonnet-20241022
  fast_model: claude-3-haiku-20240307
  api_test_model: gpt-4-turbo-preview
  context_window: 50000
  temperature: 0.4
  coverage_target: 0.8
  parallel_generation: true
```

### 6. Blueprint Agent (Technical Templating)

**Primary Model**: Claude Sonnet 3.5
- Excellent pattern recognition
- Good at extracting reusable components
- Strong template generation

**Configuration**:
```yaml
blueprint_agent:
  default_model: claude-3-5-sonnet-20241022
  context_window: 100000
  temperature: 0.3
  enable_pattern_analysis: true
  template_validation: strict
```

## Subagent Recommendations

### Core Subagents

#### 1. Architect
**Model**: Claude Sonnet 3.5
- Design patterns and system architecture
- High-level structure decisions
- Interface definitions

#### 2. Executor
**Model**: Claude Haiku (primary), Sonnet 3.5 (complex)
- Task execution and implementation
- Fast iteration cycles
- Parallel execution capability

#### 3. Researcher
**Model**: Claude Sonnet 3.5 with GPT-4 for web
- Information gathering
- Source synthesis
- Citation management

#### 4. Validator
**Model**: Claude Haiku
- Fast validation checks
- Parallel verification
- Rule-based checking

#### 5. Documenter
**Model**: Claude Sonnet 3.5 (quality), Haiku (speed)
- Technical documentation
- API documentation
- Code comments

### Utility Subagents

#### 6. Synthesizer
**Model**: Claude Sonnet 3.5
- Information condensation
- Multi-source integration
- Summary generation

#### 7. Tracer
**Model**: Claude Haiku
- Dependency tracking
- Cross-reference management
- Link maintenance

#### 8. Formatter
**Model**: Claude Haiku
- Code formatting
- Markdown normalization
- Style consistency

#### 9. Organizer
**Model**: Claude Haiku
- File organization
- Directory structure
- Naming conventions

### Testing Subagents

#### 10. Test-Analyzer
**Model**: Claude Sonnet 3.5
- Test scenario identification
- Coverage analysis
- Edge case discovery

#### 11. Test-Generator
**Model**: Claude Sonnet 3.5 (complex), Haiku (simple)
- Test code creation
- Mock generation
- Fixture creation

#### 12. Test-Coverage
**Model**: Claude Haiku
- Coverage metrics calculation
- Gap identification
- Report generation

#### 13. Test-Validator
**Model**: Claude Haiku
- Test quality checks
- Anti-pattern detection
- Best practice enforcement

#### 14. Test-Documenter
**Model**: Claude Haiku
- Test documentation
- Test plan creation
- Report generation

#### 15. Test-Researcher
**Model**: Claude Sonnet 3.5
- Testing best practices research
- Framework evaluation
- Pattern identification

### Specialized Subagents

#### 16. Committer
**Model**: Claude Haiku
- Commit message generation
- Conventional commits
- Change summarization

#### 17. Guardian
**Model**: Claude Sonnet 3.5
- Process monitoring
- Stuck detection
- Recovery orchestration

#### 18. Reviewer
**Model**: Claude Sonnet 3.5
- Requirement validation
- Quality assessment
- Completeness checking

## Model Comparison Table

### Primary Agents

| Agent | First Choice | Second Choice | Third Choice | Rationale |
|-------|-------------|---------------|--------------|-----------|
| **Plan** | Claude Sonnet 3.5 | Claude Opus 3 | GPT-4 Turbo | Sonnet balances reasoning and cost; Opus for critical decisions; GPT-4 as alternative |
| **Implement** | Claude Sonnet 3.5 | GPT-4 Turbo | Claude Haiku | Sonnet excels at code; GPT-4 for web tech; Haiku for simple tasks |
| **Research** | Claude Sonnet 3.5 | GPT-4 + Browse | Claude Opus 3 | Sonnet for synthesis; GPT-4 for web; Opus for complex analysis |
| **Debug** | Claude Sonnet 3.5 | Claude Haiku | GPT-4 | Sonnet for reasoning; Haiku for speed; GPT-4 as backup |
| **Test** | Claude Sonnet 3.5 | Claude Haiku | GPT-4 | Sonnet for quality; Haiku for volume; GPT-4 for web/API |
| **Blueprint** | Claude Sonnet 3.5 | Claude Opus 3 | GPT-4 | Sonnet for patterns; Opus for complex extraction; GPT-4 alternative |

### Subagents

| Subagent | First Choice | Second Choice | Third Choice | Trade-offs |
|----------|-------------|---------------|--------------|------------|
| **Architect** | Sonnet 3.5 | Opus 3 | GPT-4 | Quality vs Cost |
| **Executor** | Haiku | Sonnet 3.5 | GPT-3.5 | Speed vs Capability |
| **Researcher** | Sonnet 3.5 | GPT-4 | Opus 3 | Synthesis vs Web |
| **Validator** | Haiku | GPT-3.5 | Sonnet 3.5 | Speed vs Accuracy |
| **Documenter** | Sonnet 3.5 | Haiku | GPT-4 | Quality vs Speed |
| **Synthesizer** | Sonnet 3.5 | Opus 3 | GPT-4 | Context vs Cost |
| **Tracer** | Haiku | GPT-3.5 | Sonnet 3.5 | Speed priority |
| **Formatter** | Haiku | GPT-3.5 | - | Speed critical |
| **Organizer** | Haiku | GPT-3.5 | - | Simple task |
| **Test-Analyzer** | Sonnet 3.5 | GPT-4 | Haiku | Analysis depth |
| **Test-Generator** | Sonnet 3.5 | Haiku | GPT-4 | Quality vs Volume |
| **Test-Coverage** | Haiku | GPT-3.5 | - | Calculation speed |
| **Test-Validator** | Haiku | Sonnet 3.5 | GPT-3.5 | Speed vs Nuance |
| **Test-Documenter** | Haiku | GPT-3.5 | Sonnet 3.5 | Speed priority |
| **Test-Researcher** | Sonnet 3.5 | GPT-4 | Opus 3 | Research quality |
| **Committer** | Haiku | GPT-3.5 | - | Simple generation |
| **Guardian** | Sonnet 3.5 | Opus 3 | GPT-4 | Recovery complexity |
| **Reviewer** | Sonnet 3.5 | Opus 3 | GPT-4 | Review depth |

## Implementation Strategy

### Configuration Examples

#### OpenCode Configuration
```yaml
# .opencode/models.yaml
models:
  providers:
    anthropic:
      api_key: ${ANTHROPIC_API_KEY}
      default_model: claude-3-5-sonnet-20241022
      enable_caching: true
      cache_ttl: 300
    
    openai:
      api_key: ${OPENAI_API_KEY}
      default_model: gpt-4-turbo-preview
      enable_streaming: true
  
  agents:
    plan:
      primary: claude-3-5-sonnet-20241022
      fallback: claude-3-haiku-20240307
      escalation: claude-3-opus-20240229
      max_tokens: 4000
      temperature: 0.7
    
    implement:
      primary: claude-3-5-sonnet-20241022
      fallback: gpt-4-turbo-preview
      budget: claude-3-haiku-20240307
      max_tokens: 8000
      temperature: 0.3
    
    research:
      primary: claude-3-5-sonnet-20241022
      search: gpt-4-turbo-preview
      budget: claude-3-haiku-20240307
      max_context: 200000
      enable_web: true
    
    debug:
      primary: claude-3-5-sonnet-20241022
      fast: claude-3-haiku-20240307
      temperature: 0.2
      chain_of_thought: true
    
    test:
      primary: claude-3-5-sonnet-20241022
      bulk: claude-3-haiku-20240307
      api_testing: gpt-4-turbo-preview
      parallel_limit: 10
    
    blueprint:
      primary: claude-3-5-sonnet-20241022
      temperature: 0.3
      pattern_extraction: true
```

### Fallback Patterns

#### Cascading Fallback Strategy
```python
class ModelSelector:
    def __init__(self):
        self.fallback_chain = {
            "claude-3-5-sonnet": ["claude-3-opus", "gpt-4-turbo", "claude-3-haiku"],
            "claude-3-opus": ["claude-3-5-sonnet", "gpt-4"],
            "gpt-4-turbo": ["claude-3-5-sonnet", "gpt-4"],
            "claude-3-haiku": ["gpt-3.5-turbo", "claude-3-5-sonnet"]
        }
    
    def select_model(self, task_type, complexity_score):
        if complexity_score > 0.8:
            return self.get_premium_model(task_type)
        elif complexity_score < 0.3:
            return self.get_budget_model(task_type)
        else:
            return self.get_default_model(task_type)
    
    def handle_failure(self, current_model, error_type):
        fallbacks = self.fallback_chain.get(current_model, [])
        for fallback in fallbacks:
            if self.is_available(fallback):
                return fallback
        raise NoModelAvailable(f"All fallbacks exhausted for {current_model}")
```

#### Error-Based Escalation
```yaml
escalation_rules:
  rate_limit:
    action: switch_provider
    from: anthropic
    to: openai
  
  context_overflow:
    action: upgrade_model
    from: haiku
    to: sonnet
  
  quality_issue:
    action: escalate
    from: sonnet
    to: opus
    threshold: 3_retries
  
  timeout:
    action: downgrade
    from: opus
    to: sonnet
    preserve_context: true
```

### Cost Monitoring Approach

#### Cost Tracking System
```python
class CostMonitor:
    def __init__(self):
        self.cost_per_token = {
            "claude-3-opus": {"input": 0.015, "output": 0.075},
            "claude-3-5-sonnet": {"input": 0.003, "output": 0.015},
            "claude-3-haiku": {"input": 0.00025, "output": 0.00125},
            "gpt-4-turbo": {"input": 0.01, "output": 0.03},
            "gpt-3.5-turbo": {"input": 0.0005, "output": 0.0015}
        }
        self.usage_history = []
        self.budget_limits = {
            "hourly": 10.0,
            "daily": 100.0,
            "monthly": 2000.0
        }
    
    def track_usage(self, model, input_tokens, output_tokens):
        cost = self.calculate_cost(model, input_tokens, output_tokens)
        self.usage_history.append({
            "timestamp": datetime.now(),
            "model": model,
            "input_tokens": input_tokens,
            "output_tokens": output_tokens,
            "cost": cost
        })
        self.check_budget_alerts()
        return cost
    
    def get_cost_report(self, period="daily"):
        # Generate cost breakdown by model, agent, and time period
        pass
```

#### Budget Optimization Rules
```yaml
budget_optimization:
  rules:
    - name: peak_hours_downgrade
      condition: time_between(9, 17) and load > 0.8
      action: prefer_budget_models
    
    - name: batch_with_haiku
      condition: task_count > 10 and similarity > 0.7
      action: use_haiku_parallel
    
    - name: cache_expensive_contexts
      condition: context_size > 50000 and model in [opus, sonnet]
      action: enable_prompt_caching
    
    - name: progressive_escalation
      condition: confidence < threshold
      action: try_cheaper_first
      sequence: [haiku, sonnet, opus]
```

### Monitoring Dashboard
```yaml
metrics:
  performance:
    - response_time_p50
    - response_time_p95
    - tokens_per_second
    - cache_hit_rate
  
  quality:
    - task_success_rate
    - retry_count
    - escalation_rate
    - user_satisfaction
  
  cost:
    - cost_per_task
    - cost_per_agent
    - budget_utilization
    - model_distribution
  
  alerts:
    - budget_exceeded
    - high_retry_rate
    - model_unavailable
    - quality_degradation
```

## Best Practices

### 1. Model Selection
- Start with Sonnet 3.5 as default for most agents
- Use Haiku for high-volume, low-complexity tasks
- Reserve Opus 3 for critical decisions only
- Implement automatic escalation based on confidence

### 2. Context Management
- Use prompt caching for system prompts
- Chunk large contexts intelligently
- Stream responses for better UX
- Implement context window monitoring

### 3. Cost Optimization
- Batch similar operations with Haiku
- Cache frequently used contexts
- Monitor cost per task continuously
- Implement budget alerts and limits

### 4. Performance Optimization
- Use parallel execution with Haiku
- Implement streaming for long responses
- Cache model responses when appropriate
- Monitor and optimize token usage

### 5. Quality Assurance
- Track success rates by model
- Implement quality checks
- A/B test model changes
- Maintain evaluation datasets

## Conclusion

This model selection strategy provides a balanced approach optimizing for:
- **Quality**: Using appropriate models for task complexity
- **Cost**: Minimizing expenses through intelligent routing
- **Performance**: Meeting latency requirements
- **Reliability**: Implementing robust fallback patterns

The recommended configuration uses Claude Sonnet 3.5 as the workhorse model, with strategic use of Opus 3 for complex tasks and Haiku for high-volume operations. This approach should achieve optimal results while maintaining cost efficiency in the OpenCode environment.