# Hyprland UWSM Monitor Blackout Resolution Plan

## Context

### Problem Statement
The user's Hyprland setup with 3 monitors (HDMI-A-1, DP-1, DP-3) works perfectly in normal mode but causes all screens to go black when using UWSM (Universal Wayland Session Manager). The system appears to be running but provides no visual output, requiring TTY access for recovery.

### Current State
- **Working Configuration**: Normal Hyprland launch with complex startup orchestrator
- **Failing Configuration**: UWSM-managed Hyprland session with immediate monitor blackout
- **Hardware**: 3-monitor setup (1920x1200@120Hz, 2560x1440@75Hz, 2560x1440@144Hz with VRR)
- **Software**: Complex Quickshell/Heimdall integration with custom state management

### Goals
1. Achieve stable UWSM-managed Hyprland sessions with all monitors functional
2. Maintain existing Quickshell/Heimdall functionality under UWSM
3. Provide reliable fallback mechanisms for session recovery
4. Create comprehensive debugging and monitoring procedures

### Constraints
- Must maintain compatibility with existing Quickshell/Heimdall setup
- Cannot break normal (non-UWSM) Hyprland functionality
- Must be recoverable from TTY-only access
- Should minimize startup time impact

## Specification

### Functional Requirements
- **FR1**: UWSM session starts without monitor blackout
- **FR2**: All three monitors remain active and functional
- **FR3**: Quickshell/Heimdall components start correctly under UWSM
- **FR4**: Environment variables propagate correctly to all services
- **FR5**: Fallback to normal Hyprland if UWSM fails

### Non-Functional Requirements
- **NFR1**: Session startup time < 10 seconds
- **NFR2**: Recovery from failure state < 30 seconds via TTY
- **NFR3**: Comprehensive logging for debugging
- **NFR4**: Minimal configuration duplication

### Interfaces
- **TTY Access**: Primary interface for debugging and recovery
- **Systemd Journal**: Logging and monitoring interface
- **UWSM CLI**: Session management interface
- **Hyprctl**: Compositor control interface

## Implementation Plan

### Phase 1: Immediate Diagnostic Setup
**Duration**: 1-2 hours  
**Priority**: Critical

#### Task 1.1: Create Comprehensive Monitoring Environment
- [ ] Set up multi-TTY monitoring layout for real-time debugging
  - TTY1: UWSM session control
  - TTY2: System journal monitoring
  - TTY3: User journal monitoring  
  - TTY4: UWSM service status
  - TTY5: Monitor hardware status
- [ ] Create debug log collection scripts
- [ ] Establish baseline measurements from working normal session

**Acceptance Criteria**:
- All TTY terminals configured with appropriate monitoring commands
- Debug scripts collect comprehensive system state
- Baseline logs captured from working session

**Test Requirements**:
- Verify all monitoring terminals display relevant information
- Confirm log collection captures all required data sources

#### Task 1.2: Implement Minimal UWSM Test Configuration
- [ ] Create stripped-down UWSM-compatible Hyprland config
- [ ] Remove all complex startup orchestration
- [ ] Add essential UWSM finalization commands
- [ ] Test single-monitor configurations individually

**Acceptance Criteria**:
- Minimal config starts without errors
- Single monitor configurations work independently
- UWSM finalization commands execute successfully

**Test Requirements**:
- Each monitor (HDMI-A-1, DP-1, DP-3) works individually
- No startup orchestrator conflicts
- UWSM service reaches ready state

#### Task 1.3: Root Cause Analysis Procedures
- [ ] Implement systematic service dependency checking
- [ ] Create environment variable validation scripts
- [ ] Set up graphics driver status monitoring
- [ ] Establish timeout and race condition detection

**Acceptance Criteria**:
- Service dependency issues identified
- Environment variable propagation tracked
- Graphics driver state monitored during startup
- Timeout conditions detected and logged

**Test Requirements**:
- Scripts identify specific failure points
- Timing issues documented with precise timestamps
- Graphics driver errors captured in logs

### Phase 2: Systematic Configuration Fixes
**Duration**: 2-3 hours  
**Priority**: High

#### Task 2.1: Implement UWSM Finalization
- [ ] Add `uwsm finalize` command to Hyprland configuration
- [ ] Configure UWSM wait variables for proper timing
- [ ] Remove conflicting systemd integration commands
- [ ] Test finalization with minimal configuration

