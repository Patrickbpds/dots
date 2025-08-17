# Coordination Mechanisms Quick Reference

## Convergence Points

### Barrier Convergence
**When to use**: When all streams must complete before proceeding
```python
convergence_type: "barrier"
# All streams wait at convergence point
```

### Progressive Convergence  
**When to use**: For long-running tasks where partial results are useful
```python
convergence_type: "progressive"
# Streams merge results as they complete
```

### Checkpoint Convergence
**When to use**: For regular synchronization during execution
```python
convergence_type: "checkpoint"
checkpoint_interval: 300  # 5 minutes
```

## Race Condition Prevention

### File Access Patterns
```python
# Read access (multiple readers OK)
lock_manager.acquire_file_lock(file, mode="read")

# Write access (exclusive)
lock_manager.acquire_file_lock(file, mode="write")

# Atomic write (safe replacement)
AtomicFileOperations.atomic_write(file, content)
```

### Workspace Isolation
```python
# Each stream gets isolated directory
stream_workspace = allocate_stream_directory(stream_id)
# No conflicts between streams
```

## Shared State Management

### Centralized State
```python
# Thread-safe state updates
state_manager.update_state(key, value, stream_id)
# Versioned with change log
```

### Immutable State
```python
# Copy-on-write pattern
new_state = state_manager.create_new_version(
    transformer_func, stream_id
)
```

### Message Queue
```python
# Async communication between streams
coordinator.send_message(from_stream, to_stream, message)
coordinator.broadcast_message(from_stream, message)
```

## Coordination Protocols

### Stream Registration
```python
stream_config = {
    "id": "my_stream",
    "capabilities": ["code_gen"],
    "dependencies": ["analysis_stream"]
}
register_stream(stream_config)
```

### Heartbeat Monitoring
```python
# Automatic - sends every 60 seconds
# Guardian invoked after 10 min timeout
send_heartbeat(stream_id, status_info)
```

### Resource Negotiation
```python
# Request resources with negotiation
request_resources(stream_id, {
    "cpu_cores": 2,
    "memory_mb": 1024
})
```

## Configuration Template

```yaml
coordination:
  convergence_type: "barrier"
  
  isolation:
    workspace: "isolated"
    file_access: "exclusive_write"
    
  state_management:
    type: "immutable"
    sync_interval: 300
    
  protocols:
    - "registration"
    - "heartbeat"
    - "negotiation"
    
  recovery:
    max_retries: 2
    timeout: 600
    fallback: "sequential"
```

## Common Patterns

### Safe Parallel File Modification
```python
# Each stream modifies different files
stream_1: modify files in src/module_a/
stream_2: modify files in src/module_b/
# No conflicts
```

### Coordinated Test Execution
```python
# Parallel test generation
stream_1: generate unit tests
stream_2: generate integration tests
# Barrier convergence before running all tests
```

### Progressive Documentation Update
```python
# Streams update docs as they complete
stream_1: update API docs → merge
stream_2: update README → merge  
stream_3: update examples → merge
# Progressive convergence for immediate availability
```

## Debugging

### Check Active Streams
```bash
coordinator.list_active_streams()
```

### View Lock Contentions
```bash
lock_manager.show_contentions()
```

### Monitor Convergence
```bash
coordinator.convergence_status()
```

### View State History
```bash
state_manager.get_change_log()
```

## Recovery Mechanisms

### Automatic Guardian Invocation
- No heartbeat for 10 minutes → Guardian invoked
- Stuck at convergence point → Guardian invoked
- Resource deadlock detected → Guardian invoked

### Recovery Sequence
1. **Soft Recovery**: Query status, request update
2. **Hard Recovery**: Terminate, capture partial, retry
3. **Fallback**: Switch to sequential execution

## Best Practices

1. **Always isolate workspaces** for parallel writes
2. **Use appropriate convergence type** for your use case
3. **Configure heartbeat monitoring** for all streams
4. **Define clear dependencies** in stream registration
5. **Use atomic operations** for critical updates
6. **Test recovery mechanisms** before production
7. **Monitor coordination overhead** (target < 10%)
8. **Document convergence points** in agent config
9. **Use immutable state** when possible
10. **Log all coordination events** for debugging