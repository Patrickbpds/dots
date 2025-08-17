# Comprehensive Timeout Handling Implementation

## Overview
This document implements Week 3 Task 2: Comprehensive timeout handling with soft/hard timeouts, configurable values per task type, and clear escalation paths.

## 1. Core Timeout Architecture

### 1.1 TimeoutManager Class

```python
import time
import threading
import signal
import json
import uuid
from datetime import datetime, timedelta
from enum import Enum
from typing import Dict, List, Optional, Any, Callable
from dataclasses import dataclass, field

class TimeoutLevel(Enum):
    """Timeout severity levels."""
    SOFT = "soft"        # Progress check without termination
    HARD = "hard"        # Terminate and retry with refined scope
    CRITICAL = "critical" # Immediate escalation to user

class TimeoutAction(Enum):
    """Actions to take on timeout."""
    CHECK_PROGRESS = "check_progress"
    REDUCE_SCOPE = "reduce_scope"
    RETRY_TASK = "retry_task"
    TERMINATE = "terminate"
    ESCALATE = "escalate"
    FALLBACK = "fallback"

@dataclass
class TimeoutConfig:
    """Configuration for timeout handling."""
    task_type: str
    soft_timeout: int = 300      # 5 minutes default
    hard_timeout: int = 600      # 10 minutes default
    critical_timeout: int = 900  # 15 minutes default
    max_retries: int = 2
    scope_reduction_factor: float = 0.5
    fallback_strategy: str = "sequential"
    escalation_enabled: bool = True
    custom_handlers: Dict[TimeoutLevel, Callable] = field(default_factory=dict)

class TimeoutManager:
    """Comprehensive timeout management system."""
    
    def __init__(self, agent_type: str):
        self.agent_type = agent_type
        self.active_tasks = {}
        self.timeout_configs = {}
        self.timeout_history = []
        self.lock = threading.RLock()
        self.monitor_thread = None
        self.running = False
        self.default_config = self._get_default_config()
        
    def _get_default_config(self) -> TimeoutConfig:
        """Get default timeout configuration based on agent type."""
        configs = {
            "plan": TimeoutConfig(
                task_type="planning",
                soft_timeout=300,   # 5 min
                hard_timeout=600,   # 10 min
                critical_timeout=900 # 15 min
            ),
            "implement": TimeoutConfig(
                task_type="implementation",
                soft_timeout=300,
                hard_timeout=600,
                critical_timeout=1200 # 20 min
            ),
            "research": TimeoutConfig(
                task_type="research",
                soft_timeout=240,   # 4 min
                hard_timeout=480,   # 8 min
                critical_timeout=720 # 12 min
            ),
            "debug": TimeoutConfig(
                task_type="debugging",
                soft_timeout=180,   # 3 min (faster for debug)
                hard_timeout=360,   # 6 min
                critical_timeout=600 # 10 min
            ),
            "test": TimeoutConfig(
                task_type="testing",
                soft_timeout=300,
                hard_timeout=600,
                critical_timeout=900
            ),
            "blueprint": TimeoutConfig(
                task_type="blueprint",
                soft_timeout=300,
                hard_timeout=600,
                critical_timeout=900
            )
        }
        return configs.get(self.agent_type, TimeoutConfig(task_type="default"))
    
    def start_monitoring(self):
        """Start the timeout monitoring system."""
        with self.lock:
            if not self.running:
                self.running = True
                self.monitor_thread = threading.Thread(target=self._monitor_loop)
                self.monitor_thread.daemon = True
                self.monitor_thread.start()
    
    def stop_monitoring(self):
        """Stop the timeout monitoring system."""
        with self.lock:
            self.running = False
            if self.monitor_thread:
                self.monitor_thread.join(timeout=5)
    
    def register_task(self, task_id: str, task_config: Dict[str, Any], 
                     timeout_config: Optional[TimeoutConfig] = None):
        """Register a task for timeout monitoring."""
        with self.lock:
            config = timeout_config or self.default_config
            
            self.active_tasks[task_id] = {
                "id": task_id,
                "type": task_config.get("type", "unknown"),
                "name": task_config.get("name", "Unnamed Task"),
                "started_at": datetime.now(),
                "last_progress": datetime.now(),
                "progress_percentage": 0,
                "timeout_config": config,
                "soft_timeout_triggered": False,
                "hard_timeout_triggered": False,
                "retry_count": 0,
                "original_scope": task_config.get("scope", {}),
                "current_scope": task_config.get("scope", {}),
                "status": "running",
                "partial_results": {},
                "metadata": task_config.get("metadata", {})
            }
            
            # Set up timeout handlers
            self._schedule_timeouts(task_id, config)
    
    def update_task_progress(self, task_id: str, progress: int, 
                            partial_results: Optional[Dict] = None):
        """Update task progress to reset timeout counters."""
        with self.lock:
            if task_id not in self.active_tasks:
                return False
            
            task = self.active_tasks[task_id]
            old_progress = task["progress_percentage"]
            task["progress_percentage"] = min(100, max(0, progress))
            
            # Reset timeout if meaningful progress made
            if task["progress_percentage"] > old_progress:
                task["last_progress"] = datetime.now()
                task["soft_timeout_triggered"] = False
                # Reschedule timeouts based on new progress
                self._reschedule_timeouts(task_id)
            
            if partial_results:
                task["partial_results"].update(partial_results)
            
            return True
    
    def _schedule_timeouts(self, task_id: str, config: TimeoutConfig):
        """Schedule timeout checks for a task."""
        # Schedule soft timeout
        threading.Timer(
            config.soft_timeout,
            self._handle_soft_timeout,
            args=[task_id]
        ).start()
        
        # Schedule hard timeout
        threading.Timer(
            config.hard_timeout,
            self._handle_hard_timeout,
            args=[task_id]
        ).start()
        
        # Schedule critical timeout
        if config.critical_timeout:
            threading.Timer(
                config.critical_timeout,
                self._handle_critical_timeout,
                args=[task_id]
            ).start()
    
    def _reschedule_timeouts(self, task_id: str):
        """Reschedule timeouts after progress update."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            config = task["timeout_config"]
            elapsed = (datetime.now() - task["last_progress"]).total_seconds()
            
            # Only reschedule if we haven't hit timeouts yet
            if not task["soft_timeout_triggered"] and elapsed < config.soft_timeout:
                remaining = config.soft_timeout - elapsed
                threading.Timer(
                    remaining,
                    self._handle_soft_timeout,
                    args=[task_id]
                ).start()
    
    def _handle_soft_timeout(self, task_id: str):
        """Handle soft timeout - check progress without termination."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            if task["soft_timeout_triggered"]:
                return
            
            task["soft_timeout_triggered"] = True
            
            # Log timeout event
            self._log_timeout_event(task_id, TimeoutLevel.SOFT)
            
            # Check if task is making progress
            time_since_progress = (datetime.now() - task["last_progress"]).total_seconds()
            
            if time_since_progress < 60:  # Progress within last minute
                print(f"[SOFT TIMEOUT] Task {task_id} is still progressing ({task['progress_percentage']}%)")
                # Give more time
                threading.Timer(
                    60,
                    self._handle_soft_timeout,
                    args=[task_id]
                ).start()
            else:
                print(f"[SOFT TIMEOUT] Task {task_id} appears stuck at {task['progress_percentage']}%")
                # Trigger progress check
                self._check_task_progress(task_id)
    
    def _handle_hard_timeout(self, task_id: str):
        """Handle hard timeout - terminate and retry with reduced scope."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            if task["hard_timeout_triggered"]:
                return
            
            task["hard_timeout_triggered"] = True
            
            # Log timeout event
            self._log_timeout_event(task_id, TimeoutLevel.HARD)
            
            print(f"[HARD TIMEOUT] Task {task_id} exceeded hard timeout")
            
            # Check retry count
            if task["retry_count"] < task["timeout_config"].max_retries:
                # Reduce scope and retry
                self._retry_with_reduced_scope(task_id)
            else:
                # Max retries exceeded, escalate
                self._escalate_task(task_id, "Max retries exceeded after hard timeout")
    
    def _handle_critical_timeout(self, task_id: str):
        """Handle critical timeout - immediate escalation."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            
            # Log timeout event
            self._log_timeout_event(task_id, TimeoutLevel.CRITICAL)
            
            print(f"[CRITICAL TIMEOUT] Task {task_id} exceeded critical timeout")
            
            # Immediate escalation
            self._escalate_task(task_id, "Critical timeout exceeded")
    
    def _check_task_progress(self, task_id: str):
        """Check task progress and determine next action."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            
            # Query task status
            status_request = {
                "task_id": task_id,
                "action": TimeoutAction.CHECK_PROGRESS,
                "timestamp": datetime.now().isoformat()
            }
            
            print(f"[PROGRESS CHECK] Querying status of task {task_id}")
            print(f"  Current Progress: {task['progress_percentage']}%")
            print(f"  Partial Results: {len(task['partial_results'])} items")
            
            # Determine action based on progress
            if task["progress_percentage"] > 50:
                # Significant progress, allow continuation
                print(f"  Decision: Continue with extended timeout")
                task["soft_timeout_triggered"] = False
                self._reschedule_timeouts(task_id)
            elif task["partial_results"]:
                # Some results available, try to salvage
                print(f"  Decision: Salvage partial results and continue")
                self._salvage_partial_results(task_id)
            else:
                # No meaningful progress
                print(f"  Decision: Terminate and retry with reduced scope")
                self._retry_with_reduced_scope(task_id)
    
    def _retry_with_reduced_scope(self, task_id: str):
        """Retry task with reduced scope."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            task["retry_count"] += 1
            
            # Calculate reduced scope
            reduction_factor = task["timeout_config"].scope_reduction_factor
            original_scope = task["original_scope"]
            
            # Reduce scope based on task type
            reduced_scope = self._calculate_reduced_scope(
                original_scope, 
                reduction_factor,
                task["type"]
            )
            
            task["current_scope"] = reduced_scope
            
            print(f"[RETRY] Retrying task {task_id} with reduced scope")
            print(f"  Retry Count: {task['retry_count']}/{task['timeout_config'].max_retries}")
            print(f"  Scope Reduction: {int((1-reduction_factor)*100)}%")
            
            # Reset timeout flags
            task["soft_timeout_triggered"] = False
            task["hard_timeout_triggered"] = False
            task["last_progress"] = datetime.now()
            
            # Reschedule timeouts for retry
            self._schedule_timeouts(task_id, task["timeout_config"])
            
            # Execute retry
            self._execute_retry(task_id, reduced_scope)
    
    def _calculate_reduced_scope(self, original_scope: Dict, 
                                 reduction_factor: float, 
                                 task_type: str) -> Dict:
        """Calculate reduced scope based on task type."""
        reduced_scope = original_scope.copy()
        
        if task_type == "implementation":
            # Reduce number of files or features
            if "files" in reduced_scope:
                file_count = len(reduced_scope["files"])
                reduced_count = max(1, int(file_count * reduction_factor))
                reduced_scope["files"] = reduced_scope["files"][:reduced_count]
            
            if "features" in reduced_scope:
                feature_count = len(reduced_scope["features"])
                reduced_count = max(1, int(feature_count * reduction_factor))
                reduced_scope["features"] = reduced_scope["features"][:reduced_count]
        
        elif task_type == "research":
            # Reduce search depth or sources
            if "max_depth" in reduced_scope:
                reduced_scope["max_depth"] = max(1, int(reduced_scope["max_depth"] * reduction_factor))
            
            if "sources" in reduced_scope:
                source_count = len(reduced_scope["sources"])
                reduced_count = max(1, int(source_count * reduction_factor))
                reduced_scope["sources"] = reduced_scope["sources"][:reduced_count]
        
        elif task_type == "testing":
            # Reduce test coverage or test count
            if "coverage_target" in reduced_scope:
                reduced_scope["coverage_target"] = max(50, int(reduced_scope["coverage_target"] * reduction_factor))
            
            if "test_files" in reduced_scope:
                test_count = len(reduced_scope["test_files"])
                reduced_count = max(1, int(test_count * reduction_factor))
                reduced_scope["test_files"] = reduced_scope["test_files"][:reduced_count]
        
        return reduced_scope
    
    def _salvage_partial_results(self, task_id: str):
        """Salvage partial results from a timed-out task."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            partial_results = task["partial_results"]
            
            if partial_results:
                # Save partial results
                salvage_report = {
                    "task_id": task_id,
                    "timestamp": datetime.now().isoformat(),
                    "progress_at_timeout": task["progress_percentage"],
                    "partial_results": partial_results,
                    "salvageable": True
                }
                
                print(f"[SALVAGE] Saving partial results for task {task_id}")
                print(f"  Items Salvaged: {len(partial_results)}")
                print(f"  Progress Achieved: {task['progress_percentage']}%")
                
                # Store salvage report
                self._store_salvage_report(salvage_report)
                
                # Continue with reduced scope for remaining work
                remaining_scope = self._calculate_remaining_scope(
                    task["original_scope"],
                    partial_results
                )
                
                if remaining_scope:
                    task["current_scope"] = remaining_scope
                    self._execute_retry(task_id, remaining_scope)
                else:
                    # Mark as partially complete
                    task["status"] = "partial_complete"
                    self._complete_task(task_id, partial=True)
    
    def _calculate_remaining_scope(self, original_scope: Dict, 
                                   completed_work: Dict) -> Dict:
        """Calculate remaining scope after partial completion."""
        remaining_scope = original_scope.copy()
        
        # Remove completed items from scope
        if "files" in remaining_scope and "processed_files" in completed_work:
            remaining_files = [f for f in remaining_scope["files"] 
                             if f not in completed_work["processed_files"]]
            remaining_scope["files"] = remaining_files
        
        if "tasks" in remaining_scope and "completed_tasks" in completed_work:
            remaining_tasks = [t for t in remaining_scope["tasks"] 
                             if t not in completed_work["completed_tasks"]]
            remaining_scope["tasks"] = remaining_tasks
        
        return remaining_scope if any(remaining_scope.values()) else {}
    
    def _escalate_task(self, task_id: str, reason: str):
        """Escalate task to user intervention."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            task["status"] = "escalated"
            
            escalation_report = {
                "task_id": task_id,
                "task_name": task["name"],
                "timestamp": datetime.now().isoformat(),
                "reason": reason,
                "progress_at_escalation": task["progress_percentage"],
                "retry_count": task["retry_count"],
                "partial_results": len(task["partial_results"]),
                "elapsed_time": (datetime.now() - task["started_at"]).total_seconds(),
                "action_required": "manual_intervention"
            }
            
            print(f"\n[ESCALATION] Task requires user intervention")
            print(f"  Task: {task['name']} ({task_id})")
            print(f"  Reason: {reason}")
            print(f"  Progress: {task['progress_percentage']}%")
            print(f"  Retries: {task['retry_count']}")
            print(f"  Action Required: Please investigate and manually resolve")
            
            # Store escalation report
            self._store_escalation_report(escalation_report)
            
            # Invoke fallback strategy if configured
            if task["timeout_config"].fallback_strategy:
                self._execute_fallback_strategy(task_id)
    
    def _execute_fallback_strategy(self, task_id: str):
        """Execute fallback strategy for escalated task."""
        with self.lock:
            if task_id not in self.active_tasks:
                return
            
            task = self.active_tasks[task_id]
            strategy = task["timeout_config"].fallback_strategy
            
            print(f"[FALLBACK] Executing {strategy} strategy for task {task_id}")
            
            if strategy == "sequential":
                # Switch to sequential execution
                print("  Switching to sequential execution mode")
                self._switch_to_sequential(task_id)
            elif strategy == "skip":
                # Skip the task and continue
                print("  Skipping task and continuing")
                self._skip_task(task_id)
            elif strategy == "partial":
                # Accept partial results and continue
                print("  Accepting partial results")
                self._complete_task(task_id, partial=True)
    
    def _execute_retry(self, task_id: str, scope: Dict):
        """Execute task retry with new scope."""
        # This would interface with the actual task execution system
        print(f"[EXECUTE] Retrying task {task_id} with scope: {json.dumps(scope, indent=2)}")
    
    def _switch_to_sequential(self, task_id: str):
        """Switch task to sequential execution mode."""
        # This would interface with the execution system
        print(f"[SEQUENTIAL] Task {task_id} switched to sequential mode")
    
    def _skip_task(self, task_id: str):
        """Skip a task and mark as skipped."""
        with self.lock:
            if task_id in self.active_tasks:
                self.active_tasks[task_id]["status"] = "skipped"
    
    def _complete_task(self, task_id: str, partial: bool = False):
        """Mark task as complete (fully or partially)."""
        with self.lock:
            if task_id in self.active_tasks:
                status = "partial_complete" if partial else "complete"
                self.active_tasks[task_id]["status"] = status
    
    def _log_timeout_event(self, task_id: str, level: TimeoutLevel):
        """Log timeout event for analysis."""
        event = {
            "task_id": task_id,
            "level": level.value,
            "timestamp": datetime.now().isoformat(),
            "task_info": self.active_tasks.get(task_id, {})
        }
        self.timeout_history.append(event)
    
    def _store_salvage_report(self, report: Dict):
        """Store salvage report for later analysis."""
        filepath = f"/tmp/salvage_{report['task_id']}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
    
    def _store_escalation_report(self, report: Dict):
        """Store escalation report for user review."""
        filepath = f"/tmp/escalation_{report['task_id']}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filepath, 'w') as f:
            json.dump(report, f, indent=2)
    
    def _monitor_loop(self):
        """Main monitoring loop for timeout management."""
        while self.running:
            try:
                with self.lock:
                    now = datetime.now()
                    for task_id, task in list(self.active_tasks.items()):
                        if task["status"] in ["complete", "partial_complete", "skipped", "escalated"]:
                            continue
                        
                        # Check for stalled tasks
                        time_since_progress = (now - task["last_progress"]).total_seconds()
                        
                        # Additional monitoring logic here
                        if time_since_progress > 120 and not task["soft_timeout_triggered"]:
                            print(f"[MONITOR] Task {task_id} showing slow progress")
                
                time.sleep(30)  # Check every 30 seconds
                
            except Exception as e:
                print(f"[MONITOR ERROR] {e}")
                time.sleep(30)
    
    def get_timeout_report(self) -> Dict[str, Any]:
        """Generate comprehensive timeout report."""
        with self.lock:
            active_count = sum(1 for t in self.active_tasks.values() 
                             if t["status"] == "running")
            timed_out_count = sum(1 for t in self.active_tasks.values() 
                                if t["soft_timeout_triggered"] or t["hard_timeout_triggered"])
            escalated_count = sum(1 for t in self.active_tasks.values() 
                                if t["status"] == "escalated")
            
            return {
                "timestamp": datetime.now().isoformat(),
                "active_tasks": active_count,
                "timed_out_tasks": timed_out_count,
                "escalated_tasks": escalated_count,
                "timeout_events": len(self.timeout_history),
                "tasks": [
                    {
                        "id": task["id"],
                        "name": task["name"],
                        "status": task["status"],
                        "progress": task["progress_percentage"],
                        "soft_timeout": task["soft_timeout_triggered"],
                        "hard_timeout": task["hard_timeout_triggered"],
                        "retries": task["retry_count"]
                    }
                    for task in self.active_tasks.values()
                ]
            }
```

