#!/usr/bin/env bash
#
# install.sh - Installation script for git-worktree-create
#
# This script installs git-worktree-create to your system and optionally
# configures environment variables.
#
# Usage:
#   ./install.sh              # Install to ~/.local/bin (recommended)
#   ./install.sh --system     # Install to /usr/local/bin (requires sudo)
#   ./install.sh --prefix=/custom/path
#   ./install.sh --uninstall  # Remove installation
#

set -euo pipefail

VERSION="1.0.0"
SCRIPT_NAME="git-worktree-create"
SCRIPT_URL="https://raw.githubusercontent.com/luquanlang/git-worktree-create/main/git-worktree-create"

# Color codes
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    BOLD=''
    NC=''
fi

# Output functions
success() {
    echo -e "${GREEN}✓${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $*"
}

# Print header
print_header() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║          Git Worktree Link Manager Installer               ║"
    echo "║                      Version $VERSION                         ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# Print footer
print_footer() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                 Installation Complete! 🎉                  ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# Check dependencies
check_dependencies() {
    local missing_deps=()

    # Check for bash
    if ! command -v bash &> /dev/null; then
        missing_deps+=("bash")
    else
        local bash_version
        bash_version=$(bash --version | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
        success "Bash version $bash_version detected"
    fi

    # Check for git
    if ! command -v git &> /dev/null; then
        missing_deps+=("git")
    else
        local git_version
        git_version=$(git --version | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        success "Git version $git_version detected"
    fi

    # Check for curl or wget
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl/wget")
    else
        if command -v curl &> /dev/null; then
            success "curl detected for downloads"
        elif command -v wget &> /dev/null; then
            success "wget detected for downloads"
        fi
    fi

    # Report missing dependencies
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        error "Missing required dependencies: ${missing_deps[*]}"
        echo ""
        echo "Please install the missing dependencies and try again."
        exit 1
    fi
}

# Detect shell configuration file
detect_shell_config() {
    local shell_name
    shell_name=$(basename "$SHELL")

    case "$shell_name" in
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                echo "$HOME/.bashrc"
            elif [[ -f "$HOME/.bash_profile" ]]; then
                echo "$HOME/.bash_profile"
            else
                echo "$HOME/.bashrc"
            fi
            ;;
        zsh)
            echo "$HOME/.zshrc"
            ;;
        fish)
            echo "$HOME/.config/fish/config.fish"
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# Check if path is in PATH
is_in_path() {
    local dir="$1"
    case ":$PATH:" in
        *":$dir:"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Download the script from remote URL
download_script() {
    local temp_file
    temp_file=$(mktemp)
    
    if command -v curl &> /dev/null; then
        if ! curl -fsSL "$SCRIPT_URL" -o "$temp_file"; then
            rm -f "$temp_file"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        if ! wget -q "$SCRIPT_URL" -O "$temp_file"; then
            rm -f "$temp_file"
            return 1
        fi
    else
        error "Neither curl nor wget found. Cannot download script."
        rm -f "$temp_file"
        return 1
    fi
    
    echo "$temp_file"
}

# Install the script
install_script() {
    local install_dir="$1"
    local script_path="$install_dir/$SCRIPT_NAME"

    # Create install directory if it doesn't exist
    if [[ ! -d "$install_dir" ]]; then
        info "Creating directory: $install_dir"
        mkdir -p "$install_dir"
    fi

    local source_script=""
    # Check if we're running from a file
    if [[ -n "${BASH_SOURCE[0]:-}" ]] && [[ "${BASH_SOURCE[0]}" != "/dev/stdin" ]]; then
        local script_dir
        script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
        source_script="$script_dir/$SCRIPT_NAME"
    fi

    # Try local file first, then download if not found
    if [[ -n "$source_script" ]] && [[ -f "$source_script" ]]; then
        info "Installing from local file..."
        cp "$source_script" "$script_path"
    else
        info "Local file not found, downloading from remote..."
        local temp_file
        temp_file=$(download_script)
        
        if [[ $? -ne 0 ]]; then
            error "Failed to download script"
            exit 1
        fi
        
        mv "$temp_file" "$script_path"
    fi
    chmod +x "$script_path"
    success "Installed to: $script_path"
    success "Made executable"

    echo "$script_path"
}

# Configure environment variables
configure_environment() {
    local shell_config
    shell_config=$(detect_shell_config)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Would you like to configure environment variables now? [Y/n]"
    read -r response

    if [[ "$response" =~ ^[Nn] ]]; then
        echo ""
        info "Skipping environment configuration"
        show_manual_setup_instructions
        return
    fi

    success "Detected shell config: $shell_config"

    # Ask for WORKTREE_CONTAINING_FOLDER
    echo ""
    echo "Enter the base directory for worktrees (e.g., \$HOME/worktrees):"
    echo -n "> "
    read -r worktree_folder

    if [[ -z "$worktree_folder" ]]; then
        worktree_folder="\$HOME/worktrees"
    fi

    # Ask for WORKTREE_LINKED_FILES
    echo ""
    echo "Enter files/directories to link (comma-separated, or leave empty):"
    echo "Examples: .vscode,.env,node_modules"
    echo -n "> "
    read -r linked_files

    # Prepare configuration
    local config_lines=()
    config_lines+=("")
    config_lines+=("# Git Worktree Link Manager configuration")
    config_lines+=("export WORKTREE_CONTAINING_FOLDER=\"$worktree_folder\"")

    if [[ -n "$linked_files" ]]; then
        config_lines+=("export WORKTREE_LINKED_FILES=\"$linked_files\"")
    fi

    # Check if configuration already exists
    if [[ -f "$shell_config" ]] && grep -q "WORKTREE_CONTAINING_FOLDER" "$shell_config" 2>/dev/null; then
        warning "Configuration already exists in $shell_config"
        echo "Would you like to update it? [y/N]"
        read -r update_response

        if [[ ! "$update_response" =~ ^[Yy] ]]; then
            info "Keeping existing configuration"
            return
        fi

        # Remove old configuration
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' '/# Git Worktree Link Manager configuration/d' "$shell_config"
            sed -i '' '/WORKTREE_CONTAINING_FOLDER/d' "$shell_config"
            sed -i '' '/WORKTREE_LINKED_FILES/d' "$shell_config"
        else
            sed -i '/# Git Worktree Link Manager configuration/d' "$shell_config"
            sed -i '/WORKTREE_CONTAINING_FOLDER/d' "$shell_config"
            sed -i '/WORKTREE_LINKED_FILES/d' "$shell_config"
        fi
    fi

    # Append configuration
    for line in "${config_lines[@]}"; do
        echo "$line" >> "$shell_config"
    done

    success "Added configuration to $shell_config"

    # Source the configuration
    if [[ -f "$shell_config" ]]; then
        # shellcheck disable=SC1090
        source "$shell_config" 2>/dev/null || true
        success "Reloaded shell configuration"
    fi
}

# Show manual setup instructions
show_manual_setup_instructions() {
    local shell_config
    shell_config=$(detect_shell_config)

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${BOLD}Manual Configuration:${NC}"
    echo ""
    echo "Add these lines to your shell configuration file ($shell_config):"
    echo ""
    echo "  # Git Worktree Link Manager configuration"
    echo "  export WORKTREE_CONTAINING_FOLDER=\"\$HOME/worktrees\""
    echo "  export WORKTREE_LINKED_FILES=\".vscode,.env,node_modules\""
    echo ""
    echo "Then reload your configuration:"
    echo "  source $shell_config"
    echo ""
}

# Test installation
test_installation() {
    local script_path="$1"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    info "Testing installation..."

    if command -v "$SCRIPT_NAME" &> /dev/null; then
        success "$SCRIPT_NAME is accessible in PATH"
        local version_output
        version_output=$("$SCRIPT_NAME" --version)
        success "$version_output"
    elif [[ -x "$script_path" ]]; then
        success "$SCRIPT_NAME is installed at $script_path"
        warning "The installation directory is not in your PATH"
        echo ""
        echo "Add it to your PATH by adding this line to your shell config:"
        echo "  export PATH=\"$(dirname "$script_path"):\$PATH\""
    else
        error "Installation test failed"
        exit 1
    fi
}

# Uninstall
uninstall() {
    print_header

    local locations=(
        "$HOME/.local/bin/$SCRIPT_NAME"
        "/usr/local/bin/$SCRIPT_NAME"
    )

    local found=false

    for location in "${locations[@]}"; do
        if [[ -f "$location" ]]; then
            found=true
            echo "Found installation at: $location"
            echo -n "Remove this installation? [y/N] "
            read -r response

            if [[ "$response" =~ ^[Yy] ]]; then
                if rm "$location" 2>/dev/null; then
                    success "Removed $location"
                else
                    error "Failed to remove $location (may need sudo)"
                    echo "Try: sudo rm $location"
                fi
            else
                info "Skipped $location"
            fi
        fi
    done

    if [[ "$found" == false ]]; then
        info "No installation found in standard locations"
        echo ""
        echo "Checked:"
        for location in "${locations[@]}"; do
            echo "  - $location"
        done
    fi

    echo ""
    info "To remove environment configuration, manually edit your shell config file"
    info "and remove lines containing WORKTREE_CONTAINING_FOLDER and WORKTREE_LINKED_FILES"
    echo ""
}

# Main installation flow
main() {
    local install_mode="user-local"
    local custom_prefix=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --system)
                install_mode="system"
                shift
                ;;
            --prefix=*)
                custom_prefix="${1#*=}"
                install_mode="custom"
                shift
                ;;
            --uninstall)
                uninstall
                exit 0
                ;;
            -h|--help)
                echo "Git Worktree Link Manager Installer"
                echo ""
                echo "Usage:"
                echo "  ./install.sh              Install to ~/.local/bin (recommended)"
                echo "  ./install.sh --system     Install to /usr/local/bin (requires sudo)"
                echo "  ./install.sh --prefix=/path  Install to custom location"
                echo "  ./install.sh --uninstall  Remove installation"
                echo ""
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    print_header

    # Check dependencies
    check_dependencies

    echo ""
    info "Installing $SCRIPT_NAME..."
    echo ""

    # Determine installation directory
    local install_dir
    case "$install_mode" in
        user-local)
            install_dir="$HOME/.local/bin"
            echo "Installing to user-local directory (recommended)"
            echo "Location: $install_dir"
            ;;
        system)
            install_dir="/usr/local/bin"
            echo "Installing to system-wide directory"
            echo "Location: $install_dir"
            if [[ ! -w "$install_dir" ]]; then
                warning "This requires sudo privileges"
                echo "You may be prompted for your password"
                echo ""
            fi
            ;;
        custom)
            install_dir="$custom_prefix"
            echo "Installing to custom directory"
            echo "Location: $install_dir"
            ;;
    esac

    echo ""

    # Install the script
    local script_path
    if [[ "$install_mode" == "system" ]] && [[ ! -w "$install_dir" ]]; then
        # Download to temp file first for system installation
        info "Downloading script for system installation..."
        local temp_file
        temp_file=$(download_script)
        
        if [[ $? -ne 0 ]]; then
            error "Failed to download script"
            exit 1
        fi
        
        # Need sudo for system installation
        sudo bash -c "
            mkdir -p '$install_dir'
            mv '$temp_file' '$install_dir/$SCRIPT_NAME'
            chmod +x '$install_dir/$SCRIPT_NAME'
        "
        script_path="$install_dir/$SCRIPT_NAME"
        success "Installed to: $script_path"
        success "Made executable"
    else
        script_path=$(install_script "$install_dir")
    fi

    # Check if install directory is in PATH
    if ! is_in_path "$install_dir"; then
        echo ""
        warning "Installation directory is not in your PATH"
        echo ""
        echo "Add it by adding this line to your shell configuration:"
        echo "  export PATH=\"$install_dir:\$PATH\""
    fi

    # Configure environment variables
    configure_environment

    # Test installation
    test_installation "$script_path"

    # Success message
    print_footer

    echo "Next steps:"
    echo "  1. Restart your terminal or run: source $(detect_shell_config)"
    echo "  2. Navigate to a Git repository"
    echo "  3. Run: git worktree-create feature/my-branch"
    echo ""
    echo "Documentation: https://github.com/yourusername/git-worktree-link-manager"
    echo ""
}

# Run main
main "$@"
