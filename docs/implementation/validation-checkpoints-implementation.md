# Validation Checkpoints Implementation

## Overview
This document implements comprehensive validation checkpoints for all agent workflows, ensuring robust error detection within 2 minutes and maintaining high-quality execution standards.

## Validation Checkpoint Architecture

### Three-Phase Validation System

#### 1. Pre-Execution Validation
**Timing**: Before any stream starts (0-30 seconds)
**Purpose**: Verify all prerequisites and resources are available

```python
class PreExecutionValidator:
    """Validates prerequisites before execution begins."""
    
    def __init__(self, agent_type: str):
        self.agent_type = agent_type
        self.validation_start = None
        self.validation_results = {}
        self.max_validation_time = 30  # 30 seconds max
        
    def validate_all(self, task_config: Dict[str, Any]) -> ValidationResult:
        """Run all pre-execution validations."""
        self.validation_start = datetime.now()
        
        validations = [
            self.validate_prerequisites(),
            self.validate_resources(),
            self.validate_dependencies(),
            self.validate_permissions(),
            self.validate_environment(),
            self.validate_input_data()
        ]
        
        # Run validations in parallel for speed
        with ThreadPoolExecutor(max_workers=6) as executor:
            futures = []
            for validation in validations:
                futures.append(executor.submit(validation, task_config))
            
            # Wait max 30 seconds for all validations
            done, not_done = wait(futures, timeout=self.max_validation_time)
            
            # Process results
            for future in done:
                result = future.result()
                self.validation_results[result.name] = result
            
            # Handle timeouts
            for future in not_done:
                future.cancel()
                self.validation_results["timeout"] = ValidationResult(
                    name="timeout",
                    passed=False,
                    reason="Validation timeout exceeded 30 seconds"
                )
        
        return self.aggregate_results()
    
    def validate_prerequisites(self, config: Dict) -> ValidationResult:
        """Validate all prerequisites are met."""
        checks = {
            "required_tools": self.check_required_tools(config),
            "required_files": self.check_required_files(config),
            "required_services": self.check_required_services(config),
            "network_connectivity": self.check_network(config)
        }
        
        failed = [k for k, v in checks.items() if not v["passed"]]
        
        return ValidationResult(
            name="prerequisites",
            passed=len(failed) == 0,
            checks=checks,
            reason=f"Failed prerequisites: {', '.join(failed)}" if failed else "All prerequisites met"
        )
    
    def validate_resources(self, config: Dict) -> ValidationResult:
        """Validate sufficient resources are available."""
        required = config.get("resources", {})
        available = self.get_available_resources()
        
        checks = {
            "cpu": available["cpu"] >= required.get("cpu_cores", 1),
            "memory": available["memory"] >= required.get("memory_mb", 512),
            "disk": available["disk"] >= required.get("disk_mb", 1000),
            "file_handles": available["file_handles"] >= required.get("file_handles", 100)
        }
        
        insufficient = [k for k, v in checks.items() if not v]
        
        return ValidationResult(
            name="resources",
            passed=len(insufficient) == 0,
            checks=checks,
            available=available,
            required=required,
            reason=f"Insufficient resources: {', '.join(insufficient)}" if insufficient else "Resources adequate"
        )
    
    def validate_dependencies(self, config: Dict) -> ValidationResult:
        """Validate all dependencies are available."""
        dependencies = config.get("dependencies", [])
        
        checks = {}
        for dep in dependencies:
            if isinstance(dep, str):
                # Simple dependency check
                checks[dep] = self.check_dependency_exists(dep)
            elif isinstance(dep, dict):
                # Complex dependency with version
                checks[dep["name"]] = self.check_dependency_version(
                    dep["name"], 
                    dep.get("version"),
                    dep.get("operator", ">=")
                )
        
        missing = [k for k, v in checks.items() if not v["available"]]
        
        return ValidationResult(
            name="dependencies",
            passed=len(missing) == 0,
            checks=checks,
            reason=f"Missing dependencies: {', '.join(missing)}" if missing else "All dependencies satisfied"
        )
    
    def validate_permissions(self, config: Dict) -> ValidationResult:
        """Validate required permissions."""
        paths = config.get("paths", {})
        
        checks = {}
        for path_type, path_list in paths.items():
            for path in path_list:
                if path_type == "read":
                    checks[f"read:{path}"] = os.access(path, os.R_OK)
                elif path_type == "write":
                    checks[f"write:{path}"] = os.access(path, os.W_OK)
                elif path_type == "execute":
                    checks[f"execute:{path}"] = os.access(path, os.X_OK)
        
        denied = [k for k, v in checks.items() if not v]
        
        return ValidationResult(
            name="permissions",
            passed=len(denied) == 0,
            checks=checks,
            reason=f"Permission denied: {', '.join(denied)}" if denied else "All permissions granted"
        )
    
    def validate_environment(self, config: Dict) -> ValidationResult:
        """Validate environment variables and settings."""
        required_env = config.get("environment", {})
        
        checks = {}
        for var, expected in required_env.items():
            actual = os.environ.get(var)
            if expected == "*":
                # Just check existence
                checks[var] = actual is not None
            else:
                # Check specific value
                checks[var] = actual == expected
        
        missing = [k for k, v in checks.items() if not v]
        
        return ValidationResult(
            name="environment",
            passed=len(missing) == 0,
            checks=checks,
            reason=f"Environment issues: {', '.join(missing)}" if missing else "Environment configured"
        )
    
    def validate_input_data(self, config: Dict) -> ValidationResult:
        """Validate input data format and content."""
        input_data = config.get("input", {})
        
        checks = {
            "format": self.validate_data_format(input_data),
            "schema": self.validate_data_schema(input_data),
            "size": self.validate_data_size(input_data),
            "encoding": self.validate_data_encoding(input_data)
        }
        
        invalid = [k for k, v in checks.items() if not v["valid"]]
        
        return ValidationResult(
            name="input_data",
            passed=len(invalid) == 0,
            checks=checks,
            reason=f"Invalid input: {', '.join(invalid)}" if invalid else "Input data valid"
        )
```

