# Git Worktree Link Manager

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

A command-line tool that streamlines Git worktree creation by automatically creating symbolic links for shared files and directories across parallel branches.

## The Problem

When working with Git worktrees to manage multiple branches simultaneously, developers face these challenges:

- **Manual setup** - Every worktree needs manual configuration of `.vscode`, `.env`, etc.
- **Wasted disk space** - Duplicated `node_modules`, `vendor`, and other large directories
- **Inconsistent environments** - Different settings across worktrees lead to bugs
- **Time-consuming process** - Manual linking is tedious and error-prone

## The Solution

**One command** that creates a worktree **and** automatically links your shared files:

```bash
git worktree-create feature/user-auth
```

That's it! Your worktree is ready with all your configuration files and dependencies linked.

## Features

- **Automatic file linking** - Symlinks shared files/directories (`.vscode`, `.env`, `node_modules`, etc.)
- **Smart naming** - Converts branch names to clean directory names (`feature/login` → `my-app-feature-login`)
- **Safe operations** - Never overwrites existing files, skips gracefully
- **Dry-run mode** - Preview what will be created before making changes
- **Verbose output** - See exactly what's happening at each step
- **Environment-based** - Configure once, use everywhere
- **Git native** - Works as `git worktree-create` (Git custom command)

## Table of Contents
- [Git Worktree Link Manager](#git-worktree-link-manager)
  - [The Problem](#the-problem)
  - [The Solution](#the-solution)
  - [Features](#features)
  - [Requirements](#requirements)
  - [Installation](#installation)
  - [Usage](#usage)
  - [Examples](#examples)
  - [Contributing](#contributing)
  - [License](#license)

## Requirements

- **Bash** 4.0 or later
- **Git** 2.5 or later (for worktree support)
- **OS**: Linux, macOS, or WSL on Windows

## Installation

### Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/git-worktree-link-manager/main/install.sh | bash
```

The installer will:
1. Install `git-worktree-create` to `~/.local/bin`
2. Offer to configure environment variables
3. Test the installation
4. Show you what to do next

### Manual Installation with Installer

```bash
# Clone the repository
git clone https://github.com/yourusername/git-worktree-link-manager.git
cd git-worktree-link-manager

# Run the installer
./install.sh

# Or install system-wide (requires sudo)
./install.sh --system

# Or install to a custom location
./install.sh --prefix=/opt/mytools
```

### Manual Installation without Installer

```bash
# Clone the repository
git clone https://github.com/yourusername/git-worktree-link-manager.git
cd git-worktree-link-manager

# Copy to a directory in your PATH
cp git-worktree-create ~/.local/bin/
chmod +x ~/.local/bin/git-worktree-create

# Verify installation
git-worktree-create --version
```

### From Source (Development)

```bash
# Clone the repository
git clone https://github.com/yourusername/git-worktree-link-manager.git
cd git-worktree-link-manager

# Create a symlink in your PATH
ln -s "$(pwd)/git-worktree-create" ~/.local/bin/git-worktree-create

# Now you can edit the script and changes take effect immediately
```

## Configuration

Add these environment variables to your shell configuration file (`~/.bashrc`, `~/.zshrc`, `~/.bash_profile`, etc.):

```bash
# Required: Base directory for all worktrees
export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"

# Optional: Comma-separated list of files/directories to link
export WORKTREE_LINKED_FILES=".vscode,.env,.claude,node_modules"
```

Then reload your configuration:

```bash
source ~/.bashrc  # or ~/.zshrc, etc.
```

### Configuration by Project Type

**Frontend (Node.js/React/Vue):**
```bash
export WORKTREE_LINKED_FILES=".vscode,.env,.env.local,node_modules,.eslintrc,.prettierrc"
```

**Python:**
```bash
export WORKTREE_LINKED_FILES=".vscode,.env,venv,.python-version,.pylintrc"
```

**PHP/Laravel:**
```bash
export WORKTREE_LINKED_FILES=".vscode,.env,vendor,.idea"
```

**Full-Stack:**
```bash
export WORKTREE_LINKED_FILES=".vscode,.env,node_modules,vendor,venv"
```

## Usage

### Basic Usage

```bash
# Create a worktree for an existing branch
git-worktree-create feature/user-login

# Or use as a Git subcommand
git worktree-create feature/user-login
```

### Creating a New Branch with -b Flag

The `-b` flag creates a new branch from a base branch before creating the worktree, similar to `git worktree add -b`:

```bash
# Create a new feature branch from main
git-worktree-create -b feature/new-api main

# Create a hotfix from production branch
git-worktree-create -b hotfix/critical-bug origin/production

# Create an experiment from a specific commit
git-worktree-create -b experiment/idea HEAD~5

# Create from develop branch
git worktree-create -b feature/user-dashboard develop
```

### Options

```bash
# Preview what would be created (dry run)
git-worktree-create --dry-run feature/new-feature

# Preview branch creation
git-worktree-create --dry-run -b feature/experiment main

# Show detailed output
git-worktree-create --verbose feature/bug-fix

# Create new branch with detailed output
git-worktree-create --verbose -b feature/new-api develop

# Show help
git-worktree-create --help

# Show version
git-worktree-create --version
```

### Example Output

**Existing branch:**
```bash
$ git-worktree-create feature/user-auth

ℹ Creating worktree for branch 'feature/user-auth'...
✓ Worktree created at: /home/user/worktrees/my-app-feature-user-auth
ℹ Creating symbolic links for shared files...
✓ Linked: .vscode
✓ Linked: .env
✓ Linked: node_modules
⚠ Source does not exist, skipping: .claude

✓ Worktree setup complete!

To start working in your new worktree:
  cd /home/user/worktrees/my-app-feature-user-auth
```

**Creating a new branch:**
```bash
$ git-worktree-create -b feature/new-api main

ℹ Creating new branch 'feature/new-api' from 'main'...
✓ Created branch 'feature/new-api' from 'main'
✓ Worktree created at: /home/user/worktrees/my-app-feature-new-api
ℹ Creating symbolic links for shared files...
✓ Linked: .vscode
✓ Linked: .env
✓ Linked: node_modules

✓ Worktree setup complete!

To start working in your new worktree:
  cd /home/user/worktrees/my-app-feature-new-api
```

## How It Works

1. **Validates environment** - Checks you're in a Git repository and variables are set
2. **Sanitizes branch name** - Converts `feature/login` to `feature-login` for the directory name
3. **Creates worktree** - Runs `git worktree add <path> <branch>`
4. **Creates symlinks** - Links each file/directory from `WORKTREE_LINKED_FILES`
5. **Reports results** - Shows what was linked, skipped, or failed

### Directory Naming

Worktrees are named: `{repository-name}-{sanitized-branch-name}`

**Examples:**
- Branch `feature/login` → Directory `my-app-feature-login`
- Branch `bugfix/issue-123` → Directory `my-app-bugfix-issue-123`
- Branch `main` → Directory `my-app-main`

### Symbolic Links

Symbolic links are created from the main repository to the worktree:

```
Main Repository                    Worktree
/home/user/repos/my-app/          /home/user/worktrees/my-app-feature-login/
├── .vscode/                      ├── .vscode/ → /home/user/repos/my-app/.vscode/
├── .env                          ├── .env → /home/user/repos/my-app/.env
├── node_modules/                 ├── node_modules/ → /home/user/repos/my-app/node_modules/
└── src/                          └── src/ (independent copy from Git)
```

**Benefits:**
- Changes to `.vscode` settings apply to all worktrees
- Single `node_modules` directory saves disk space
- Consistent environment variables across all worktrees

## Benefits

### vs. Manual Worktree Setup

**Manual Process:**
```bash
git worktree add ../my-app-feature-login feature/login
cd ../my-app-feature-login
ln -s ../my-app/.vscode .vscode
ln -s ../my-app/.env .env
ln -s ../my-app/node_modules node_modules
# ... repeat for every worktree
```

**With git-worktree-create:**
```bash
git-worktree-create feature/login
cd ~/worktrees/my-app-feature-login
```

**Savings:**
- **Time**: 30 seconds vs. 5+ minutes per worktree
- **Disk Space**: Single `node_modules` (typically 200MB-1GB saved per worktree)
- **Errors**: Zero manual linking errors
- **Consistency**: Guaranteed identical configuration

## Troubleshooting

### "WORKTREE_CONTAINING_FOLDER is not set"

**Solution:** Add the environment variable to your shell configuration:

```bash
echo 'export WORKTREE_CONTAINING_FOLDER="$HOME/worktrees"' >> ~/.bashrc
source ~/.bashrc
```

### "Not a Git repository"

**Solution:** Run the command from inside a Git repository:

```bash
cd /path/to/your/git/repo
git-worktree-create feature/branch
```

### "Branch does not exist"

**Solution:** Create the branch first, or create it with the worktree:

```bash
# Option 1: Create branch first
git branch feature/new-feature
git-worktree-create feature/new-feature

# Option 2: Create branch from a commit
git-worktree-create feature/new-feature origin/main
```

### "Worktree already exists"

**Solution:** Remove the existing worktree first:

```bash
git worktree remove /path/to/worktree
# or
rm -rf /path/to/worktree
git worktree prune
```

### Symlinks not working on Windows

**Solution:** Use WSL (Windows Subsystem for Linux) for proper symlink support. Git Bash on Windows has limited symlink capabilities.

### "Permission denied" when creating symlinks

**Solution:** Check that you have write permissions in both the source and target directories:

```bash
ls -la /path/to/source/file
ls -la /path/to/worktree/directory
```

## Uninstallation

Run the installer with the `--uninstall` flag:

```bash
./install.sh --uninstall
```

Or manually remove the script:

```bash
rm ~/.local/bin/git-worktree-create
# or
sudo rm /usr/local/bin/git-worktree-create
```

Then remove the environment variables from your shell configuration file.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Examples

For detailed real-world usage examples, see [EXAMPLES.md](EXAMPLES.md).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and release notes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with Bash for universal compatibility
- Inspired by Git's excellent worktree feature
- Designed to follow Unix philosophy: do one thing well

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/git-worktree-link-manager/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/git-worktree-link-manager/discussions)
- **Documentation**: This README and [EXAMPLES.md](EXAMPLES.md)

---

Made with ⚡ by developers, for developers.
