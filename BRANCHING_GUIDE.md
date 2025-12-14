# Branch Management Guide

This guide explains how to create and manage branches in this repository.

## Quick Start

### Using the Helper Script

We've provided a convenient script to help you create and push branches:

```bash
# Make the script executable (first time only)
chmod +x create_branch.sh

# Create a new branch
./create_branch.sh feature/my-new-feature

# Create and push a branch
./create_branch.sh -p feature/my-new-feature

# Create from a specific branch and push
./create_branch.sh -f main -p feature/my-new-feature

# Create, switch to, and push a branch
./create_branch.sh -s -p bugfix/fix-issue
```

### Manual Branch Creation

If you prefer to create branches manually:

```bash
# Create a new branch from current branch
git branch feature/my-feature

# Create and switch to a new branch
git checkout -b feature/my-feature

# Create a branch from a specific branch
git checkout -b feature/my-feature main

# Push the branch to remote
git push -u origin feature/my-feature
```

## Branch Naming Conventions

Use these prefixes to categorize your branches:

- **`feature/`** - New features or enhancements
  - Example: `feature/patient-registration`
  - Example: `feature/appointment-scheduling`

- **`bugfix/`** - Bug fixes
  - Example: `bugfix/login-error`
  - Example: `bugfix/null-pointer-exception`

- **`hotfix/`** - Critical fixes for production
  - Example: `hotfix/security-patch`
  - Example: `hotfix/data-corruption`

- **`release/`** - Release preparation
  - Example: `release/v1.0.0`
  - Example: `release/v2.1.0`

- **`docs/`** - Documentation updates
  - Example: `docs/api-documentation`
  - Example: `docs/setup-guide`

- **`refactor/`** - Code refactoring
  - Example: `refactor/database-layer`
  - Example: `refactor/ui-components`

- **`test/`** - Testing improvements
  - Example: `test/integration-tests`
  - Example: `test/unit-coverage`

## Branching Workflow

### 1. Creating a New Branch

Always create branches from the latest version of your base branch (usually `main` or `develop`):

```bash
# Update your local main branch
git checkout main
git pull origin main

# Create your new branch
./create_branch.sh -s -p feature/my-feature
```

### 2. Working on Your Branch

```bash
# Make changes to your code
# ... edit files ...

# Stage and commit your changes
git add .
git commit -m "Add meaningful commit message"

# Push changes to remote
git push origin feature/my-feature
```

### 3. Keeping Your Branch Updated

If your branch falls behind the base branch:

```bash
# Update your base branch
git checkout main
git pull origin main

# Switch back to your branch
git checkout feature/my-feature

# Merge or rebase with main
git merge main
# or
git rebase main

# Push the updated branch
git push origin feature/my-feature
```

### 4. Creating a Pull Request

Once your work is complete:

1. Push all your changes to the remote branch
2. Go to the repository on GitHub
3. Click "Compare & pull request"
4. Fill in the PR description
5. Request reviewers
6. Address any feedback

### 5. After Merge

Clean up local and remote branches after they're merged:

```bash
# Switch to main branch
git checkout main

# Delete local branch
git branch -d feature/my-feature

# Delete remote branch (if not auto-deleted)
git push origin --delete feature/my-feature
```

## Common Commands

### Listing Branches

```bash
# List local branches
git branch

# List remote branches
git branch -r

# List all branches
git branch -a

# List branches with last commit
git branch -v
```

### Switching Branches

```bash
# Switch to an existing branch
git checkout branch-name

# Create and switch to a new branch
git checkout -b new-branch-name
```

### Deleting Branches

```bash
# Delete a local branch (only if merged)
git branch -d branch-name

# Force delete a local branch
git branch -D branch-name

# Delete a remote branch
git push origin --delete branch-name
```

### Renaming Branches

```bash
# Rename current branch
git branch -m new-name

# Rename a specific branch
git branch -m old-name new-name

# Update remote after rename
git push origin -u new-name
git push origin --delete old-name
```

## Best Practices

1. **Keep branches focused** - One branch per feature or fix
2. **Use descriptive names** - Make it clear what the branch is for
3. **Update regularly** - Keep your branch up to date with the base branch
4. **Small, frequent commits** - Easier to review and revert if needed
5. **Delete merged branches** - Keep your repository clean
6. **Don't commit directly to main** - Always use feature branches
7. **Review before pushing** - Check your changes with `git diff`
8. **Write good commit messages** - Explain what and why, not just what

## Troubleshooting

### Branch Already Exists

```bash
# If a branch name is taken, use a more specific name
./create_branch.sh feature/patient-registration-v2
```

### Merge Conflicts

```bash
# When you encounter conflicts during merge
git status  # See which files have conflicts
# Edit conflicted files and resolve markers (<<<<<<, =====, >>>>>>)
git add resolved-file.dart
git commit -m "Resolve merge conflicts"
```

### Accidentally Committed to Wrong Branch

```bash
# Move commits to a new branch
git branch feature/correct-branch
git reset --hard HEAD~1  # Remove commit from current branch
git checkout feature/correct-branch
```

### Lost Commits

```bash
# View reflog to find lost commits
git reflog

# Recover a commit
git cherry-pick <commit-hash>
```

## Additional Resources

- [Git Documentation](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Atlassian Git Tutorials](https://www.atlassian.com/git/tutorials)

## Questions?

If you have questions about branching or Git workflows, please:
1. Check this guide first
2. Search existing issues/discussions
3. Ask in the team chat
4. Create an issue with the `question` label