## 2. Task-Specific Timeout Configurations

### 2.1 Agent-Specific Configurations

```python
class AgentTimeoutConfigurations:
    """Predefined timeout configurations for different agent types."""
    
    @staticmethod
    def get_planning_config() -> Dict[str, TimeoutConfig]:
        """Timeout configurations for planning agent tasks."""
        return {
            "analysis": TimeoutConfig(
                task_type="analysis",
                soft_timeout=300,    # 5 min
                hard_timeout=600,    # 10 min
                critical_timeout=900, # 15 min
                max_retries=2,
                scope_reduction_factor=0.6,
                fallback_strategy="sequential"
            ),
            "research": TimeoutConfig(
                task_type="research",
                soft_timeout=240,    # 4 min
                hard_timeout=480,    # 8 min
                critical_timeout=720, # 12 min
                max_retries=3,
                scope_reduction_factor=0.5,
                fallback_strategy="partial"
            ),
            "design": TimeoutConfig(
                task_type="design",
                soft_timeout=360,    # 6 min
                hard_timeout=720,    # 12 min
                critical_timeout=1080, # 18 min
                max_retries=1,
                scope_reduction_factor=0.7,
                fallback_strategy="sequential"
            )
        }
    
    @staticmethod
    def get_implementation_config() -> Dict[str, TimeoutConfig]:
        """Timeout configurations for implementation agent tasks."""
        return {
            "code_generation": TimeoutConfig(
                task_type="code_generation",
                soft_timeout=300,     # 5 min
                hard_timeout=600,     # 10 min
                critical_timeout=1200, # 20 min
                max_retries=2,
                scope_reduction_factor=0.5,
                fallback_strategy="partial"
            ),
            "testing": TimeoutConfig(
                task_type="testing",
                soft_timeout=240,    # 4 min
                hard_timeout=480,    # 8 min
                critical_timeout=720, # 12 min
                max_retries=3,
                scope_reduction_factor=0.6,
                fallback_strategy="skip"
            ),
            "validation": TimeoutConfig(
                task_type="validation",
                soft_timeout=180,    # 3 min
                hard_timeout=360,    # 6 min
                critical_timeout=540, # 9 min
                max_retries=2,
                scope_reduction_factor=0.7,
                fallback_strategy="partial"
            ),
            "documentation": TimeoutConfig(
                task_type="documentation",
                soft_timeout=300,    # 5 min
                hard_timeout=600,    # 10 min
                critical_timeout=900, # 15 min
                max_retries=1,
                scope_reduction_factor=0.8,
                fallback_strategy="skip"
            )
        }
    
    @staticmethod
    def get_debug_config() -> Dict[str, TimeoutConfig]:
        """Timeout configurations for debug agent tasks."""
        return {
            "diagnostics": TimeoutConfig(
                task_type="diagnostics",
                soft_timeout=120,    # 2 min (faster for debug)
                hard_timeout=240,    # 4 min
                critical_timeout=360, # 6 min
                max_retries=3,
                scope_reduction_factor=0.5,
                fallback_strategy="sequential"
            ),
            "log_analysis": TimeoutConfig(
                task_type="log_analysis",
                soft_timeout=180,    # 3 min
                hard_timeout=360,    # 6 min
                critical_timeout=540, # 9 min
                max_retries=2,
                scope_reduction_factor=0.4,
                fallback_strategy="partial"
            ),
            "hypothesis_testing": TimeoutConfig(
                task_type="hypothesis_testing",
                soft_timeout=240,    # 4 min
                hard_timeout=480,    # 8 min
                critical_timeout=720, # 12 min
                max_retries=2,
                scope_reduction_factor=0.6,
                fallback_strategy="sequential"
            ),
            "fix_validation": TimeoutConfig(
                task_type="fix_validation",
                soft_timeout=180,    # 3 min
                hard_timeout=360,    # 6 min
                critical_timeout=600, # 10 min
                max_retries=1,
                scope_reduction_factor=0.7,
                fallback_strategy="partial"
            )
        }
    
    @staticmethod
    def get_test_config() -> Dict[str, TimeoutConfig]:
        """Timeout configurations for test agent tasks."""
        return {
            "unit_test_generation": TimeoutConfig(
                task_type="unit_test_generation",
                soft_timeout=300,    # 5 min
                hard_timeout=600,    # 10 min
                critical_timeout=900, # 15 min
                max_retries=2,
                scope_reduction_factor=0.5,
                fallback_strategy="partial"
            ),
            "integration_testing": TimeoutConfig(
                task_type="integration_testing",
                soft_timeout=360,     # 6 min
                hard_timeout=720,     # 12 min
                critical_timeout=1080, # 18 min
                max_retries=1,
                scope_reduction_factor=0.6,
                fallback_strategy="skip"
            ),
            "coverage_analysis": TimeoutConfig(
                task_type="coverage_analysis",
                soft_timeout=240,    # 4 min
                hard_timeout=480,    # 8 min
                critical_timeout=720, # 12 min
                max_retries=2,
                scope_reduction_factor=0.7,
                fallback_strategy="partial"
            )
        }
```