#### 2. During-Execution Validation
**Timing**: Every 2 minutes during execution
**Purpose**: Catch errors early and validate progress

```python
class DuringExecutionValidator:
    """Validates execution health every 2 minutes."""
    
    def __init__(self, checkpoint_manager: CheckpointManager):
        self.checkpoint_manager = checkpoint_manager
        self.validation_interval = 120  # 2 minutes
        self.error_detection_threshold = 2  # Errors within 2 minutes
        self.validation_thread = None
        self.running = False
        self.validation_history = []
        
    def start_monitoring(self):
        """Start the during-execution validation monitoring."""
        self.running = True
        self.validation_thread = threading.Thread(target=self._validation_loop)
        self.validation_thread.daemon = True
        self.validation_thread.start()
    
    def stop_monitoring(self):
        """Stop the validation monitoring."""
        self.running = False
        if self.validation_thread:
            self.validation_thread.join(timeout=5)
    
    def _validation_loop(self):
        """Main validation loop running every 2 minutes."""
        while self.running:
            try:
                # Perform validation
                validation_result = self.validate_execution_health()
                
                # Store result
                self.validation_history.append({
                    "timestamp": datetime.now(),
                    "result": validation_result
                })
                
                # Handle validation failures
                if not validation_result.passed:
                    self.handle_validation_failure(validation_result)
                
                # Sleep for 2 minutes
                time.sleep(self.validation_interval)
                
            except Exception as e:
                print(f"[VALIDATION ERROR] {e}")
                time.sleep(30)  # Brief pause before retry
    
    def validate_execution_health(self) -> ValidationResult:
        """Comprehensive execution health validation."""
        validations = {
            "progress": self.validate_progress(),
            "errors": self.validate_error_rate(),
            "resources": self.validate_resource_usage(),
            "streams": self.validate_stream_health(),
            "output": self.validate_partial_output(),
            "deadlocks": self.validate_no_deadlocks(),
            "memory_leaks": self.validate_no_memory_leaks(),
            "infinite_loops": self.validate_no_infinite_loops()
        }
        
        failed = [k for k, v in validations.items() if not v.passed]
        
        return ValidationResult(
            name="execution_health",
            passed=len(failed) == 0,
            validations=validations,
            failed_checks=failed,
            reason=f"Health check failures: {', '.join(failed)}" if failed else "Execution healthy"
        )
    
    def validate_progress(self) -> ValidationResult:
        """Validate execution is making progress."""
        latest_checkpoint = self.checkpoint_manager.get_latest_checkpoint()
        
        if not latest_checkpoint:
            return ValidationResult(
                name="progress",
                passed=True,
                reason="No checkpoint data yet"
            )
        
        # Check if progress is being made
        current_progress = latest_checkpoint.get("overall_progress", 0)
        
        # Get progress from 2 minutes ago
        two_min_ago = datetime.now() - timedelta(minutes=2)
        old_checkpoint = self.get_checkpoint_at_time(two_min_ago)
        
        if old_checkpoint:
            old_progress = old_checkpoint.get("overall_progress", 0)
            progress_delta = current_progress - old_progress
            
            # Expect at least 5% progress in 2 minutes
            min_expected_progress = 5.0
            
            return ValidationResult(
                name="progress",
                passed=progress_delta >= min_expected_progress or current_progress >= 95,
                current_progress=current_progress,
                progress_delta=progress_delta,
                reason=f"Progress: {progress_delta:.1f}% in 2 minutes"
            )
        
        return ValidationResult(
            name="progress",
            passed=True,
            reason="Initial progress check"
        )
    
    def validate_error_rate(self) -> ValidationResult:
        """Validate error rate is within acceptable limits."""
        # Get errors from last 2 minutes
        recent_errors = self.get_recent_errors(minutes=2)
        
        error_count = len(recent_errors)
        error_rate = error_count / 120  # Errors per second
        
        # Thresholds
        max_errors = 5  # Max 5 errors in 2 minutes
        max_error_rate = 0.05  # Max 0.05 errors per second
        
        passed = error_count <= max_errors and error_rate <= max_error_rate
        
        return ValidationResult(
            name="error_rate",
            passed=passed,
            error_count=error_count,
            error_rate=error_rate,
            recent_errors=recent_errors[:3],  # First 3 errors
            reason=f"Error rate: {error_count} errors in 2 minutes"
        )
    
    def validate_resource_usage(self) -> ValidationResult:
        """Validate resource usage is within limits."""
        current_usage = self.get_current_resource_usage()
        
        checks = {
            "cpu": current_usage["cpu"] < 90,  # Below 90% CPU
            "memory": current_usage["memory"] < 85,  # Below 85% memory
            "disk_io": current_usage["disk_io"] < 80,  # Below 80% disk I/O
            "network": current_usage["network"] < 75  # Below 75% network
        }
        
        excessive = [k for k, v in checks.items() if not v]
        
        return ValidationResult(
            name="resource_usage",
            passed=len(excessive) == 0,
            usage=current_usage,
            checks=checks,
            reason=f"Excessive usage: {', '.join(excessive)}" if excessive else "Resource usage normal"
        )
    
    def validate_stream_health(self) -> ValidationResult:
        """Validate all streams are healthy."""
        latest_checkpoint = self.checkpoint_manager.get_latest_checkpoint()
        
        if not latest_checkpoint:
            return ValidationResult(
                name="stream_health",
                passed=True,
                reason="No stream data yet"
            )
        
        streams = latest_checkpoint.get("streams", {}).get("details", [])
        
        unhealthy = []
        for stream in streams:
            if stream["status"] in ["stuck", "failed", "blocked"]:
                unhealthy.append({
                    "id": stream["id"],
                    "status": stream["status"],
                    "blockers": stream.get("blockers", [])
                })
        
        return ValidationResult(
            name="stream_health",
            passed=len(unhealthy) == 0,
            unhealthy_streams=unhealthy,
            total_streams=len(streams),
            reason=f"{len(unhealthy)} unhealthy streams" if unhealthy else "All streams healthy"
        )
    
    def validate_partial_output(self) -> ValidationResult:
        """Validate partial output is being generated correctly."""
        latest_checkpoint = self.checkpoint_manager.get_latest_checkpoint()
        
        if not latest_checkpoint:
            return ValidationResult(
                name="partial_output",
                passed=True,
                reason="No output data yet"
            )
        
        partial_results = latest_checkpoint.get("partial_results_summary", {})
        total_results = partial_results.get("total_results", 0)
        
        # Expect some partial results after 2 minutes
        min_expected_results = 1
        
        return ValidationResult(
            name="partial_output",
            passed=total_results >= min_expected_results,
            total_results=total_results,
            by_stream=partial_results.get("by_stream", {}),
            reason=f"Generated {total_results} partial results"
        )
    
    def validate_no_deadlocks(self) -> ValidationResult:
        """Validate no deadlocks are present."""
        # Check for circular dependencies or resource locks
        deadlock_indicators = self.detect_deadlock_patterns()
        
        return ValidationResult(
            name="deadlocks",
            passed=len(deadlock_indicators) == 0,
            indicators=deadlock_indicators,
            reason=f"Potential deadlock detected" if deadlock_indicators else "No deadlocks detected"
        )
    
    def validate_no_memory_leaks(self) -> ValidationResult:
        """Validate no memory leaks are occurring."""
        memory_trend = self.analyze_memory_trend(minutes=2)
        
        # Check if memory is growing linearly
        is_leaking = memory_trend["slope"] > 10  # MB per minute
        
        return ValidationResult(
            name="memory_leaks",
            passed=not is_leaking,
            memory_trend=memory_trend,
            reason=f"Memory growing at {memory_trend['slope']:.1f} MB/min" if is_leaking else "No memory leak detected"
        )
    
    def validate_no_infinite_loops(self) -> ValidationResult:
        """Validate no infinite loops are occurring."""
        # Check for repeated operations
        repeated_ops = self.detect_repeated_operations(threshold=5)
        
        return ValidationResult(
            name="infinite_loops",
            passed=len(repeated_ops) == 0,
            repeated_operations=repeated_ops,
            reason=f"Potential infinite loop detected" if repeated_ops else "No infinite loops detected"
        )
    
    def handle_validation_failure(self, result: ValidationResult):
        """Handle validation failures with appropriate recovery."""
        print(f"\n[VALIDATION FAILURE] {datetime.now()}")
        print(f"Failed validations: {', '.join(result.failed_checks)}")
        
        # Determine recovery strategy based on failure type
        for check in result.failed_checks:
            if check == "progress":
                self.handle_stuck_progress()
            elif check == "errors":
                self.handle_high_error_rate()
            elif check == "resources":
                self.handle_resource_exhaustion()
            elif check == "stream_health":
                self.handle_unhealthy_streams()
            elif check == "deadlocks":
                self.handle_deadlock()
            elif check == "memory_leaks":
                self.handle_memory_leak()
            elif check == "infinite_loops":
                self.handle_infinite_loop()
```

