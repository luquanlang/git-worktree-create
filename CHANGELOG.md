# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Git Worktree Link Manager
- Core `git-worktree-create` script for creating worktrees with automatic file linking
- Automatic symbolic link creation for shared files and directories
- Branch name sanitization (converts `/` to `-` for directory names)
- Smart directory naming: `{repo-name}-{sanitized-branch-name}`
- Environment-based configuration via `WORKTREE_CONTAINING_FOLDER` and `WORKTREE_LINKED_FILES`
- `--help` flag for displaying usage information
- `--version` flag for showing version number
- `--verbose` flag for detailed output during execution
- `--dry-run` flag for previewing changes without making modifications
- Colored output for better readability (success, warning, error, info)
- Comprehensive error handling with helpful error messages
- Safe operations (never overwrites existing files)
- Installation script (`install.sh`) with multiple installation modes:
  - User-local installation (`~/.local/bin`)
  - System-wide installation (`/usr/local/bin`)
  - Custom path installation (`--prefix`)
- Environment variable configuration helper in installer
- Uninstall functionality (`install.sh --uninstall`)
- Installation verification and PATH detection
- Shell configuration detection (bash, zsh, fish)
- Comprehensive documentation:
  - README.md with installation, configuration, and usage guide
  - CONTRIBUTING.md with development guidelines and coding standards
  - EXAMPLES.md with real-world usage scenarios
  - This CHANGELOG.md for tracking changes
- MIT License
- Works as Git custom command (`git worktree-create`)
- Support for Linux, macOS, and WSL

### Features
- **Automatic File Linking**: Symlinks shared files/directories based on configuration
- **Smart Naming**: Converts branch names like `feature/login` to `my-app-feature-login`
- **Safe Operations**: Skips existing files, never overwrites
- **Dry Run**: Preview changes before applying them
- **Verbose Mode**: See detailed information about operations
- **Universal Compatibility**: Works on Linux, macOS, and WSL
- **Git Native**: Works as both `git-worktree-create` and `git worktree-create`

### Technical Details
- Written in pure Bash for maximum compatibility
- Requires Bash 4.0+ and Git 2.5+
- Follows shellcheck best practices
- Uses strict error handling (`set -euo pipefail`)
- Proper quoting for paths with spaces
- Exit codes: 0 for success, 1 for errors

## [Unreleased]

### Added
- **Branch creation with `-b` flag** - Create new branches and worktrees in one command
  - Similar to `git worktree add -b`, provides: `git-worktree-create -b <branch> <base>`
  - Automatically creates a new branch from a specified base branch
  - Works with any valid Git reference (branches, tags, commits, HEAD~N)
  - Full validation: requires base branch when using `-b`, errors if base specified without `-b`
  - Supports all existing flags (`--dry-run`, `--verbose`) with branch creation
  - Updated documentation across README, EXAMPLES, and help message
  - Examples: `git-worktree-create -b feature/new main`, `git-worktree-create -b hotfix/urgent origin/production`

### Planned Features
Future enhancements being considered (not committed to any timeline):

- **Pre/post creation hooks** - Allow custom scripts to run before/after worktree creation
- **Branch-specific link configuration** - Different links for different branch patterns
- **Force/overwrite mode** - `--force` flag to recreate existing worktrees
- **Template system** - Predefined configurations for common project types
- **Interactive mode** - Prompt for configuration if env vars not set
- **Shell completion** - Bash/Zsh/Fish completion scripts
- **Config file support** - Alternative to environment variables (YAML/JSON)
- **Repair command** - Separate `git-worktree-repair` to fix broken symlinks
- **Sync command** - Separate `git-worktree-sync` to update links after config changes

### Community Suggestions
Features requested by users (under consideration):

- None yet - we're just getting started!

## Version History

### Version Numbering

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for new functionality in a backwards compatible manner
- **PATCH** version for backwards compatible bug fixes

### Release Types

- **Major Release** (1.0.0 → 2.0.0) - Breaking changes, major new features
- **Minor Release** (1.0.0 → 1.1.0) - New features, no breaking changes
- **Patch Release** (1.0.0 → 1.0.1) - Bug fixes, small improvements

## How to Upgrade

### From v1.x to v1.y (Minor Version)

Minor version updates are backwards compatible:

```bash
# Update using installer
curl -fsSL https://raw.githubusercontent.com/yourusername/git-worktree-link-manager/main/install.sh | bash

# Or manually
cd /path/to/git-worktree-link-manager
git pull origin main
./install.sh
```

Your existing configuration will continue to work.

### From v1.x to v2.0 (Major Version - Future)

Major version updates may include breaking changes. Release notes will include:
- What's breaking and why
- Migration guide
- New features
- Deprecation warnings from previous version

## Support Policy

- **Latest Version**: Full support with new features and bug fixes
- **Previous Minor Version**: Security fixes and critical bug fixes for 6 months
- **Older Versions**: Community support only

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to this project.

## Links

- **Repository**: https://github.com/yourusername/git-worktree-link-manager
- **Issues**: https://github.com/yourusername/git-worktree-link-manager/issues
- **Releases**: https://github.com/yourusername/git-worktree-link-manager/releases

---

[1.0.0]: https://github.com/yourusername/git-worktree-link-manager/releases/tag/v1.0.0
[Unreleased]: https://github.com/yourusername/git-worktree-link-manager/compare/v1.0.0...HEAD