## 3. Escalation Paths and Recovery Strategies

### 3.1 Escalation Framework

```python
class EscalationFramework:
    """Framework for handling timeout escalations."""
    
    def __init__(self):
        self.escalation_levels = []
        self.escalation_handlers = {}
        self.escalation_history = []
        
    def define_escalation_path(self):
        """Define the escalation path for timeout handling."""
        self.escalation_levels = [
            {
                "level": 1,
                "name": "Soft Timeout",
                "trigger": "5 minutes no progress",
                "action": "Progress check",
                "handler": self.handle_soft_escalation
            },
            {
                "level": 2,
                "name": "Hard Timeout",
                "trigger": "10 minutes no completion",
                "action": "Terminate and retry with reduced scope",
                "handler": self.handle_hard_escalation
            },
            {
                "level": 3,
                "name": "Critical Timeout",
                "trigger": "15 minutes total",
                "action": "Escalate to user",
                "handler": self.handle_critical_escalation
            },
            {
                "level": 4,
                "name": "Emergency",
                "trigger": "System resource exhaustion",
                "action": "Immediate termination",
                "handler": self.handle_emergency_escalation
            }
        ]
    
    def handle_soft_escalation(self, task_info: Dict) -> Dict:
        """Handle soft timeout escalation."""
        return {
            "action": "check_progress",
            "strategy": "query_status",
            "continue_if": "progress > 25%",
            "fallback": "extend_timeout",
            "report": {
                "level": "INFO",
                "message": f"Task {task_info['id']} reached soft timeout",
                "recommendation": "Monitor closely"
            }
        }
    
    def handle_hard_escalation(self, task_info: Dict) -> Dict:
        """Handle hard timeout escalation."""
        return {
            "action": "terminate_and_retry",
            "strategy": "reduce_scope",
            "scope_reduction": 0.5,
            "max_retries": 2,
            "fallback": "sequential_execution",
            "report": {
                "level": "WARNING",
                "message": f"Task {task_info['id']} reached hard timeout",
                "recommendation": "Retry with reduced scope"
            }
        }
    
    def handle_critical_escalation(self, task_info: Dict) -> Dict:
        """Handle critical timeout escalation."""
        return {
            "action": "escalate_to_user",
            "strategy": "immediate_alert",
            "preserve": "partial_results",
            "fallback": "manual_intervention",
            "report": {
                "level": "ERROR",
                "message": f"Task {task_info['id']} reached critical timeout",
                "recommendation": "User intervention required"
            }
        }
    
    def handle_emergency_escalation(self, task_info: Dict) -> Dict:
        """Handle emergency escalation."""
        return {
            "action": "emergency_shutdown",
            "strategy": "immediate_termination",
            "preserve": "critical_data_only",
            "fallback": "system_recovery",
            "report": {
                "level": "CRITICAL",
                "message": f"Task {task_info['id']} causing system instability",
                "recommendation": "Immediate termination and investigation"
            }
        }
```

