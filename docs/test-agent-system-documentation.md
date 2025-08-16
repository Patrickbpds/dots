# OpenCode Test Agent System Documentation

## Overview

The Test Agent System is a comprehensive testing framework for OpenCode that ensures high-quality, meaningful test coverage across all codebases. It consists of a primary `test` agent and six specialized subagents that work together to analyze, generate, validate, and document tests.

## Core Philosophy

The test agent system is built on these fundamental principles:

1. **No Placeholder Tests**: Every test must validate actual behavior
2. **Meaningful Coverage**: Focus on quality over quantity
3. **Best Practices**: Follow language-specific conventions and patterns
4. **Continuous Validation**: Tests are validated for quality before acceptance
5. **Comprehensive Documentation**: All tests are well-documented
6. **Research-Driven**: Leverage industry best practices and patterns

## Agent Architecture

### Primary Agent: `test`

The main testing agent that orchestrates the entire testing workflow.

**Capabilities:**
- Creates comprehensive unit tests
- Ensures excellent coverage
- Follows best practices
- Gradually tests and validates
- Never creates placeholder tests

**Usage:**
```bash
# Switch to test agent using Tab key or:
@test Create unit tests for the UserService class

# The test agent will:
1. Analyze the code structure
2. Identify test scenarios
3. Generate meaningful tests
4. Validate test quality
5. Document the tests
```

### Subagents

#### 1. `test-analyzer`
**Purpose**: Analyzes code to identify comprehensive test scenarios

**Responsibilities:**
- Code structure analysis
- Logic path identification
- Edge case discovery
- Coverage gap analysis
- Security concern identification

**Output**: Detailed test scenario reports with priorities

#### 2. `test-generator`
**Purpose**: Creates high-quality test implementations

**Responsibilities:**
- Generate tests following AAA pattern
- Language-specific best practices
- Proper mocking strategies
- Performance considerations
- Maintainable test code

**Supports**: Python (pytest), JavaScript/TypeScript (Jest/Vitest), Go, and more

#### 3. `test-coverage`
**Purpose**: Analyzes and improves test coverage

**Responsibilities:**
- Run coverage tools
- Identify meaningful gaps
- Priority-based improvements
- Mutation testing integration
- Coverage report generation

**Metrics**: Line, branch, function, and statement coverage

#### 4. `test-validator`
**Purpose**: Ensures test quality and prevents low-quality tests

**Responsibilities:**
- Detect placeholder tests
- Validate assertions
- Check test independence
- Performance validation
- Anti-pattern detection

**Enforcement**: Pre-commit hooks and CI/CD integration

#### 5. `test-documenter`
**Purpose**: Creates comprehensive test documentation

**Responsibilities:**
- Test plan creation
- Test suite documentation
- Execution reports
- Bug report templates
- Maintenance guidelines

**Outputs**: Markdown documentation in `docs/tests/`

#### 6. `test-researcher`
**Purpose**: Researches testing best practices

**Responsibilities:**
- Technology stack analysis
- Best practices research
- Pattern identification
- Tool evaluation
- Domain-specific requirements

**Sources**: Official docs, industry standards, academic research

## Workflow Examples

### Example 1: Creating Tests for a New Feature

```bash
# User request
@test Create comprehensive tests for the new PaymentProcessor class

# Test agent workflow:
1. @test-analyzer analyzes PaymentProcessor
   - Identifies 15 test scenarios
   - Finds 5 edge cases
   - Notes 3 security concerns

2. @test-generator creates tests
   - Generates 20 unit tests
   - Implements proper mocking
   - Adds parameterized tests

3. @test-validator checks quality
   - Validates all assertions
   - Ensures no placeholders
   - Checks performance

4. @test-coverage analyzes coverage
   - Reports 92% line coverage
   - Identifies 2 uncovered branches
   - Suggests additional tests

5. @test-documenter creates documentation
   - Updates test plan
   - Documents test scenarios
   - Creates coverage report
```

### Example 2: Improving Existing Test Coverage

```bash
# User request
@test Improve test coverage for the authentication module

# Test agent workflow:
1. @test-coverage analyzes current state
   - Current coverage: 73%
   - Missing: error paths, edge cases

2. @test-analyzer identifies gaps
   - 8 uncovered scenarios found
   - 3 critical, 5 nice-to-have

3. @test-generator creates new tests
   - Adds 8 new test cases
   - Focuses on error handling

4. @test-validator ensures quality
   - All tests meaningful
   - Proper assertions added

5. Coverage improved to 91%
```

## Test Quality Standards

### Mandatory Requirements

Every test must:
- Have a clear, descriptive name
- Test actual behavior (not just existence)
- Include meaningful assertions
- Be independent of other tests
- Run quickly (< 1 second for unit tests)
- Handle both success and failure cases

### Anti-Patterns Prevented

The system actively prevents:
```python
# ❌ PREVENTED: Placeholder tests
def test_something():
    assert True

# ❌ PREVENTED: Tests without assertions
def test_function():
    my_function()  # No validation

# ❌ PREVENTED: Weak assertions
def test_user():
    user = create_user()
    assert user  # Too vague
```

### Best Practices Enforced