#### 3. Post-Execution Validation
**Timing**: After execution completes
**Purpose**: Ensure completeness and check for side effects

```python
class PostExecutionValidator:
    """Validates execution completeness and side effects."""
    
    def __init__(self, agent_type: str):
        self.agent_type = agent_type
        self.validation_results = {}
        
    def validate_all(self, execution_result: Dict[str, Any]) -> ValidationResult:
        """Run all post-execution validations."""
        validations = [
            self.validate_completeness(execution_result),
            self.validate_correctness(execution_result),
            self.validate_side_effects(execution_result),
            self.validate_output_quality(execution_result),
            self.validate_performance_metrics(execution_result),
            self.validate_cleanup(execution_result)
        ]
        
        # Run validations
        for validation in validations:
            result = validation
            self.validation_results[result.name] = result
        
        return self.aggregate_results()
    
    def validate_completeness(self, result: Dict) -> ValidationResult:
        """Validate all required outputs are present."""
        required_outputs = result.get("required_outputs", [])
        actual_outputs = result.get("actual_outputs", [])
        
        missing = [o for o in required_outputs if o not in actual_outputs]
        extra = [o for o in actual_outputs if o not in required_outputs]
        
        completeness_score = len([o for o in required_outputs if o in actual_outputs]) / max(len(required_outputs), 1)
        
        return ValidationResult(
            name="completeness",
            passed=len(missing) == 0,
            completeness_score=completeness_score,
            missing_outputs=missing,
            extra_outputs=extra,
            reason=f"Missing outputs: {', '.join(missing)}" if missing else "All outputs complete"
        )
    
    def validate_correctness(self, result: Dict) -> ValidationResult:
        """Validate output correctness."""
        outputs = result.get("outputs", {})
        
        checks = {}
        for output_name, output_data in outputs.items():
            checks[output_name] = self.validate_output_correctness(output_name, output_data)
        
        incorrect = [k for k, v in checks.items() if not v["correct"]]
        
        return ValidationResult(
            name="correctness",
            passed=len(incorrect) == 0,
            checks=checks,
            incorrect_outputs=incorrect,
            reason=f"Incorrect outputs: {', '.join(incorrect)}" if incorrect else "All outputs correct"
        )
    
    def validate_side_effects(self, result: Dict) -> ValidationResult:
        """Check for unexpected side effects."""
        side_effects = []
        
        # Check for unexpected file modifications
        unexpected_files = self.check_unexpected_file_changes(result)
        if unexpected_files:
            side_effects.append({
                "type": "file_modifications",
                "files": unexpected_files
            })
        
        # Check for resource leaks
        resource_leaks = self.check_resource_leaks(result)
        if resource_leaks:
            side_effects.append({
                "type": "resource_leaks",
                "resources": resource_leaks
            })
        
        # Check for orphaned processes
        orphaned_processes = self.check_orphaned_processes(result)
        if orphaned_processes:
            side_effects.append({
                "type": "orphaned_processes",
                "processes": orphaned_processes
            })
        
        # Check for temporary file cleanup
        temp_files = self.check_temp_file_cleanup(result)
        if temp_files:
            side_effects.append({
                "type": "temp_files_not_cleaned",
                "files": temp_files
            })
        
        return ValidationResult(
            name="side_effects",
            passed=len(side_effects) == 0,
            side_effects=side_effects,
            reason=f"Found {len(side_effects)} side effects" if side_effects else "No side effects detected"
        )
    
    def validate_output_quality(self, result: Dict) -> ValidationResult:
        """Validate output quality metrics."""
        outputs = result.get("outputs", {})
        
        quality_checks = {
            "format": self.check_output_format(outputs),
            "size": self.check_output_size(outputs),
            "encoding": self.check_output_encoding(outputs),
            "schema": self.check_output_schema(outputs),
            "consistency": self.check_output_consistency(outputs)
        }
        
        failed_quality = [k for k, v in quality_checks.items() if not v["passed"]]
        
        quality_score = len([v for v in quality_checks.values() if v["passed"]]) / len(quality_checks) * 100
        
        return ValidationResult(
            name="output_quality",
            passed=len(failed_quality) == 0,
            quality_score=quality_score,
            quality_checks=quality_checks,
            failed_checks=failed_quality,
            reason=f"Quality score: {quality_score:.1f}%"
        )
    
    def validate_performance_metrics(self, result: Dict) -> ValidationResult:
        """Validate performance met expectations."""
        metrics = result.get("performance_metrics", {})
        expectations = result.get("performance_expectations", {})
        
        checks = {}
        for metric, expected in expectations.items():
            actual = metrics.get(metric)
            if actual is not None:
                if metric.endswith("_time"):
                    # Time metrics - actual should be less than expected
                    checks[metric] = actual <= expected
                elif metric.endswith("_rate"):
                    # Rate metrics - actual should be greater than expected
                    checks[metric] = actual >= expected
                else:
                    # Other metrics - check within tolerance
                    tolerance = 0.1  # 10% tolerance
                    checks[metric] = abs(actual - expected) / expected <= tolerance
        
        failed_metrics = [k for k, v in checks.items() if not v]
        
        return ValidationResult(
            name="performance_metrics",
            passed=len(failed_metrics) == 0,
            metrics=metrics,
            expectations=expectations,
            checks=checks,
            failed_metrics=failed_metrics,
            reason=f"Failed metrics: {', '.join(failed_metrics)}" if failed_metrics else "Performance expectations met"
        )
    
    def validate_cleanup(self, result: Dict) -> ValidationResult:
        """Validate proper cleanup was performed."""
        cleanup_checks = {
            "temp_files": self.check_temp_files_removed(),
            "locks_released": self.check_locks_released(),
            "connections_closed": self.check_connections_closed(),
            "memory_freed": self.check_memory_freed(),
            "threads_terminated": self.check_threads_terminated()
        }
        
        incomplete_cleanup = [k for k, v in cleanup_checks.items() if not v]
        
        return ValidationResult(
            name="cleanup",
            passed=len(incomplete_cleanup) == 0,
            cleanup_checks=cleanup_checks,
            incomplete=incomplete_cleanup,
            reason=f"Incomplete cleanup: {', '.join(incomplete_cleanup)}" if incomplete_cleanup else "Cleanup complete"
        )
```