### 3.2 Recovery Strategies

```python
class RecoveryStrategies:
    """Recovery strategies for timeout scenarios."""
    
    @staticmethod
    def progressive_scope_reduction(original_scope: Dict, 
                                   iteration: int) -> Dict:
        """Progressively reduce scope with each retry."""
        reduction_factors = [1.0, 0.7, 0.5, 0.3, 0.1]
        factor = reduction_factors[min(iteration, len(reduction_factors)-1)]
        
        reduced_scope = {}
        for key, value in original_scope.items():
            if isinstance(value, list):
                reduced_count = max(1, int(len(value) * factor))
                reduced_scope[key] = value[:reduced_count]
            elif isinstance(value, (int, float)):
                reduced_scope[key] = type(value)(value * factor)
            else:
                reduced_scope[key] = value
        
        return reduced_scope
    
    @staticmethod
    def intelligent_task_splitting(task: Dict) -> List[Dict]:
        """Split a large task into smaller, manageable subtasks."""
        subtasks = []
        
        if "files" in task and len(task["files"]) > 10:
            # Split by files
            chunk_size = 5
            for i in range(0, len(task["files"]), chunk_size):
                subtask = task.copy()
                subtask["files"] = task["files"][i:i+chunk_size]
                subtask["id"] = f"{task['id']}_part_{i//chunk_size}"
                subtasks.append(subtask)
        
        elif "operations" in task and len(task["operations"]) > 5:
            # Split by operations
            for i, operation in enumerate(task["operations"]):
                subtask = task.copy()
                subtask["operations"] = [operation]
                subtask["id"] = f"{task['id']}_op_{i}"
                subtasks.append(subtask)
        
        else:
            # Can't split further
            subtasks = [task]
        
        return subtasks
    
    @staticmethod
    def fallback_to_sequential(parallel_tasks: List[Dict]) -> List[Dict]:
        """Convert parallel tasks to sequential execution."""
        sequential_tasks = []
        
        for i, task in enumerate(parallel_tasks):
            seq_task = task.copy()
            seq_task["execution_mode"] = "sequential"
            seq_task["priority"] = i
            seq_task["dependencies"] = [sequential_tasks[-1]["id"]] if sequential_tasks else []
            sequential_tasks.append(seq_task)
        
        return sequential_tasks
    
    @staticmethod
    def salvage_partial_results(task: Dict, 
                               partial_results: Dict) -> Dict:
        """Salvage and structure partial results."""
        salvaged = {
            "task_id": task["id"],
            "original_scope": task.get("scope", {}),
            "completed_percentage": task.get("progress", 0),
            "salvaged_results": partial_results,
            "remaining_work": {},
            "recommendations": []
        }
        
        # Calculate remaining work
        if "files" in task and "processed_files" in partial_results:
            remaining_files = set(task["files"]) - set(partial_results["processed_files"])
            salvaged["remaining_work"]["files"] = list(remaining_files)
        
        # Add recommendations
        if salvaged["completed_percentage"] > 75:
            salvaged["recommendations"].append("Consider accepting partial results")
        elif salvaged["completed_percentage"] > 50:
            salvaged["recommendations"].append("Retry with remaining scope only")
        else:
            salvaged["recommendations"].append("Full retry recommended")
        
        return salvaged
```

