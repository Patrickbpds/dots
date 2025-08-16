# Git Commit Best Practices Reference Guide

## Table of Contents
1. [Conventional Commits Specification](#conventional-commits-specification)
2. [The Seven Rules of Great Commit Messages](#the-seven-rules-of-great-commit-messages)
3. [Writing Descriptive Messages (WHY vs WHAT)](#writing-descriptive-messages-why-vs-what)
4. [Atomic Commits Guidelines](#atomic-commits-guidelines)
5. [Common Commit Types](#common-commit-types)
6. [Examples and Anti-patterns](#examples-and-anti-patterns)

---

## Conventional Commits Specification

### Basic Structure
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Key Components

1. **Type** (REQUIRED): Describes the category of change
2. **Scope** (OPTIONAL): Section of codebase affected, in parentheses
3. **Description** (REQUIRED): Short summary of changes
4. **Body** (OPTIONAL): Detailed explanation
5. **Footer** (OPTIONAL): Breaking changes, issue references

### Breaking Changes
- Use `BREAKING CHANGE:` in footer, OR
- Append `!` after type/scope: `feat!:` or `feat(api)!:`

---

## The Seven Rules of Great Commit Messages

### 1. Separate Subject from Body with Blank Line
- First line = commit title (used by Git tools)
- Blank line is critical for proper parsing
- Not all commits need a body

### 2. Limit Subject Line to 50 Characters
- **Soft limit**: 50 characters (recommended)
- **Hard limit**: 72 characters (maximum)
- Forces concise, clear communication
- GitHub UI warns at 50, truncates at 72

### 3. Capitalize the Subject Line
✅ `Fix authentication bug in login flow`  
❌ `fix authentication bug in login flow`

### 4. Do Not End Subject Line with Period
✅ `Add user profile validation`  
❌ `Add user profile validation.`

### 5. Use Imperative Mood in Subject Line
**Test**: "If applied, this commit will [your subject]"

✅ Good examples:
- `Refactor database connection logic`
- `Update API documentation`
- `Remove deprecated methods`

❌ Bad examples:
- `Fixed bug with validation`
- `Changing behavior of parser`
- `More fixes for broken stuff`

### 6. Wrap Body at 72 Characters
- Git doesn't auto-wrap text
- 72 chars allows Git to indent while staying under 80 total
- Configure your editor to help with this

### 7. Use Body to Explain WHAT and WHY vs HOW
- Code shows HOW (implementation details)
- Commit message explains WHAT changed and WHY
- Include context future maintainers will need

---

## Writing Descriptive Messages (WHY vs WHAT)

### Focus Areas for the Body

1. **Problem Statement**: What issue does this solve?
2. **Motivation**: Why was this change necessary?
3. **Approach**: Why this solution over alternatives?
4. **Side Effects**: Any non-obvious consequences?
5. **Context**: Related issues, discussions, decisions

### Template for Descriptive Body
```
[Problem/Context]
The system was experiencing [issue] when [condition].

[Solution/Changes]
This commit [action taken] by [approach].

[Impact/Reasoning]
This change [benefits/fixes] because [explanation].

[Additional Notes]
- Side effect: [if any]
- Alternative considered: [if relevant]

Fixes: #123
See also: #456
```

---

## Atomic Commits Guidelines

### Principles of Atomic Commits

1. **Single Purpose**: Each commit does ONE thing
2. **Complete**: The change is self-contained and functional
3. **Reversible**: Can be reverted without breaking other features
4. **Testable**: Can be tested in isolation

### Benefits
- Easier code review
- Simpler debugging with `git bisect`
- Clean revert if needed
- Clear project history
- Better collaboration

### How to Achieve Atomic Commits

1. **Plan before coding**: Break work into logical chunks
2. **Use staging area**: `git add -p` for partial staging
3. **Commit frequently**: Small, focused changes
4. **Squash when needed**: Combine related commits before merging
5. **Split large changes**: Use multiple commits for complex features

### Signs Your Commit is NOT Atomic
- Subject line contains "and" or multiple verbs
- Changes touch unrelated files/features
- Commit message needs multiple paragraphs to explain different changes
- Reverting would break unrelated functionality

---

## Common Commit Types

### Core Types (Conventional Commits)

| Type | Description | Semantic Version | Example |
|------|-------------|------------------|---------|
| `feat` | New feature | MINOR | `feat: add user authentication` |
| `fix` | Bug fix | PATCH | `fix: resolve memory leak in parser` |
| `docs` | Documentation only | - | `docs: update API examples` |
| `style` | Formatting, no code change | - | `style: format code with prettier` |
| `refactor` | Code change, no fix/feature | - | `refactor: extract validation logic` |
| `perf` | Performance improvement | PATCH | `perf: optimize database queries` |
| `test` | Add/update tests | - | `test: add unit tests for auth` |
| `build` | Build system/dependencies | - | `build: upgrade webpack to v5` |
| `ci` | CI configuration | - | `ci: add GitHub Actions workflow` |
| `chore` | Maintenance tasks | - | `chore: update .gitignore` |
| `revert` | Revert previous commit | - | `revert: revert commit abc123` |

### With Scopes
```
feat(auth): implement OAuth2 integration
fix(api): handle null response correctly
docs(readme): add installation instructions
test(user): cover edge cases in validation
```

---

## Examples and Anti-patterns

### ✅ GOOD Examples

#### Simple Fix
```
fix: prevent race condition in request handler

Introduce request ID and reference to latest request.
Dismiss responses from outdated requests.

The previous timeout-based approach was unreliable
and could still result in out-of-order responses.

Fixes: #2341
```

#### Feature with Breaking Change
```
feat(api)!: change user endpoint response format

BREAKING CHANGE: The /api/users endpoint now returns
data in a nested structure:

Before: { id, name, email }
After: { user: { id, name, email } }

This aligns with our other API endpoints and allows
for metadata in the response.

Migration guide: Update client code to access user
data via response.user instead of response directly.
```

#### Refactor with Context
```
refactor: consolidate validation logic into single module

Previously, validation was scattered across controllers,
services, and models, leading to:
- Duplicate code
- Inconsistent error messages
- Difficult testing

This change centralizes all validation in a dedicated
module, providing:
- Single source of truth for validation rules
- Consistent error format
- Easier unit testing
- 30% reduction in code duplication

All existing validation behavior is preserved.
```

### ❌ BAD Examples (Anti-patterns)

#### Too Vague
```
update code
fix stuff
changes
misc updates
```
**Problem**: No information about what changed or why

#### Too Long/Unfocused
```
fix: update user service and add logging and refactor database queries and fix authentication bug and update documentation
```
**Problem**: Multiple unrelated changes in one commit

#### Wrong Mood/Tense
```
fixed the bug with login
changing the validation logic
updated dependencies
```
**Problem**: Not using imperative mood

#### Missing Context
```
fix: change timeout to 5000
```
**Problem**: Doesn't explain why 5000 or what problem this solves

#### Implementation-focused
```
feat: use forEach instead of for loop
```
**Problem**: Describes HOW not WHAT/WHY

#### Non-atomic Commit
```
feat: add user profile page

- Create profile component
- Fix unrelated bug in navigation
- Update README
- Refactor auth service
- Add profile tests
- Fix typos in comments
```
**Problem**: Contains multiple unrelated changes

### 🎯 Quick Decision Guide

| Situation | Commit Type | Example |
|-----------|------------|---------|
| Adding new capability | `feat` | `feat: add CSV export functionality` |
| Fixing broken behavior | `fix` | `fix: correct calculation in tax module` |
| Improving performance | `perf` | `perf: lazy load images on scroll` |
| Restructuring code | `refactor` | `refactor: extract email service` |
| Updating documentation | `docs` | `docs: clarify setup instructions` |
| Adding/updating tests | `test` | `test: add integration tests for API` |
| Formatting/style only | `style` | `style: apply ESLint rules` |
| Dependency updates | `build` | `build: upgrade React to v18` |
| CI/CD changes | `ci` | `ci: add deployment pipeline` |
| Maintenance tasks | `chore` | `chore: clean up unused files` |

---

## Best Practices Summary

### DO ✅
- Write in imperative mood
- Explain WHY, not just WHAT
- Keep commits atomic and focused
- Use conventional commit types
- Include issue references
- Think about future readers
- Test before committing
- Review your own commits

### DON'T ❌
- Mix unrelated changes
- Use generic messages
- Forget the blank line between subject and body
- End subject with period
- Exceed character limits
- Commit commented-out code
- Include sensitive information
- Use unclear abbreviations

### Pro Tips 💡
1. **Configure your editor** for Git commit messages
2. **Use templates** for consistent format
3. **Review log before pushing** with `git log --oneline`
4. **Amend recent commits** if needed: `git commit --amend`
5. **Interactive rebase** to clean history: `git rebase -i`
6. **Write commit message first** to clarify intent
7. **Use hooks** for automated validation
8. **Batch related changes** but keep them atomic

---

## References

- [Conventional Commits Specification v1.0.0](https://www.conventionalcommits.org/)
- [How to Write a Git Commit Message - Chris Beams](https://cbea.ms/git-commit/)
- [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/main/CONTRIBUTING.md#commit)
- [Linux Kernel Commit Guidelines](https://www.kernel.org/doc/html/latest/process/submitting-patches.html)
- [Pro Git Book - Distributed Git](https://git-scm.com/book/en/v2/Distributed-Git-Contributing-to-a-Project)