### Validation Result Structure

```python
@dataclass
class ValidationResult:
    """Structure for validation results."""
    name: str
    passed: bool
    reason: str
    timestamp: datetime = field(default_factory=datetime.now)
    details: Dict[str, Any] = field(default_factory=dict)
    errors: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    metrics: Dict[str, float] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert to dictionary."""
        return {
            "name": self.name,
            "passed": self.passed,
            "reason": self.reason,
            "timestamp": self.timestamp.isoformat(),
            "details": self.details,
            "errors": self.errors,
            "warnings": self.warnings,
            "metrics": self.metrics
        }
    
    def __str__(self) -> str:
        """String representation."""
        status = "✅ PASSED" if self.passed else "❌ FAILED"
        return f"[{status}] {self.name}: {self.reason}"
```

### Error Detection Mechanisms

#### 1. Pattern-Based Error Detection
```python
class ErrorDetector:
    """Detects errors through pattern matching."""
    
    def __init__(self):
        self.error_patterns = {
            "timeout": r"(timeout|timed out|deadline exceeded)",
            "memory": r"(out of memory|memory exhausted|oom|heap)",
            "permission": r"(permission denied|access denied|forbidden)",
            "network": r"(connection refused|network unreachable|timeout)",
            "file": r"(file not found|no such file|cannot open)",
            "syntax": r"(syntax error|parse error|invalid syntax)",
            "type": r"(type error|type mismatch|incompatible type)",
            "null": r"(null pointer|null reference|undefined)",
            "deadlock": r"(deadlock|circular dependency|waiting for)",
            "infinite": r"(infinite loop|maximum recursion|stack overflow)"
        }
        
    def detect_errors(self, text: str) -> List[Dict[str, Any]]:
        """Detect errors in text output."""
        detected_errors = []
        
        for error_type, pattern in self.error_patterns.items():
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                detected_errors.append({
                    "type": error_type,
                    "pattern": pattern,
                    "match": match.group(),
                    "position": match.span(),
                    "context": text[max(0, match.start()-50):min(len(text), match.end()+50)]
                })
        
        return detected_errors
```