## 4. Integration with Agent System

### 4.1 Agent Integration

```python
def integrate_timeout_handling(agent_type: str, task: Dict) -> Any:
    """Integrate timeout handling with agent execution."""
    
    # Initialize timeout manager
    timeout_manager = TimeoutManager(agent_type)
    timeout_manager.start_monitoring()
    
    # Get task-specific timeout configuration
    if agent_type == "plan":
        configs = AgentTimeoutConfigurations.get_planning_config()
    elif agent_type == "implement":
        configs = AgentTimeoutConfigurations.get_implementation_config()
    elif agent_type == "debug":
        configs = AgentTimeoutConfigurations.get_debug_config()
    elif agent_type == "test":
        configs = AgentTimeoutConfigurations.get_test_config()
    else:
        configs = {}
    
    # Register task with appropriate timeout config
    task_type = task.get("type", "default")
    timeout_config = configs.get(task_type, TimeoutConfig(task_type=task_type))
    
    task_id = str(uuid.uuid4())
    timeout_manager.register_task(task_id, task, timeout_config)
    
    try:
        # Execute task with timeout monitoring
        result = execute_task_with_monitoring(task, task_id, timeout_manager)
        return result
        
    finally:
        # Stop monitoring
        timeout_manager.stop_monitoring()
        
        # Generate timeout report
        report = timeout_manager.get_timeout_report()
        print(f"\n[TIMEOUT REPORT]\n{json.dumps(report, indent=2)}")

def execute_task_with_monitoring(task: Dict, task_id: str, 
                                timeout_manager: TimeoutManager) -> Any:
    """Execute task with progress updates to timeout manager."""
    
    # Simulated task execution with progress updates
    for progress in range(0, 101, 10):
        # Update progress
        timeout_manager.update_task_progress(
            task_id, 
            progress,
            partial_results={"checkpoint": f"progress_{progress}"}
        )
        
        # Simulate work
        time.sleep(1)
        
        # Check if task should continue
        task_info = timeout_manager.active_tasks.get(task_id, {})
        if task_info.get("status") in ["escalated", "skipped"]:
            print(f"Task {task_id} interrupted: {task_info['status']}")
            break
    
    return {"status": "complete", "task_id": task_id}
```