**Acceptance Criteria**:
- UWSM finalization executes within timeout period
- Service reaches ready state consistently
- No conflicting environment management

**Test Requirements**:
- UWSM service status shows "active (running)"
- Journal logs show successful finalization
- Environment variables properly exported

#### Task 2.2: Resolve Startup Orchestrator Conflicts
- [ ] Create UWSM detection in startup orchestrator
- [ ] Implement conditional execution paths
- [ ] Migrate critical components to UWSM app launcher
- [ ] Test orchestrator bypass functionality

**Acceptance Criteria**:
- Startup orchestrator detects UWSM sessions
- Critical components start via UWSM app launcher
- No duplicate service initialization

**Test Requirements**:
- Orchestrator skips execution in UWSM mode
- All required services start via UWSM
- No service conflicts or duplicates

#### Task 2.3: Configure Monitor-Specific Initialization
- [ ] Implement delayed monitor activation
- [ ] Add DPMS control commands
- [ ] Configure monitor-specific timing
- [ ] Test multi-monitor startup sequence

**Acceptance Criteria**:
- All monitors activate in correct sequence
- No race conditions in monitor initialization
- DPMS states managed correctly

**Test Requirements**:
- All three monitors display output
- Monitor configuration applied correctly
- No blank or black screens during startup

### Phase 3: Advanced UWSM Integration
**Duration**: 3-4 hours  
**Priority**: Medium

#### Task 3.1: Create UWSM-Specific Configuration
- [ ] Develop dedicated UWSM Hyprland configuration
- [ ] Implement UWSM environment setup
- [ ] Configure service dependencies
- [ ] Test complete UWSM integration

**Acceptance Criteria**:
- Dedicated UWSM config works independently
- Environment variables properly configured
- Service dependencies resolved

**Test Requirements**:
- UWSM session starts with full functionality
- All monitors remain active throughout session
- Quickshell/Heimdall components function correctly

#### Task 3.2: Migrate Quickshell/Heimdall to UWSM
- [ ] Convert startup orchestrator to UWSM app launcher
- [ ] Implement UWSM-compatible state management
- [ ] Configure service timing and dependencies
- [ ] Test complete Quickshell/Heimdall functionality

**Acceptance Criteria**:
- Quickshell starts via UWSM app launcher
- State management works under UWSM
- All Heimdall features functional

**Test Requirements**:
- Quickshell UI displays correctly
- Heimdall CLI integration works
- Color scheme synchronization functional

#### Task 3.3: Implement Comprehensive Error Handling
- [ ] Create UWSM session health monitoring
- [ ] Implement automatic recovery procedures
- [ ] Configure failure notification system
- [ ] Test error handling scenarios

**Acceptance Criteria**:
- Health monitoring detects failures
- Recovery procedures execute automatically
- Notifications alert user to issues

**Test Requirements**:
- Monitoring detects service failures
- Recovery restores functionality
- Notifications work correctly

### Phase 4: Validation and Optimization
**Duration**: 2-3 hours  
**Priority**: Medium

#### Task 4.1: Comprehensive Testing Suite
- [ ] Test all monitor configurations
- [ ] Validate service startup timing
- [ ] Verify environment variable propagation
- [ ] Test failure and recovery scenarios

**Acceptance Criteria**:
- All monitor configurations work
- Service timing optimized
- Environment variables correct
- Recovery procedures validated

**Test Requirements**:
- 100% success rate for UWSM session starts
- All monitors functional in all tests
- Recovery completes within 30 seconds

#### Task 4.2: Performance Optimization
- [ ] Optimize service startup timing
- [ ] Reduce unnecessary delays
- [ ] Streamline configuration loading
- [ ] Benchmark startup performance

**Acceptance Criteria**:
- Startup time under 10 seconds
- No unnecessary service delays
- Configuration loading optimized

**Test Requirements**:
- Startup time measured and documented
- Performance comparable to normal mode
- No functionality compromised

#### Task 4.3: Documentation and Monitoring
- [ ] Create operational procedures
- [ ] Document troubleshooting steps
- [ ] Implement ongoing monitoring
- [ ] Create maintenance schedules

**Acceptance Criteria**:
- Complete operational documentation
- Troubleshooting procedures tested
- Monitoring system operational

