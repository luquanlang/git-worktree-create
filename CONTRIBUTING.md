# Contributing to Git Worktree Link Manager

Thank you for considering contributing to Git Worktree Link Manager! This document provides guidelines and instructions for contributing.

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Assume good intentions

## How to Contribute

There are many ways to contribute:

1. **Report bugs** - Help me identify and fix issues
2. **Suggest features** - Share ideas for improvements
3. **Improve documentation** - Fix typos, clarify instructions, add examples
4. **Submit code** - Fix bugs or implement new features
5. **Share feedback** - Let me know how you're using the tool

## Reporting Bugs

### Before Submitting a Bug Report

1. **Check existing issues** - Your bug may already be reported
2. **Try the latest version** - The bug might be fixed in `main`
3. **Test in a clean environment** - Verify it's not a local configuration issue

### How to Submit a Bug Report

Create an issue with the following information:

**Title:** Short, descriptive summary (e.g., "Symlink creation fails with spaces in path")

**Template:**
```markdown
## Description
A clear description of the bug

## Steps to Reproduce
1. Run command: `git-worktree-create feature/test`
2. Expected: Worktree created with links
3. Actual: Error message about permissions

## Environment
- OS: macOS 13.5 / Ubuntu 22.04 / WSL2
- Bash version: `bash --version`
- Git version: `git --version`
- Installation method: Quick install / Manual / From source

## Configuration
```bash
WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"
WORKTREE_LINKED_FILES=".vscode,.env"
```

## Error Output
```
Paste the full error message here
```

## Additional Context
Any other information that might be relevant
```

## Suggesting Features

I love feature ideas! Before suggesting:

1. **Check existing issues** - Someone may have already suggested it
2. **Consider scope** - Does it align with the tool's purpose?
3. **Think about alternatives** - Are there other ways to achieve this?

### How to Suggest a Feature

Create an issue with the following information:

**Title:** Clear feature description (e.g., "Add support for per-branch link configuration")

**Template:**
```markdown
## Problem
What problem does this feature solve?

## Proposed Solution
How would this feature work?

## Alternatives Considered
What other approaches did you consider?

## Example Usage
```bash
# Show how users would use this feature
git-worktree-create --config=.worktree-config.json feature/test
```

## Additional Context
Any other relevant information
```

## Development Setup

### Prerequisites

- Bash 4.0 or later
- Git 2.5 or later
- shellcheck (optional but recommended for linting)

### Setup Steps

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/luquanlang/git-worktree-create.git
   cd git-worktree-create
   ```

2. **Create a development link**
   ```bash
   # Link the script to your PATH for testing
   mkdir -p ~/.local/bin
   ln -sf "$(pwd)/git-worktree-create" ~/.local/bin/git-worktree-create
   ```

3. **Make changes**
   ```bash
   # Edit git-worktree-create
   # Changes take effect immediately due to symlink
   ```

4. **Test your changes**
   ```bash
   # Test basic functionality
   cd /path/to/test/repo
   git-worktree-create --dry-run test/branch

   # Test with various options
   git-worktree-create --verbose test/branch
   ```

5. **Run shellcheck** (if installed)
   ```bash
   shellcheck git-worktree-create
   ```

### Testing

**Manual Test Checklist:**

- [ ] Basic worktree creation works
- [ ] Branch names with slashes are sanitized correctly
- [ ] Symlinks are created for configured files
- [ ] Missing source files are skipped gracefully
- [ ] Existing target files are not overwritten
- [ ] `--dry-run` shows what would happen without changes
- [ ] `--verbose` shows detailed information
- [ ] `--help` displays help message
- [ ] `--version` shows version number
- [ ] Error messages are clear and helpful
- [ ] Works outside a Git repo (should fail gracefully)
- [ ] Works without `WORKTREE_CONTAINING_FOLDER` (should fail with helpful message)

**Test Script:**

```bash
#!/usr/bin/env bash
# Quick test script for git-worktree-create

# Setup
export WORKTREE_CONTAINING_FOLDER="/tmp/test-worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env"

# Create test repo
cd /tmp
rm -rf test-repo test-worktrees
mkdir test-repo && cd test-repo
git init
echo "test" > README.md
git add . && git commit -m "Initial commit"
mkdir .vscode
echo "config" > .vscode/settings.json
echo "SECRET=test" > .env

# Test 1: Basic creation
echo "Test 1: Basic creation"
git-worktree-create feature/test-basic

# Test 2: Verify symlinks
echo "Test 2: Verify symlinks"
ls -la /tmp/test-worktrees/test-repo-feature-test-basic/

# Test 3: Dry run
echo "Test 3: Dry run"
git-worktree-create --dry-run feature/test-dryrun

# Test 4: Verbose
echo "Test 4: Verbose"
git-worktree-create --verbose feature/test-verbose