## 5. Configuration Schema

### 5.1 YAML Configuration

```yaml
timeout_configuration:
  global_defaults:
    soft_timeout: 300      # 5 minutes
    hard_timeout: 600      # 10 minutes
    critical_timeout: 900  # 15 minutes
    max_retries: 2
    scope_reduction_factor: 0.5
    
  agent_overrides:
    plan:
      soft_timeout: 300
      hard_timeout: 600
      critical_timeout: 900
      
    implement:
      soft_timeout: 300
      hard_timeout: 600
      critical_timeout: 1200  # 20 minutes for implementation
      
    debug:
      soft_timeout: 180      # 3 minutes (faster for debug)
      hard_timeout: 360
      critical_timeout: 600
      
    test:
      soft_timeout: 300
      hard_timeout: 600
      critical_timeout: 900
      
    research:
      soft_timeout: 240
      hard_timeout: 480
      critical_timeout: 720
      
    blueprint:
      soft_timeout: 300
      hard_timeout: 600
      critical_timeout: 900
  
  task_specific:
    code_generation:
      soft_timeout: 300
      hard_timeout: 600
      max_retries: 3
      
    test_execution:
      soft_timeout: 240
      hard_timeout: 480
      max_retries: 2
      
    log_analysis:
      soft_timeout: 180
      hard_timeout: 360
      max_retries: 3
      
    documentation:
      soft_timeout: 300
      hard_timeout: 600
      max_retries: 1
  
  escalation_paths:
    - level: soft
      trigger_after: 300
      action: check_progress
      continue_if_progress: true
      
    - level: hard
      trigger_after: 600
      action: terminate_and_retry
      reduce_scope_by: 0.5
      
    - level: critical
      trigger_after: 900
      action: escalate_to_user
      preserve_partial_results: true
  
  recovery_strategies:
    scope_reduction:
      enabled: true
      factors: [1.0, 0.7, 0.5, 0.3]
      
    task_splitting:
      enabled: true
      max_subtasks: 10
      
    sequential_fallback:
      enabled: true
      trigger_after_retries: 2
      
    partial_salvage:
      enabled: true
      min_progress_to_salvage: 25
  
  monitoring:
    check_interval: 30  # seconds
    progress_threshold: 5  # minimum % progress to reset timeout
    heartbeat_interval: 60
    
  reporting:
    log_timeouts: true
    store_escalations: true
    report_directory: "/tmp/timeout_reports"
    retention_days: 7
```