#### 2. Anomaly-Based Error Detection
```python
class AnomalyDetector:
    """Detects errors through anomaly detection."""
    
    def __init__(self):
        self.baseline_metrics = {}
        self.threshold_multiplier = 2.0  # 2x standard deviation
        
    def establish_baseline(self, metrics: List[Dict[str, float]]):
        """Establish baseline metrics from successful runs."""
        for metric_set in metrics:
            for key, value in metric_set.items():
                if key not in self.baseline_metrics:
                    self.baseline_metrics[key] = {
                        "values": [],
                        "mean": 0,
                        "std": 0
                    }
                self.baseline_metrics[key]["values"].append(value)
        
        # Calculate statistics
        for key, data in self.baseline_metrics.items():
            values = data["values"]
            data["mean"] = np.mean(values)
            data["std"] = np.std(values)
    
    def detect_anomalies(self, current_metrics: Dict[str, float]) -> List[Dict[str, Any]]:
        """Detect anomalies in current metrics."""
        anomalies = []
        
        for key, value in current_metrics.items():
            if key in self.baseline_metrics:
                baseline = self.baseline_metrics[key]
                mean = baseline["mean"]
                std = baseline["std"]
                
                # Check if value is outside threshold
                if abs(value - mean) > self.threshold_multiplier * std:
                    anomalies.append({
                        "metric": key,
                        "value": value,
                        "expected_mean": mean,
                        "expected_std": std,
                        "deviation": abs(value - mean) / std,
                        "severity": self.calculate_severity(abs(value - mean) / std)
                    })
        
        return anomalies
    
    def calculate_severity(self, deviation: float) -> str:
        """Calculate anomaly severity."""
        if deviation < 3:
            return "low"
        elif deviation < 5:
            return "medium"
        else:
            return "high"
```

