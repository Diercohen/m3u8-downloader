#!/bin/bash

# M3U8 Downloader Installation Script
# This script installs ffmpeg (if needed) and sets up the m3u8 downloader alias

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect user's shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        # Try to detect from SHELL environment variable
        case "$SHELL" in
            */zsh) echo "zsh" ;;
            */bash) echo "bash" ;;
            *) echo "bash" ;;  # Default to bash
        esac
    fi
}

# Function to get shell config file path
get_shell_config() {
    local shell_type="$1"
    local config_file=""
    
    case "$shell_type" in
        "zsh")
            if [ -f "$HOME/.zshrc" ]; then
                config_file="$HOME/.zshrc"
            else
                config_file="$HOME/.zshrc"
            fi
            ;;
        "bash")
            if [ -f "$HOME/.bashrc" ]; then
                config_file="$HOME/.bashrc"
            elif [ -f "$HOME/.bash_profile" ]; then
                config_file="$HOME/.bash_profile"
            else
                config_file="$HOME/.bashrc"
            fi
            ;;
    esac
    
    echo "$config_file"
}

# Function to check if ffmpeg is installed
check_ffmpeg() {
    if command_exists ffmpeg; then
        print_success "ffmpeg is already installed"
        ffmpeg -version | head -n 1
        return 0
    else
        print_warning "ffmpeg is not installed"
        return 1
    fi
}

# Function to install ffmpeg on macOS
install_ffmpeg_macos() {
    print_status "Installing ffmpeg on macOS..."
    
    if command_exists brew; then
        print_status "Using Homebrew to install ffmpeg..."
        brew install ffmpeg
    else
        print_error "Homebrew is not installed. Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        print_error "After installing Homebrew, run this script again."
        exit 1
    fi
}

# Function to install ffmpeg on Linux
install_ffmpeg_linux() {
    print_status "Installing ffmpeg on Linux..."
    
    if command_exists apt-get; then
        print_status "Using apt-get to install ffmpeg..."
        sudo apt-get update
        sudo apt-get install -y ffmpeg
    elif command_exists yum; then
        print_status "Using yum to install ffmpeg..."
        sudo yum install -y ffmpeg
    elif command_exists dnf; then
        print_status "Using dnf to install ffmpeg..."
        sudo dnf install -y ffmpeg
    elif command_exists pacman; then
        print_status "Using pacman to install ffmpeg..."
        sudo pacman -S ffmpeg
    else
        print_error "Could not detect package manager. Please install ffmpeg manually."
        exit 1
    fi
}

# Function to install ffmpeg
install_ffmpeg() {
    local os=$(uname -s)
    
    case "$os" in
        "Darwin")
            install_ffmpeg_macos
            ;;
        "Linux")
            install_ffmpeg_linux
            ;;
        *)
            print_error "Unsupported operating system: $os"
            print_error "Please install ffmpeg manually for your system."
            exit 1
            ;;
    esac
}

# Function to check if alias already exists
alias_exists() {
    local config_file="$1"
    local alias_pattern="alias m3u8="
    
    if [ -f "$config_file" ]; then
        grep -q "^$alias_pattern" "$config_file" 2>/dev/null
    else
        return 1
    fi
}

# Function to remove existing alias
remove_existing_alias() {
    local config_file="$1"
    local temp_file=$(mktemp)
    
    print_warning "Removing existing m3u8 alias..."
    grep -v "^alias m3u8=" "$config_file" > "$temp_file" 2>/dev/null || true
    mv "$temp_file" "$config_file"
}

# Function to add the m3u8 alias
add_m3u8_alias() {
    local config_file="$1"
    local alias_line='alias m3u8='\''echo "Enter m3u8 link to download by ffmpeg:";read link;echo "Enter output filename:";read filename;echo "Starting download...";ffmpeg -i "$link" -bsf:a aac_adtstoasc -vcodec copy -c copy -crf 50 $filename.mp4 && echo "\033[0;32m Download completed successfully! File saved to: $(pwd)/$filename.mp4"'\'''
    
    # Create config file if it doesn't exist
    if [ ! -f "$config_file" ]; then
        touch "$config_file"
        print_status "Created shell config file: $config_file"
    fi
    
    # Add alias to config file
    echo "" >> "$config_file"
    echo "# M3U8 Downloader alias" >> "$config_file"
    echo "$alias_line" >> "$config_file"
    
    print_success "Added m3u8 alias to $config_file"
}

# Main installation process
main() {
    print_status "Starting M3U8 Downloader installation..."
    echo ""
    
    # Check and install ffmpeg
    if ! check_ffmpeg; then
        install_ffmpeg
        print_success "ffmpeg installation completed"
    fi
    
    echo ""
    
    # Detect shell and config file
    local shell_type=$(detect_shell)
    local config_file=$(get_shell_config "$shell_type")
    
    print_status "Detected shell: $shell_type"
    print_status "Using config file: $config_file"
    
    # Check if alias already exists
    if alias_exists "$config_file"; then
        print_warning "m3u8 alias already exists in $config_file"
        remove_existing_alias "$config_file"
    fi
    
    # Add the alias
    add_m3u8_alias "$config_file"
    
    echo ""
    print_success "Installation completed successfully!"
    echo ""
    print_status "To use the m3u8 downloader:"
    echo "  1. Reload your shell configuration:"
    echo "     source $config_file"
    echo "  2. Or restart your terminal"
    echo "  3. Then run: m3u8"
    echo ""
    print_status "Usage:"
    echo "  m3u8"
    echo "  # Follow the prompts to enter m3u8 link and output filename"
    echo ""
}

# Run main function
main "$@"