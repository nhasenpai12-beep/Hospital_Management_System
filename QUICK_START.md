# Quick Start: Creating and Pushing Branches

This is a quick reference for creating and pushing branches in this repository.

## TL;DR - Most Common Use Cases

### Create and push a new feature branch:
```bash
./create_branch.sh -s -p feature/my-feature
```
This creates the branch, switches to it, and pushes it to remote in one command.

### Create a bugfix branch:
```bash
./create_branch.sh -s -p bugfix/fix-description
```

### Create a branch from main:
```bash
./create_branch.sh -f main -s -p feature/my-feature
```

## Step-by-Step: First Time Setup

1. **Make the script executable** (only needed once):
```bash
chmod +x create_branch.sh
```

2. **Update your main branch**:
```bash
git switch main
git pull origin main
```

3. **Create your new branch**:
```bash
./create_branch.sh -s -p feature/your-feature-name
```

4. **Start working**:
```bash
# Make your changes
# Then commit:
git add .
git commit -m "Your commit message"
git push
```

## Branch Name Examples

Good branch names:
- ✅ `feature/patient-registration`
- ✅ `bugfix/login-error`
- ✅ `hotfix/security-patch`
- ✅ `docs/api-documentation`
- ✅ `refactor/database-layer`

Avoid:
- ❌ `my-branch`
- ❌ `test`
- ❌ `updates`
- ❌ `fix`

## Common Workflows

### Working on a feature:
```bash
# Create branch
./create_branch.sh -s -p feature/new-feature

# Make changes and commit
git add .
git commit -m "Add new feature"
git push

# Continue working...
git add .
git commit -m "Improve feature"
git push

# When done, create a PR on GitHub
```

### Fixing a bug:
```bash
# Create branch
./create_branch.sh -s -p bugfix/issue-123

# Fix the bug
git add .
git commit -m "Fix issue #123"
git push

# Create a PR
```

### Updating documentation:
```bash
# Create branch
./create_branch.sh -s -p docs/update-readme

# Update docs
git add .
git commit -m "Update README"
git push

# Create a PR
```

## Need More Help?

- Read the full guide: [BRANCHING_GUIDE.md](BRANCHING_GUIDE.md)
- View script options: `./create_branch.sh --help`
- Check the README: [README.md](README.md)

## Manual Method (Without Script)

If you prefer not to use the script:

```bash
# Create and switch to new branch (modern way)
git switch -c feature/my-feature

# Create and switch to new branch (legacy way)
git checkout -b feature/my-feature

# Push to remote with tracking
git push -u origin feature/my-feature
```