### Validation Criteria Configuration

```yaml
validation_checkpoints:
  enabled: true
  
  pre_execution:
    enabled: true
    timeout: 30  # seconds
    criteria:
      prerequisites:
        required_tools: ["python", "git", "bash"]
        required_files: ["config.yaml", "requirements.txt"]
        required_services: []
        network_connectivity: true
      
      resources:
        cpu_cores: 2
        memory_mb: 1024
        disk_mb: 5000
        file_handles: 100
      
      dependencies:
        - name: "python"
          version: "3.8"
          operator: ">="
        - name: "git"
          version: "2.0"
          operator: ">="
      
      permissions:
        read: ["./src", "./config"]
        write: ["./output", "./logs"]
        execute: ["./scripts"]
      
      environment:
        PATH: "*"
        HOME: "*"
        USER: "*"
  
  during_execution:
    enabled: true
    interval: 120  # 2 minutes
    error_detection_time: 120  # Detect errors within 2 minutes
    
    criteria:
      progress:
        min_progress_per_interval: 5.0  # 5% minimum progress
        stuck_threshold: 600  # 10 minutes no progress
      
      errors:
        max_errors_per_interval: 5
        max_error_rate: 0.05  # errors per second
      
      resources:
        max_cpu_percent: 90
        max_memory_percent: 85
        max_disk_io_percent: 80
        max_network_percent: 75
      
      health:
        max_unhealthy_streams: 0
        max_blocked_duration: 300  # 5 minutes
      
      patterns:
        detect_deadlocks: true
        detect_memory_leaks: true
        detect_infinite_loops: true
        max_repeated_operations: 5
  
  post_execution:
    enabled: true
    timeout: 60  # seconds
    
    criteria:
      completeness:
        require_all_outputs: true
        min_completeness_score: 1.0
      
      correctness:
        validate_output_format: true
        validate_output_schema: true
        validate_output_encoding: true
      
      side_effects:
        check_file_modifications: true
        check_resource_leaks: true
        check_orphaned_processes: true
        check_temp_cleanup: true
      
      quality:
        min_quality_score: 95.0
        check_consistency: true
        check_size_limits: true
      
      performance:
        check_time_limits: true
        check_rate_limits: true
        tolerance: 0.1  # 10% tolerance
      
      cleanup:
        require_temp_cleanup: true
        require_lock_release: true
        require_connection_close: true
        require_memory_free: true
        require_thread_termination: true
```