**Test Requirements**:
- Documentation enables user self-service
- Troubleshooting resolves common issues
- Monitoring detects problems early

### Phase 5: Fallback and Recovery Systems
**Duration**: 1-2 hours  
**Priority**: High

#### Task 5.1: Intelligent Session Launcher
- [ ] Create adaptive Hyprland launcher script
- [ ] Implement UWSM availability detection
- [ ] Configure automatic fallback logic
- [ ] Test launcher reliability

**Acceptance Criteria**:
- Launcher detects UWSM availability
- Automatic fallback to normal mode
- User preference handling

**Test Requirements**:
- Launcher works in all scenarios
- Fallback preserves functionality
- User can override automatic selection

#### Task 5.2: Emergency Recovery Procedures
- [ ] Create TTY-based recovery scripts
- [ ] Implement session reset procedures
- [ ] Configure emergency fallback modes
- [ ] Test recovery from various failure states

**Acceptance Criteria**:
- Recovery scripts work from TTY
- Session reset restores functionality
- Emergency modes provide basic access

**Test Requirements**:
- Recovery works from complete blackout
- Scripts execute without dependencies
- Emergency modes are stable

## Risks and Mitigations

### Risk 1: UWSM Service Timeout
**Probability**: High  
**Impact**: High  
**Mitigation**: Implement proper finalization commands and timing configuration

### Risk 2: Graphics Driver Conflicts
**Probability**: Medium  
**Impact**: High  
**Mitigation**: Configure driver-specific workarounds and fallback modes

### Risk 3: Environment Variable Race Conditions
**Probability**: Medium  
**Impact**: Medium  
**Mitigation**: Implement proper wait conditions and variable validation

### Risk 4: Quickshell/Heimdall Incompatibility
**Probability**: Low  
**Impact**: Medium  
**Mitigation**: Gradual migration with fallback to original configuration

## Success Metrics

### Primary Metrics
- **Session Success Rate**: >95% successful UWSM session starts
- **Monitor Functionality**: 100% of monitors active in successful sessions
- **Recovery Time**: <30 seconds from failure to working session
- **Startup Performance**: <10 seconds total startup time

### Secondary Metrics
- **Error Rate**: <5% of sessions experience any errors
- **User Intervention**: <10% of issues require manual intervention
- **Documentation Completeness**: 100% of procedures documented
- **Monitoring Coverage**: 100% of critical components monitored

## Dev Log

### Session 2025-01-13 - Initial Plan Creation
**Changes Made**:
- Analyzed existing debug documentation and research
- Reviewed current Hyprland configuration structure
- Identified key conflict points between startup orchestrator and UWSM
- Created comprehensive implementation plan with 5 phases
- Established monitoring and testing procedures

**Validation Results**:
- Plan addresses all identified issues from research
- Phases logically build upon each other
- Risk mitigation strategies cover major failure modes
- Success metrics align with user requirements

**Next Steps**:
- Begin Phase 1 implementation with monitoring setup
- Create minimal UWSM test configuration
- Establish baseline measurements from working session
- Start systematic root cause analysis

## Quick Reference Commands

### UWSM Session Management
```bash
# Check UWSM status
uwsm check active

# Start UWSM session with debugging
UWSM_LOG_LEVEL=debug uwsm start -D Hyprland

# Stop UWSM session
uwsm stop

# View UWSM service logs
journalctl --user -u wayland-wm@Hyprland.service -f
```

### Monitor Debugging
```bash
# Check monitor status
hyprctl monitors

# Check hardware display status
ls -la /sys/class/drm/*/status | xargs -I {} sh -c 'echo -n "{}: "; cat {}'

# Force monitor activation
hyprctl dispatch dpms on
```

### Emergency Recovery
```bash
# Kill UWSM and start normal Hyprland
pkill -9 uwsm; Hyprland

# Reset systemd user services
systemctl --user reset-failed

# Check for failed services
systemctl --user --failed
```

### Monitoring Setup
```bash
# TTY2: System journal
journalctl -f

# TTY3: User journal  
journalctl --user -f

# TTY4: UWSM service status
watch -n 1 'systemctl --user status wayland-wm@Hyprland.service'

# TTY5: Monitor hardware status
watch -n 1 'cat /sys/class/drm/*/status 2>/dev/null | grep -c connected'
```