```python
# ✅ ENFORCED: Meaningful tests
def test_calculate_discount_applies_percentage_correctly():
    """Test that discount calculation is accurate."""
    original_price = 100.0
    discount_percent = 20
    
    result = calculate_discount(original_price, discount_percent)
    
    assert result == 80.0, f"Expected 80.0 but got {result}"
    assert isinstance(result, float), "Result should be a float"
```

## Language-Specific Support

### Python (pytest)
- Fixtures for test data
- Parameterized tests
- Async test support
- Mock/patch strategies
- Coverage with pytest-cov

### JavaScript/TypeScript (Jest/Vitest)
- Describe/it structure
- Snapshot testing
- Mock modules
- Async/await testing
- Coverage with built-in tools

### Go
- Table-driven tests
- Subtests
- Benchmarks
- Mock interfaces
- Built-in coverage

## Integration with CI/CD

### GitHub Actions Example
```yaml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Run tests with coverage
        run: |
          pytest --cov=src --cov-fail-under=80
          
      - name: Validate test quality
        run: |
          python -m test_validator validate --strict
          
      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          fail_ci_if_error: true
```

## Configuration

### Global Settings
Add to `~/.config/opencode/opencode.json`:
```json
{
  "test_settings": {
    "coverage_threshold": 80,
    "enforce_quality": true,
    "parallel_execution": true,
    "timeout_seconds": 300
  }
}
```

### Project-Specific Settings
Add to `.opencode/test-config.json`:
```json
{
  "test_framework": "pytest",
  "coverage_tool": "pytest-cov",
  "minimum_coverage": 85,
  "excluded_paths": ["*/migrations/*", "*/vendor/*"]
}
```

## Metrics and Reporting

### Coverage Metrics
- Line Coverage: Percentage of code lines executed
- Branch Coverage: Percentage of decision branches taken
- Function Coverage: Percentage of functions called
- Statement Coverage: Percentage of statements executed

### Quality Metrics
- Assertion Density: Assertions per test
- Test Independence: Percentage of independent tests
- Performance: Average test execution time
- Mutation Score: Percentage of mutations caught

### Reports Generated
1. **Test Plan**: Strategic testing approach
2. **Coverage Report**: Detailed coverage analysis
3. **Execution Report**: Test run results
4. **Quality Report**: Test quality metrics
5. **Trend Analysis**: Historical comparisons

## Best Practices

### Test Organization
```
tests/
├── unit/           # Isolated component tests
├── integration/    # Component interaction tests
├── e2e/           # End-to-end workflow tests
├── fixtures/      # Shared test data
├── helpers/       # Test utilities
└── conftest.py    # Pytest configuration
```

### Naming Conventions
- Test files: `test_[module_name].py`
- Test functions: `test_[function]_[scenario]_[expected]`
- Test classes: `Test[ClassName]`
- Fixtures: `[description]_fixture`

### Documentation Standards
Every test should include:
- Clear docstring explaining purpose
- Comments for complex logic
- Assertion messages for debugging
- Links to requirements/tickets

## Troubleshooting

### Common Issues

**Issue**: Tests failing intermittently
**Solution**: Check for time dependencies, shared state, or external dependencies

**Issue**: Coverage not improving
**Solution**: Use @test-analyzer to identify meaningful gaps, not just line coverage

**Issue**: Tests running slowly
**Solution**: Check for unnecessary I/O, large datasets, or missing mocks

**Issue**: Placeholder tests detected
**Solution**: @test-validator will prevent commit; rewrite with meaningful assertions

## Future Enhancements

### Planned Features
1. **Property-based testing**: Automatic test case generation
2. **Fuzzing integration**: Security-focused testing
3. **Visual regression testing**: UI component testing
4. **Contract testing**: API contract validation
5. **Chaos engineering**: Resilience testing

### Research Areas
- AI-assisted test generation
- Automatic test maintenance
- Predictive test selection
- Test impact analysis
- Self-healing tests

## Getting Started

### Quick Start
1. Enable the test agent in your OpenCode configuration
2. Navigate to your project directory
3. Run: `@test Create tests for [module/class]`
4. Review generated tests
5. Run tests with coverage
6. Review documentation in `docs/tests/`

### Learning Resources
- Test agent examples: `/examples/test-agent/`
- Video tutorials: [Coming soon]
- Best practices guide: `docs/testing-best-practices.md`
- Pattern catalog: `docs/test-patterns.md`

## Support

### Getting Help
- GitHub Issues: Report bugs or request features
- Discord: Join #testing channel for discussions
- Documentation: Check `docs/tests/` for guides
- Examples: Browse test examples in the repo

### Contributing
We welcome contributions to improve the test agent system:
1. Fork the repository
2. Create a feature branch
3. Add tests for your changes
4. Ensure all tests pass
5. Submit a pull request

## Conclusion

The OpenCode Test Agent System provides a comprehensive, intelligent approach to testing that ensures high-quality, meaningful test coverage. By combining automated analysis, generation, validation, and documentation, it helps developers create robust test suites that actually catch bugs and provide confidence in code changes.

Remember: **Quality over quantity, meaning over coverage numbers, and no placeholder tests ever!**