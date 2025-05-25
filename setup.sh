#!/usr/bin/env bash
#
# Environment Setup Script
# ------------------------
# This script orchestrates the setup of a complete development environment
# by running component scripts in the correct order.
#
# Usage: ./setup.sh [OPTIONS]
#
# Options:
#   --help          Show this help message and exit
#   --skip-programs Skip installing basic programs
#   --skip-yay      Skip installing yay package manager
#   --skip-fonts    Skip installing fonts
#   --skip-keyd     Skip configuring keyboard remapping
#   --skip-git      Skip configuring git
#   --skip-zsh      Skip setting up zsh shell
#   --skip-symlinks Skip creating configuration symlinks
#   --only=SCRIPT   Run only the specified script (e.g., --only=fonts)
#
# Examples:
#   ./setup.sh                  # Run full setup
#   ./setup.sh --skip-programs  # Skip programs installation
#   ./setup.sh --only=symlinks  # Only create symlinks

# Set exit on error
set -e

# Set script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export ENV_DIR="$SCRIPT_DIR"

# Parse command line arguments
SKIP_PROGRAMS=false
SKIP_YAY=false
SKIP_FONTS=false
SKIP_KEYD=false
SKIP_GIT=false
SKIP_ZSH=false
SKIP_SYMLINKS=false
ONLY_SCRIPT=""

for arg in "$@"; do
  case $arg in
    --help)
      grep -E '^# |^#$' "$0" | sed 's/^# //' | sed 's/^#//'
      exit 0
      ;;
    --skip-programs)
      SKIP_PROGRAMS=true
      ;;
    --skip-yay)
      SKIP_YAY=true
      ;;
    --skip-fonts)
      SKIP_FONTS=true
      ;;
    --skip-keyd)
      SKIP_KEYD=true
      ;;
    --skip-git)
      SKIP_GIT=true
      ;;
    --skip-zsh)
      SKIP_ZSH=true
      ;;
    --skip-symlinks)
      SKIP_SYMLINKS=true
      ;;
    --only=*)
      ONLY_SCRIPT="${arg#*=}"
      ;;
    *)
      echo "Unknown option: $arg"
      echo "Use --help to see available options"
      exit 1
      ;;
  esac
done

# Function to print colored status messages
print_status() {
  local color=$1
  local message=$2

  # ANSI color codes
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local RED='\033[0;31m'
  local BLUE='\033[0;34m'
  local NC='\033[0m' # No Color

  case $color in
    "success")
      echo -e "${GREEN}✓  ${message}${NC}"
      ;;
    "warning")
      echo -e "${YELLOW}⚠  ${message}${NC}"
      ;;
    "error")
      echo -e "${RED}✗  ${message}${NC}"
      ;;
    "info")
      echo -e "${BLUE}ℹ  ${message}${NC}"
      ;;
    *)
      echo "$message"
      ;;
  esac
}

# Function to run a component script
run_script() {
  local script_name=$1
  local script_path="$ENV_DIR/scripts/${script_name}.sh"

  # Skip if requested
  if [ "$ONLY_SCRIPT" != "" ] && [ "$ONLY_SCRIPT" != "$script_name" ]; then
    print_status "info" "Skipping $script_name (--only=$ONLY_SCRIPT specified)"
    return 0
  fi

  # Skip based on flags
  local skip_var="SKIP_$(echo $script_name | tr '[:lower:]' '[:upper:]')"
  if [ "${!skip_var}" = "true" ]; then
    print_status "info" "Skipping $script_name (--skip-$script_name specified)"
    return 0
  fi

  # Check if script exists
  if [ ! -f "$script_path" ]; then
    print_status "error" "Script $script_path not found"
    return 1
  fi

  # Make script executable if needed
  if [ ! -x "$script_path" ]; then
    print_status "warning" "Script $script_path is not executable. Setting permissions..."
    chmod +x "$script_path" || {
      print_status "error" "Failed to set executable permissions on $script_path"
      return 1
    }
  fi

  # Execute the script
  print_status "info" "Running $script_name..."
  "$script_path"
  local status=$?

  if [ $status -ne 0 ]; then
    print_status "error" "$script_name failed with exit code $status"
    return $status
  fi

  print_status "success" "$script_name completed successfully"
  return 0
}

# Print header
echo "======================================"
echo "   Environment Setup Script"
echo "======================================"
echo

# Execute the component scripts in order
if [ "$ONLY_SCRIPT" != "" ]; then
  print_status "info" "Running only the $ONLY_SCRIPT script"
fi

# Run the scripts
run_script "programs" || exit 1
run_script "yay" || exit 1
run_script "fonts" || exit 1
run_script "keyd" || exit 1
run_script "git" || exit 1
run_script "zsh" || exit 1
run_script "symlinks" || exit 1

# Print completion message
echo
echo "======================================"
print_status "success" "Environment setup completed successfully!"
echo "======================================"

exit 0