### Integration with Agent Workflow

```python
def execute_with_validation_checkpoints(agent_type: str, task: Dict[str, Any]):
    """Execute agent with comprehensive validation checkpoints."""
    
    # Initialize validators
    pre_validator = PreExecutionValidator(agent_type)
    during_validator = DuringExecutionValidator(checkpoint_manager)
    post_validator = PostExecutionValidator(agent_type)
    
    # Phase 1: Pre-execution validation
    print("[VALIDATION] Starting pre-execution validation...")
    pre_result = pre_validator.validate_all(task)
    
    if not pre_result.passed:
        print(f"[VALIDATION FAILED] Pre-execution: {pre_result.reason}")
        return {
            "status": "failed",
            "phase": "pre-execution",
            "validation_result": pre_result.to_dict()
        }
    
    print("[VALIDATION] Pre-execution validation PASSED ✅")
    
    # Phase 2: Start execution with during-execution monitoring
    print("[VALIDATION] Starting execution with 2-minute validation intervals...")
    during_validator.start_monitoring()
    
    try:
        # Execute the actual task
        execution_result = execute_agent_task(agent_type, task)
        
    finally:
        # Stop during-execution monitoring
        during_validator.stop_monitoring()
    
    # Check during-execution validation history
    validation_failures = [v for v in during_validator.validation_history if not v["result"].passed]
    if validation_failures:
        print(f"[VALIDATION WARNING] {len(validation_failures)} validation failures during execution")
    
    # Phase 3: Post-execution validation
    print("[VALIDATION] Starting post-execution validation...")
    post_result = post_validator.validate_all(execution_result)
    
    if not post_result.passed:
        print(f"[VALIDATION FAILED] Post-execution: {post_result.reason}")
        return {
            "status": "completed_with_issues",
            "phase": "post-execution",
            "execution_result": execution_result,
            "validation_result": post_result.to_dict()
        }
    
    print("[VALIDATION] Post-execution validation PASSED ✅")
    
    return {
        "status": "success",
        "execution_result": execution_result,
        "validation_summary": {
            "pre_execution": pre_result.to_dict(),
            "during_execution": {
                "total_validations": len(during_validator.validation_history),
                "failures": len(validation_failures)
            },
            "post_execution": post_result.to_dict()
        }
    }
```

