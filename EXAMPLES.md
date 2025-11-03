# Usage Examples

This document provides real-world examples of using `git-worktree-create` in various scenarios.

## Table of Contents

- [First-Time Setup](#first-time-setup)
- [Common Workflows](#common-workflows)
- [Project-Specific Configuration](#project-specific-configuration)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting Examples](#troubleshooting-examples)
- [Real-World Scenarios](#real-world-scenarios)

## First-Time Setup

### Complete Installation and Configuration

```bash
# Step 1: Install git-worktree-create
curl -fsSL https://raw.githubusercontent.com/yourusername/git-worktree-link-manager/main/install.sh | bash

# Step 2: Configure environment variables (add to ~/.bashrc or ~/.zshrc)
echo 'export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"' >> ~/.zshrc
echo 'export WORKTREE_LINKED_FILES=".vscode,.env,node_modules"' >> ~/.zshrc

# Step 3: Reload configuration
source ~/.zshrc

# Step 4: Verify installation
git-worktree-create --version

# Step 5: Test with a repository
cd ~/projects/my-app
git-worktree-create --dry-run feature/test
```

### First Worktree Creation

```bash
# Navigate to your repository
cd ~/projects/my-app

# Create your first worktree
git-worktree-create feature/user-authentication

# Output:
# ℹ Creating worktree for branch 'feature/user-authentication'...
# ✓ Worktree created at: /home/user/worktrees/my-app-feature-user-authentication
# ℹ Creating symbolic links for shared files...
# ✓ Linked: .vscode
# ✓ Linked: .env
# ✓ Linked: node_modules
#
# ✓ Worktree setup complete!
#
# To start working in your new worktree:
#   cd /home/user/worktrees/my-app-feature-user-authentication

# Navigate to the new worktree
cd /home/user/worktrees/my-app-feature-user-authentication

# Verify the setup
ls -la
# You should see symlinks for .vscode, .env, and node_modules

# Start working
code .
```

## Common Workflows

### Feature Development

**Scenario:** You need to work on a new feature while keeping your main branch clean.

```bash
# 1. Create NEW branch and worktree from main with -b flag
cd ~/projects/my-app
git-worktree-create -b feature/shopping-cart main

# 2. Switch to the new worktree
cd ~/worktrees/my-app-feature-shopping-cart

# 3. Develop your feature
# ... make changes, commit, etc.

# 4. When done, push and create PR
git push origin feature/shopping-cart

# 5. Clean up after merge
cd ~/projects/my-app
git worktree remove ~/worktrees/my-app-feature-shopping-cart
git worktree prune
git branch -d feature/shopping-cart
```

### Bug Fix on Production

**Scenario:** Critical bug in production needs immediate attention while you're working on a feature.

```bash
# Current situation: Working on feature branch
cd ~/worktrees/my-app-feature-shopping-cart

# Create NEW hotfix branch and worktree from production using -b
cd ~/projects/my-app
git-worktree-create -b hotfix/critical-payment-bug origin/production

# Work on the hotfix
cd ~/worktrees/my-app-hotfix-critical-payment-bug
# ... fix the bug ...
git add .
git commit -m "fix: resolve payment processing error"
git push origin hotfix/critical-payment-bug

# Return to feature work
cd ~/worktrees/my-app-feature-shopping-cart
# Continue where you left off, no context switching needed!
```

### Code Review

**Scenario:** You need to review a colleague's PR without disturbing your current work.

```bash
# Your current work is safe in your worktree
# Create a new worktree for the PR branch

cd ~/projects/my-app

# Fetch the PR branch
git fetch origin pull/123/head:pr-123

# Create worktree for review
git-worktree-create pr-123

# Review the code
cd ~/worktrees/my-app-pr-123
code .
npm test

# After review, clean up
cd ~/projects/my-app
git worktree remove ~/worktrees/my-app-pr-123
git branch -d pr-123

# Return to your work
cd ~/worktrees/my-app-feature-shopping-cart
```

### Parallel Development

**Scenario:** Working on multiple features simultaneously.

```bash
cd ~/projects/my-app

# Create multiple worktrees
git-worktree-create feature/user-profile
git-worktree-create feature/notification-system
git-worktree-create feature/search-functionality

# List all worktrees
git worktree list

# Work on each feature independently
# Terminal 1
cd ~/worktrees/my-app-feature-user-profile
npm run dev

# Terminal 2
cd ~/worktrees/my-app-feature-notification-system
npm run dev -- --port 3001

# Terminal 3
cd ~/worktrees/my-app-feature-search-functionality
npm run test:watch
```

## Project-Specific Configuration

### Frontend Project (React/Next.js)

```bash
# Configuration
export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env,.env.local,node_modules,.eslintrc.js,.prettierrc,package-lock.json"

# Create worktree
cd ~/projects/my-react-app
git-worktree-create feature/new-component

# Result: All config files and node_modules are shared
# Each worktree has independent source code
```

### Python Project (Django/Flask)

```bash
# Configuration
export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env,venv,.python-version,requirements.txt"

# Create worktree
cd ~/projects/my-python-app
git-worktree-create feature/api-endpoint

# Activate venv in the new worktree
cd ~/worktrees/my-python-app-feature-api-endpoint
source venv/bin/activate  # venv is linked, so same environment
python manage.py runserver
```

### Full-Stack Monorepo

```bash
# Configuration for monorepo
export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env,node_modules,vendor,venv"

# Create NEW branch and worktree using -b flag
cd ~/projects/my-fullstack-app
git-worktree-create -b feature/user-dashboard develop

# Result: Both frontend and backend dependencies are shared
cd ~/worktrees/my-fullstack-app-feature-user-dashboard
npm run dev  # Frontend
cd api && python manage.py runserver  # Backend
```

### Mobile App (React Native)

```bash
# Configuration
export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env,node_modules,ios/Pods,android/.gradle"

# Create worktree
cd ~/projects/my-mobile-app
git-worktree-create feature/biometric-auth

# Result: Shared dependencies, independent source code
cd ~/worktrees/my-mobile-app-feature-biometric-auth
npm run ios  # Start iOS simulator
```

## Advanced Usage

### Preview Before Creating

```bash
# Preview existing branch worktree
git-worktree-create --dry-run feature/new-feature

# Preview NEW branch creation with -b flag
git-worktree-create --dry-run -b feature/experiment main

# Output shows what WOULD happen:
# ℹ Creating new branch 'feature/experiment' from 'main'...
# [DRY RUN] Would run: git worktree add -b "feature/experiment" "..." "main"
# [DRY RUN] Would create link: .vscode -> ...
# [DRY RUN] Would create link: .env -> ...
# ⚠ This was a dry run. No changes were made.

# If everything looks good, run for real
git-worktree-create -b feature/experiment main
```

### Debugging with Verbose Mode

```bash
# Get detailed information about what's happening
git-worktree-create --verbose feature/debug-test

# Output includes:
# [VERBOSE] Validating environment...
# [VERBOSE] ✓ Running in a Git repository
# [VERBOSE] ✓ WORKTREE_CONTAINING_FOLDER is set: /home/user/worktrees
# [VERBOSE] Repository name: my-app
# [VERBOSE] Sanitized branch name: feature-debug-test
# [VERBOSE] Target worktree path: /home/user/worktrees/my-app-feature-debug-test
# [VERBOSE] Processing: .vscode
# [VERBOSE]   Source: /home/user/projects/my-app/.vscode
# [VERBOSE]   Target: /home/user/worktrees/my-app-feature-debug-test/.vscode
# ... etc.
```

### Temporary Configuration Override

```bash
# Override configuration for a single command
WORKTREE_LINKED_FILES=".vscode,.env" git-worktree-create -b feature/minimal-links main

# Or use a different base directory
WORKTREE_CONTAINING_FOLDER="/tmp/temp-worktrees" git-worktree-create -b feature/temp-work develop
```

### Creating Branch from Specific Points

```bash
# Create a new branch from main
git-worktree-create -b feature/new-branch main

# Create branch from a remote branch
git-worktree-create -b feature/from-remote origin/develop

# Create branch from a specific commit
git-worktree-create -b feature/from-commit abc1234

# Create branch from a tag
git-worktree-create -b hotfix/from-release v1.2.3

# Create branch from HEAD~N (N commits back)
git-worktree-create -b experiment/rollback HEAD~5
```

## Troubleshooting Examples

### Handling Missing Files

**Problem:** Source file doesn't exist yet

```bash
# Configuration includes a file that doesn't exist
export WORKTREE_LINKED_FILES=".vscode,.env,.claude,node_modules"

# Create worktree
git-worktree-create feature/test

# Output:
# ✓ Linked: .vscode
# ✓ Linked: .env
# ⚠ Source does not exist, skipping: .claude
# ✓ Linked: node_modules

# This is normal! The tool skips missing files gracefully
```

### Fixing Broken Symlinks

**Problem:** Symlinks break when you move the repository

```bash
# Before moving (old location)
# /home/user/projects/my-app → /home/user/worktrees/my-app-feature-test

# After moving to new location
# /home/john/code/my-app (symlinks are broken!)

# Solution: Recreate the symlinks
cd /home/john/code/my-app

# Remove broken worktree
git worktree remove /home/user/worktrees/my-app-feature-test 2>/dev/null || true
rm -rf /home/user/worktrees/my-app-feature-test

# Recreate with correct paths
git-worktree-create feature/test
```

### Space in Directory Paths

**Problem:** Spaces in file paths

```bash
# Configuration with paths containing spaces
export WORKTREE_CONTAINING_FOLDER="$HOME/My Worktrees"
export WORKTREE_LINKED_FILES=".vscode,.env,My Config"

# This works! The tool handles spaces correctly
git-worktree-create feature/test

# Verify
cd "$HOME/My Worktrees/my-app-feature-test"
ls -la "My Config"  # Symlink works
```

## Real-World Scenarios

### Scenario 1: Emergency Production Fix

**Context:** Production is down, you're in the middle of feature development

```bash
# Current state: Working on feature, lots of uncommitted changes
cd ~/worktrees/my-app-feature-complex-refactor
git status  # Lots of changes

# Create emergency hotfix without disturbing current work
cd ~/projects/my-app
git fetch origin
git checkout main
git pull origin main
git-worktree-create hotfix/production-crash

# Fix the issue
cd ~/worktrees/my-app-hotfix-production-crash
# ... make fix ...
git add .
git commit -m "fix: resolve production crash in payment flow"
git push origin hotfix/production-crash

# Create PR, get it merged, deploy

# Clean up
cd ~/projects/my-app
git worktree remove ~/worktrees/my-app-hotfix-production-crash
git branch -d hotfix/production-crash

# Return to feature work - everything is exactly as you left it!
cd ~/worktrees/my-app-feature-complex-refactor
git status  # All your changes are still there
```

### Scenario 2: Long-Running Feature Branch

**Context:** Feature takes weeks, need to stay in sync with main

```bash
# Week 1: Start feature
cd ~/projects/my-app
git-worktree-create feature/major-refactor

cd ~/worktrees/my-app-feature-major-refactor
# ... work on feature ...

# Week 2: Keep up with main branch changes
cd ~/worktrees/my-app-feature-major-refactor
git fetch origin
git merge origin/main  # Or rebase
# ... continue work ...

# Week 3: Feature is ready
git push origin feature/major-refactor
# Create PR, review, merge

# Clean up
cd ~/projects/my-app
git worktree remove ~/worktrees/my-app-feature-major-refactor
git branch -d feature/major-refactor
```

### Scenario 3: Comparing Implementations

**Context:** Testing two different approaches to the same problem

```bash
cd ~/projects/my-app

# Create two worktrees for different approaches
git-worktree-create feature/approach-a-redux
git-worktree-create feature/approach-b-zustand

# Terminal 1: Implement approach A
cd ~/worktrees/my-app-feature-approach-a-redux
# ... implement using Redux ...
npm run dev -- --port 3000

# Terminal 2: Implement approach B
cd ~/worktrees/my-app-feature-approach-b-zustand
# ... implement using Zustand ...
npm run dev -- --port 3001

# Compare both running side-by-side
# Browser: localhost:3000 vs localhost:3001

# Choose the better approach and clean up the other
cd ~/projects/my-app
git worktree remove ~/worktrees/my-app-feature-approach-a-redux
git branch -d feature/approach-a-redux
```

### Scenario 4: Conference Talk Preparation

**Context:** Preparing a live demo for a conference, need main and demo branches ready

```bash
cd ~/projects/my-app

# Main branch for "before" state
cd ~/projects/my-app
git checkout main

# Demo branch for "after" state
git-worktree-create demo/conference-2024

# Set up both
# Terminal 1: Main branch (starting point)
cd ~/projects/my-app
npm run dev

# Terminal 2: Demo branch (finished result)
cd ~/worktrees/my-app-demo-conference-2024
npm run dev -- --port 3001

# During talk:
# - Show main branch: "Here's where we start"
# - Show demo branch: "Here's where we end up"
# - No need to git checkout or stash between showing both!
```

### Scenario 5: Testing Database Migrations

**Context:** Testing migrations without affecting your main development

```bash
cd ~/projects/my-django-app

# Create worktree for migration testing
git-worktree-create test/migration-rollback

cd ~/worktrees/my-django-app-test-migration-rollback

# Test migrations
python manage.py migrate
python manage.py test
# ... verify everything works ...

# If something breaks, no problem!
# Your main worktree is unaffected
cd ~/projects/my-django-app
python manage.py runserver  # Still works perfectly

# Clean up test worktree
git worktree remove ~/worktrees/my-django-app-test-migration-rollback
```

## Tips and Tricks

### Quick Navigation

Add aliases to your shell config for faster workflow:

```bash
# ~/.bashrc or ~/.zshrc
alias wt='git-worktree-create'
alias wtls='git worktree list'
alias wtrm='git worktree remove'

# Usage
wt feature/quick-test
wtls
wtrm ~/worktrees/my-app-feature-quick-test
```

### Worktree Navigation Function

```bash
# Add to ~/.bashrc or ~/.zshrc
wtcd() {
    local branch="$1"
    local repo_name=$(basename "$(git rev-parse --show-toplevel)")
    local sanitized=$(echo "$branch" | sed 's/\//-/g')
    cd "$WORKTREE_CONTAINING_FOLDER/${repo_name}-${sanitized}"
}

# Usage
wtcd feature/my-branch  # Jumps directly to the worktree
```

### Project-Specific Configuration

```bash
# Create .worktree-config in your repo root (don't commit it)
# Load it in your shell profile
if [[ -f .worktree-config ]]; then
    source .worktree-config
fi

# .worktree-config example
export WORKTREE_LINKED_FILES=".vscode,.env,node_modules,vendor"
```

### Batch Cleanup

```bash
# Remove all worktrees for a project
cd ~/projects/my-app
git worktree list | grep -v "(bare)" | awk '{print $1}' | while read path; do
    if [[ "$path" != "$(pwd)" ]]; then
        git worktree remove "$path"
    fi
done
git worktree prune
```

---

These examples should cover most common use cases. For more information, see the main [README.md](README.md) or open an issue if you have a use case not covered here!