# Cleanup
cd /tmp
rm -rf test-repo test-worktrees
echo "Tests complete!"
```

## Coding Standards

### Shell Script Style Guide

**General Principles:**
- Follow existing code style
- Write clear, readable code
- Add comments for complex logic
- Use meaningful variable names

**Specific Guidelines:**

1. **Error Handling**
   ```bash
   # Use strict mode
   set -euo pipefail

   # Provide helpful error messages
   if [[ ! -d "$directory" ]]; then
       error "Directory does not exist: $directory"
       echo "Please create it first or check your configuration"
       exit 1
   fi
   ```

2. **Variable Names**
   ```bash
   # UPPERCASE for global constants/environment variables
   WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"

   # lowercase for local variables
   local branch_name="feature/test"
   local worktree_path="/path/to/worktree"
   ```

3. **Quoting**
   ```bash
   # Always quote variables
   echo "$VARIABLE"  # Good
   echo $VARIABLE    # Bad

   # Always quote file paths
   cd "$HOME/my folder"  # Good
   cd $HOME/my folder    # Bad (will fail)
   ```

4. **Conditionals**
   ```bash
   # Use [[ ]] for tests
   if [[ -n "$variable" ]]; then  # Good
   if [ -n "$variable" ]; then    # Acceptable but less powerful

   # Check for empty strings
   if [[ -z "$variable" ]]; then
       echo "Variable is empty"
   fi
   ```

5. **Functions**
   ```bash
   # Clear function names that describe what they do
   create_symlinks() {
       local worktree_path="$1"
       # Function body
   }

   # Return values via echo or exit codes
   get_repo_name() {
       basename "$(git rev-parse --show-toplevel)"
   }
   ```

6. **Output Functions**
   ```bash
   # Use existing output functions for consistency
   success "Operation completed"  # Green checkmark
   error "Operation failed"       # Red X
   warning "Something to note"    # Yellow warning
   info "Information"             # Blue info
   verbose "Detail when needed"   # Only in verbose mode
   ```

### shellcheck Compliance

- Run `shellcheck git-worktree-create` before submitting
- Fix all warnings and errors
- If you must disable a check, add a comment explaining why:
  ```bash
  # shellcheck disable=SC2086
  # Intentional word splitting for array expansion
  git worktree add $options "$branch"
  ```

## Commit Message Format

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Formatting, missing semicolons, etc. (no code change)
- `refactor`: Code change that neither fixes a bug nor adds a feature
- `test`: Adding or updating tests
- `chore`: Maintenance tasks, dependencies, etc.

**Examples:**

```
feat: add support for custom worktree naming

Add --name flag to allow users to specify custom directory names
instead of using the auto-generated name from the branch.

Closes #42
```

```
fix: handle spaces in file paths correctly

Quote all path variables to prevent word splitting when paths
contain spaces.

Fixes #38
```

```
docs: add troubleshooting section for Windows users

Add instructions for using WSL for proper symlink support.
```

## Pull Request Process

### Before Submitting

1. **Create a feature branch**
   ```bash
   git checkout -b feature/my-new-feature
   # or
   git checkout -b fix/bug-description
   ```

2. **Make your changes**
   - Follow coding standards
   - Add comments where needed
   - Update documentation if necessary

3. **Test thoroughly**
   - Run manual test checklist
   - Test edge cases
   - Run shellcheck

4. **Commit your changes**
   ```bash
   git add git-worktree-create
   git commit -m "feat: add new feature"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/my-new-feature
   ```

### Submitting the PR

1. **Open a Pull Request** on GitHub

2. **Fill out the PR template:**
   ```markdown
   ## Description
   Brief description of what this PR does

   ## Type of Change
   - [ ] Bug fix (non-breaking change that fixes an issue)
   - [ ] New feature (non-breaking change that adds functionality)
   - [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
   - [ ] Documentation update

   ## Testing
   - [ ] Tested basic worktree creation
   - [ ] Tested with edge cases (spaces in paths, missing files, etc.)
   - [ ] Ran shellcheck with no errors
   - [ ] Updated documentation

   ## Related Issues
   Closes #123
   Fixes #456

   ## Additional Notes
   Any other information for reviewers
   ```

3. **Respond to feedback**
   - Be open to suggestions
   - Make requested changes
   - Push updates to your branch (PR updates automatically)

### After Submission

- **Be patient** - Maintainers review in their spare time
- **Be responsive** - Reply to questions and feedback
- **Be collaborative** - Work with maintainers to refine your contribution

## Review Process

1. **Initial Review** - Maintainer checks if PR aligns with project goals
2. **Code Review** - Detailed review of code quality, style, and logic
3. **Testing** - Maintainer tests the changes locally
4. **Feedback** - Maintainer provides comments or requests changes
5. **Approval** - Once everything looks good, PR is approved
6. **Merge** - Maintainer merges the PR into main branch

## Release Process

(For maintainers)

1. Update CHANGELOG.md with version and changes
2. Update VERSION in scripts
3. Create a git tag: `git tag -a v1.1.0 -m "Release version 1.1.0"`
4. Push tag: `git push origin v1.1.0`
5. Create GitHub release with release notes

## Getting Help

- **Questions about contributing?** Open a discussion on GitHub
- **Stuck on something?** Ask in your PR or issue
- **Need clarification?** Comment on the relevant issue or PR

## Recognition

Contributors will be:
- Listed in release notes
- Mentioned in the repository's contributors list
- Credited in commit messages

Thank you for contributing to Git Worktree Link Manager!
