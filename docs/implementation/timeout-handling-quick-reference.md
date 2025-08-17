# Timeout Handling Quick Reference

## Default Timeout Values by Agent

| Agent Type | Soft (min) | Hard (min) | Critical (min) |
|------------|------------|------------|----------------|
| Planning   | 5          | 10         | 15             |
| Implementation | 5      | 10         | 20             |
| Research   | 4          | 8          | 12             |
| Debug      | 3          | 6          | 10             |
| Test       | 5          | 10         | 15             |
| Blueprint  | 5          | 10         | 15             |

## Timeout Triggers and Actions

### Soft Timeout (5 min default)
**Trigger**: No progress for configured duration  
**Action**: Progress check  
**Decision**:
- Progress > 50% → Continue + extend timeout
- Progress 25-50% → Continue + monitor closely  
- Progress < 25% → Prepare for hard timeout
- Has partial results → Salvage + continue

### Hard Timeout (10 min default)
**Trigger**: Task not completed within limit  
**Action**: Terminate and retry  
**Process**:
1. Save partial results
2. Reduce scope by 50%
3. Retry (max 2 attempts)
4. Fallback to sequential if needed

### Critical Timeout (15 min default)
**Trigger**: Total time exceeded  
**Action**: Escalate to user  
**Options**:
- Manual intervention
- Accept partial results
- Skip task
- Change approach

## Task-Specific Configurations

### High-Priority Tasks (Faster Timeouts)
```python
config = TimeoutConfig(
    soft_timeout=180,    # 3 min
    hard_timeout=360,    # 6 min
    critical_timeout=600 # 10 min
)
```

### Complex Tasks (Extended Timeouts)
```python
config = TimeoutConfig(
    soft_timeout=600,     # 10 min
    hard_timeout=1200,    # 20 min
    critical_timeout=1800 # 30 min
)
```

### Experimental Tasks (Flexible Timeouts)
```python
config = TimeoutConfig(
    soft_timeout=300,
    hard_timeout=600,
    max_retries=5,        # More retries
    scope_reduction_factor=0.8  # Gentle reduction
)
```

## Recovery Strategies

### 1. Scope Reduction Pattern
```
Original: 100% → Retry 1: 70% → Retry 2: 50% → Retry 3: 30%
```

### 2. Task Splitting Pattern
```
Large Task → [Subtask 1, Subtask 2, ..., Subtask N]
Each with independent timeout
```

### 3. Sequential Fallback
```
Parallel Streams → Sequential Tasks
Preserves order and dependencies
```

### 4. Partial Salvage
```
Progress > 75% → Accept and continue
Progress 50-75% → Retry remainder only
Progress < 50% → Full retry recommended
```

## Common Timeout Scenarios

### Scenario 1: Slow but Progressing
```
Status: 40% complete at 5 min
Action: Soft timeout check
Result: Continue with monitoring
```

### Scenario 2: Stuck Early
```
Status: 10% complete, no progress for 5 min
Action: Soft timeout → Hard timeout
Result: Retry with 50% scope
```

### Scenario 3: Nearly Complete
```
Status: 85% complete at 10 min
Action: Hard timeout check
Result: Extend timeout to complete
```

### Scenario 4: Repeated Failures
```
Status: Failed 2 retries
Action: Critical escalation
Result: User intervention required
```

## Monitoring Commands

### Check Timeout Status
```python
report = timeout_manager.get_timeout_report()
print(f"Active: {report['active_tasks']}")
print(f"Timed Out: {report['timed_out_tasks']}")
print(f"Escalated: {report['escalated_tasks']}")
```

### Update Task Progress
```python
timeout_manager.update_task_progress(
    task_id=task_id,
    progress=65,
    partial_results={"completed": ["file1.py", "file2.py"]}
)
```

### Manual Escalation
```python
timeout_manager._escalate_task(
    task_id=task_id,
    reason="Manual escalation requested"
)
```

## Best Practices

1. **Set Realistic Timeouts**: Base on historical task performance
2. **Update Progress Frequently**: Every 1-2 minutes minimum
3. **Save Partial Results**: Enable recovery from timeouts
4. **Use Appropriate Scope**: Start conservative, expand if needed
5. **Monitor Timeout Patterns**: Adjust configurations based on data
6. **Document Escalations**: Track why tasks timeout for improvement
7. **Test Recovery Paths**: Ensure fallback strategies work
8. **Configure by Task Type**: Different tasks need different limits

## Timeout Configuration Template

```yaml
task_timeout_config:
  # Basic timeouts
  soft_timeout: 300      # 5 minutes
  hard_timeout: 600      # 10 minutes  
  critical_timeout: 900  # 15 minutes
  
  # Recovery settings
  max_retries: 2
  scope_reduction_factor: 0.5
  fallback_strategy: "sequential"
  
  # Monitoring
  progress_check_interval: 60  # seconds
  heartbeat_timeout: 120       # seconds
  
  # Escalation
  escalation_enabled: true
  preserve_partial_results: true
  auto_salvage_threshold: 50  # % progress
```

## Emergency Procedures

### System Overload
```python
# Immediate termination of all non-critical tasks
timeout_manager.emergency_shutdown(
    preserve_critical=True,
    reason="System resource exhaustion"
)
```

### Infinite Loop Detection
```python
# Automatic termination after 5 identical states
if task.state_unchanged_count > 5:
    timeout_manager.force_terminate(task_id)
```

### Cascade Failure Prevention
```python
# Stop dependent tasks if parent times out
if parent_task.status == "timeout":
    for child in dependent_tasks:
        timeout_manager.pause_task(child.id)
```