## 6. Usage Examples

### 6.1 Basic Usage

```python
# Example 1: Planning agent with timeout handling
def plan_with_timeouts(task_description: str):
    timeout_manager = TimeoutManager("plan")
    timeout_manager.start_monitoring()
    
    # Configure timeout for analysis task
    analysis_config = TimeoutConfig(
        task_type="analysis",
        soft_timeout=300,
        hard_timeout=600,
        critical_timeout=900,
        max_retries=2
    )
    
    task = {
        "type": "analysis",
        "name": "Analyze project structure",
        "scope": {
            "directories": ["src", "tests", "docs"],
            "max_depth": 5
        }
    }
    
    task_id = "analysis_001"
    timeout_manager.register_task(task_id, task, analysis_config)
    
    # Execute with monitoring
    try:
        # Simulate task execution
        for progress in range(0, 101, 10):
            timeout_manager.update_task_progress(task_id, progress)
            time.sleep(2)  # Simulate work
            
    except Exception as e:
        print(f"Task failed: {e}")
    
    finally:
        timeout_manager.stop_monitoring()
        report = timeout_manager.get_timeout_report()
        print(json.dumps(report, indent=2))

# Example 2: Implementation with scope reduction
def implement_with_scope_reduction(features: List[str]):
    timeout_manager = TimeoutManager("implement")
    timeout_manager.start_monitoring()
    
    task = {
        "type": "code_generation",
        "name": "Implement features",
        "scope": {
            "features": features,
            "files": ["main.py", "utils.py", "config.py"]
        }
    }
    
    config = TimeoutConfig(
        task_type="code_generation",
        soft_timeout=300,
        hard_timeout=600,
        scope_reduction_factor=0.5  # Reduce to 50% on retry
    )
    
    task_id = "impl_001"
    timeout_manager.register_task(task_id, task, config)
    
    # Task will automatically retry with reduced scope if timeout occurs
    execute_task_with_monitoring(task, task_id, timeout_manager)

# Example 3: Debug with fast timeouts
def debug_with_fast_timeouts(error_log: str):
    timeout_manager = TimeoutManager("debug")
    timeout_manager.start_monitoring()
    
    # Debug tasks have faster timeouts
    diagnostic_config = TimeoutConfig(
        task_type="diagnostics",
        soft_timeout=120,  # 2 minutes
        hard_timeout=240,  # 4 minutes
        critical_timeout=360  # 6 minutes
    )
    
    task = {
        "type": "diagnostics",
        "name": "Analyze error",
        "scope": {
            "log_file": error_log,
            "max_lines": 10000
        }
    }
    
    task_id = "debug_001"
    timeout_manager.register_task(task_id, task, diagnostic_config)
    
    # Execute with fast timeout monitoring
    execute_task_with_monitoring(task, task_id, timeout_manager)
```

