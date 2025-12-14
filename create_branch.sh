#!/usr/bin/env bash

# Branch Creation and Push Helper Script
# This script helps you create and push new branches to the repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Function to display usage
usage() {
    echo "Usage: $0 [OPTIONS] <branch-name>"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -f, --from BRANCH   Create branch from specific branch (default: current branch)"
    echo "  -p, --push          Push the branch to remote after creation"
    echo "  -s, --switch        Switch to the new branch after creation"
    echo ""
    echo "Examples:"
    echo "  $0 feature/new-feature              # Create branch from current branch"
    echo "  $0 -p feature/new-feature           # Create and push branch"
    echo "  $0 -f main -p feature/new-feature   # Create from main and push"
    echo "  $0 -s -p bugfix/issue-123           # Create, switch to, and push branch"
    echo ""
    echo "Common branch naming conventions:"
    echo "  feature/description    - New features"
    echo "  bugfix/description     - Bug fixes"
    echo "  hotfix/description     - Critical fixes"
    echo "  release/version        - Release branches"
    echo "  docs/description       - Documentation updates"
    exit 1
}

# Parse command line arguments
PUSH_BRANCH=false
SWITCH_BRANCH=false
FROM_BRANCH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -p|--push)
            PUSH_BRANCH=true
            shift
            ;;
        -s|--switch)
            SWITCH_BRANCH=true
            shift
            ;;
        -f|--from)
            FROM_BRANCH="$2"
            shift 2
            ;;
        -*)
            print_error "Unknown option: $1"
            usage
            ;;
        *)
            BRANCH_NAME="$1"
            shift
            ;;
    esac
done

# Check if branch name is provided
if [ -z "$BRANCH_NAME" ]; then
    print_error "Branch name is required"
    usage
fi

# Validate branch name
if [[ ! "$BRANCH_NAME" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
    print_error "Invalid branch name. Use only alphanumeric characters, hyphens, underscores, periods, and forward slashes."
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository"
    exit 1
fi

# Get current branch if FROM_BRANCH is not specified
if [ -z "$FROM_BRANCH" ]; then
    FROM_BRANCH=$(git branch --show-current)
    print_info "Creating branch from current branch: $FROM_BRANCH"
else
    print_info "Creating branch from: $FROM_BRANCH"
fi

# Check if source branch exists
if ! git rev-parse --verify "$FROM_BRANCH" > /dev/null 2>&1; then
    print_error "Source branch '$FROM_BRANCH' does not exist"
    exit 1
fi

# Check if branch already exists
if git rev-parse --verify "$BRANCH_NAME" > /dev/null 2>&1; then
    print_error "Branch '$BRANCH_NAME' already exists"
    exit 1
fi

# Create the branch
print_info "Creating branch: $BRANCH_NAME"
if git branch "$BRANCH_NAME" "$FROM_BRANCH"; then
    print_success "Branch '$BRANCH_NAME' created successfully"
else
    print_error "Failed to create branch"
    exit 1
fi

# Switch to the branch if requested
if [ "$SWITCH_BRANCH" = true ]; then
    print_info "Switching to branch: $BRANCH_NAME"
    if git switch "$BRANCH_NAME" 2>/dev/null || git checkout "$BRANCH_NAME" 2>/dev/null; then
        print_success "Switched to branch '$BRANCH_NAME'"
    else
        print_error "Failed to switch to branch"
        exit 1
    fi
fi

# Push the branch if requested
if [ "$PUSH_BRANCH" = true ]; then
    print_info "Pushing branch to remote..."
    if git push -u origin "$BRANCH_NAME"; then
        print_success "Branch '$BRANCH_NAME' pushed to remote"
    else
        print_error "Failed to push branch"
        exit 1
    fi
fi

print_success "Done!"
echo ""
print_info "What's next?"
if [ "$SWITCH_BRANCH" = false ]; then
    echo "  - Switch to the branch: git switch $BRANCH_NAME"
fi
if [ "$PUSH_BRANCH" = false ]; then
    echo "  - Push to remote: git push -u origin $BRANCH_NAME"
fi
echo "  - Make your changes and commit them"
echo "  - Create a pull request when ready"