### Validation Dashboard

```
[VALIDATION CHECKPOINT STATUS] 2025-08-17 10:30:00
Agent: Implementation
Phase: During Execution

Pre-Execution: ✅ PASSED (30s)
  Prerequisites: ✅ All met
  Resources: ✅ Adequate
  Dependencies: ✅ Satisfied
  Permissions: ✅ Granted
  Environment: ✅ Configured
  Input Data: ✅ Valid

During Execution: ⏳ MONITORING
  Interval: Every 2 minutes
  Last Check: 10:28:00
  
  Progress: ✅ 12% in last 2 min
  Error Rate: ✅ 1 error (within limit)
  Resources: ⚠️ CPU at 87%
  Stream Health: ✅ All healthy
  Partial Output: ✅ 15 results
  Deadlocks: ✅ None detected
  Memory Leaks: ✅ None detected
  Infinite Loops: ✅ None detected
  
  Next Check: 10:30:00

Post-Execution: ⏸️ PENDING

Error Detection Active:
  Pattern Matching: ENABLED
  Anomaly Detection: ENABLED
  Detected Issues: 1 (handled)
```

## Summary

This validation checkpoint system provides:

1. **Pre-execution validation** (0-30 seconds) to verify all prerequisites
2. **During-execution validation** (every 2 minutes) to catch errors early
3. **Post-execution validation** to ensure completeness and check side effects
4. **Comprehensive error detection** within 2 minutes using pattern and anomaly detection
5. **Clear validation criteria** with configurable thresholds
6. **Automatic recovery mechanisms** for validation failures
7. **Detailed validation reporting** and dashboards

The system ensures robust execution with early error detection and comprehensive quality assurance throughout the agent workflow.