## 7. Monitoring and Reporting

### 7.1 Timeout Dashboard

```python
class TimeoutDashboard:
    """Dashboard for monitoring timeout events."""
    
    def __init__(self, timeout_manager: TimeoutManager):
        self.timeout_manager = timeout_manager
        
    def display_status(self):
        """Display current timeout status."""
        report = self.timeout_manager.get_timeout_report()
        
        print("\n" + "="*60)
        print("TIMEOUT STATUS DASHBOARD")
        print("="*60)
        print(f"Timestamp: {report['timestamp']}")
        print(f"Active Tasks: {report['active_tasks']}")
        print(f"Timed Out: {report['timed_out_tasks']}")
        print(f"Escalated: {report['escalated_tasks']}")
        print("\nTask Details:")
        print("-"*60)
        
        for task in report['tasks']:
            status_icon = self._get_status_icon(task['status'])
            timeout_indicator = self._get_timeout_indicator(
                task['soft_timeout'], 
                task['hard_timeout']
            )
            
            print(f"{status_icon} {task['name']} ({task['id']})")
            print(f"  Progress: {task['progress']}%")
            print(f"  Timeouts: {timeout_indicator}")
            print(f"  Retries: {task['retries']}")
            print()
    
    def _get_status_icon(self, status: str) -> str:
        icons = {
            "running": "▶",
            "complete": "✓",
            "partial_complete": "◐",
            "escalated": "⚠",
            "skipped": "⊘"
        }
        return icons.get(status, "?")
    
    def _get_timeout_indicator(self, soft: bool, hard: bool) -> str:
        if hard:
            return "HARD TIMEOUT ⏰"
        elif soft:
            return "Soft timeout ⏱"
        else:
            return "Normal ✓"
```

## Summary

This comprehensive timeout handling implementation provides:

1. **Soft Timeout (5 min)**: Progress check without termination
2. **Hard Timeout (10 min)**: Terminate and retry with reduced scope
3. **Critical Timeout (15 min)**: Immediate escalation to user
4. **Configurable Values**: Per task type and agent type
5. **Clear Escalation Paths**: Progressive escalation with defined actions
6. **Recovery Strategies**: Scope reduction, task splitting, sequential fallback
7. **Partial Result Salvaging**: Preserve work done before timeout
8. **Comprehensive Monitoring**: Real-time status and reporting
9. **Integration Ready**: Easy integration with existing agent system

The system ensures tasks don't hang indefinitely while providing multiple recovery mechanisms before requiring user intervention.