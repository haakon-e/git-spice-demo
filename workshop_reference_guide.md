# Git Stacking Workshop - Reference Guide

*A comprehensive guide to managing interdependent changes with git-spice*

By: Haakon Ervik

Last updated: July 9, 2025

## Overview

This guide walks you through the complete workflow of stacked development using git-spice. You'll learn to create interdependent branches, modify them safely, submit stacked Pull Requests, and handle real-world scenarios like merged PRs and merge conflicts.

The git-spice docs, which this guide is based on, are available [here](https://abhinav.github.io/git-spice/).

### What You'll Build

Throughout this guide, we'll build a climate model with three interdependent components:
1. **Spatial discretization** - Basic differential operators
2. **Model setup** - Configuration and initialization 
3. **Model run** - Main execution loop

Each component builds on the previous one, demonstrating how stacking helps manage complex, interdependent changes.

---

## Prerequisites

- **Git knowledge**: Familiarity with basic Git commands (commit, branch, rebase)
- **GitHub account**: For submitting Pull Requests
- **git-spice installed**: Follow the [installation guide](https://abhinav.github.io/git-spice/start/install/)

### Installation

Install git-spice using [Homebrew](https://brew.sh):
```bash
brew install git-spice
```

Verify the installation:
```bash
gs --version
```

---

## Part 1: Understanding the Problem

### Traditional Approach vs. Stacking

**Traditional approach:** One large branch with weeks of work
```
main ← feature/complete-climate-model (3 weeks of changes)
```

**Problems:**
- No early feedback
- Overwhelming reviews
- Blocked if one part needs major revisions
- Difficult merge conflicts

**Stacked approach:** Multiple focused branches
```
main ← spatial-discretization ← model-setup ← model-run
       (PR #1)                  (PR #2)       (PR #3)
```

**Benefits:**
- Early feedback on each component
- Smaller, focused reviews
- Parallel development possible
- Easier to isolate and fix issues

---

## Part 2: Your First Stack

### Setting Up the Repository

Create a new repository on GitHub, then clone it locally:

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo

# Create initial files
echo "# Climate Model Project" > README.md
echo ".vscode" > .gitignore
git add README.md .gitignore
git commit -m "Initial commit"

# Initialize git-spice
gs repo init
```

The `gs repo init` command sets up git-spice's internal storage for tracking branch relationships.

### Creating Your First Branch

Create the spatial discretization component:

**File: `spatial_discretization.jl`**
```julia
function horizontal_derivative!(dudx, u, dx)
    n = length(u)
    for i in 1:n
        ip = i == n ? i : i + 1
        im = i == 1 ? i : i - 1
        Δ = 1 < i < n ? 2dx : dx
        dudx[i] = (u[ip] - u[im]) / Δ
    end
    nothing
end
```

You can create and track the branch using traditional Git commands:
```bash
git switch -c feat/spatial-discretization
git add spatial_discretization.jl
git commit -m "Implement horizontal derivative"
gs branch track feat/spatial-discretization
```

### Checking Your Stack

View your current stack structure:
```bash
gs log long  # or the shortcut: gs ll
```

This shows your branches, their relationships, and associated commits.

### Creating Stacked Branches

Add the model setup component that depends on spatial discretization:

**File: `model_setup.jl`**
```julia
function model_setup(config)
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

Use git-spice's streamlined branch creation:
```bash
git add model_setup.jl
gs branch create feat/model-setup
# Enter commit message: "Add model setup"
```

The `gs branch create` command creates the branch AND commits staged changes automatically.

Add the model run component:

**File: `model_run.jl`**
```julia
function model_run(config)
    dx, u, dudx = model_setup(config)
    dt = config["dt"]
    for i in 1:config["nt"]
        horizontal_derivative!(dudx, u, dx)
        @. u += u * dudx * dt
    end
    return u
end
```

```bash
git add model_run.jl
# if you don't specify a branch name, 
#   it will generate a name for you based on the commit message
gs branch create
# Enter commit message: "Add model run"
```

### Navigating Your Stack

git-spice provides intuitive navigation commands:

```bash
gs ls           # Show current stack (alias for gs log short)
gs down         # Move to the branch below current (shorthand: gs d)
gs up           # Move to the branch above current (shorthand: gs u)
gs top          # Jump to the top of the stack (shorthand: gs U)
gs bottom       # Jump to the bottom of the stack (shorthand: gs D)
gs trunk        # Return to main branch (no shorthand)
```

Interactive branch selection:
```bash
gs branch checkout  # Shows a menu to select any branch (shorthand: gs bco)
```

### Command Shortcuts

Most git-spice commands have intuitive shortcuts. View them with `--help`:
```bash
gs branch create --help
# Shows: gs branch (b) create (c)
# Shortcut: gs bc
```

Common shortcuts:
- `gs ll` = `gs log long`
- `gs bc` = `gs branch create`
- `gs cc` = `gs commit create`
- `gs bs` = `gs branch submit`
- `gs ss` = `gs stack submit`

---

## Part 3: Modifying Mid-Stack

### The Challenge

When you modify a branch in the middle of your stack, all branches above it become out of sync. This is a core challenge in stacked development.

### Making Mid-Stack Changes

Navigate to the spatial discretization branch and add boundary conditions:

```bash
gs branch checkout feat/spatial-discretization
```

Update `spatial_discretization.jl`:
```julia
function horizontal_derivative!(dudx, u, dx; boundary_condition=:periodic)
    n = length(u)
    for i in 1:n
        if boundary_condition == :periodic
            # Periodic boundary conditions
            ip = i == n ? 1 : i + 1
            im = i == 1 ? n : i - 1
            Δ = 2dx
        elseif boundary_condition == :zero_gradient
            # Zero gradient boundary conditions
            ip = i == n ? i : i + 1
            im = i == 1 ? i : i - 1
            Δ = 1 < i < n ? 2dx : dx
        end
        dudx[i] = (u[ip] - u[im]) / Δ
    end
    nothing
end
```

### Manual Restacking (The Hard Way)

After committing your changes, dependent branches need to be rebased:
```bash
git add spatial_discretization.jl
git commit -m "Add boundary condition support to horizontal derivative"

# Manual approach - don't do this!
gs up  # Go to model-setup
git rebase feat/spatial-discretization
gs up  # Go to model-run
git rebase feat/model-setup
```

This becomes tedious with large stacks.

!!! note "Manually rebasing with `--update-refs`"
    Recently, git introduced the `git rebase <branch> --update-refs` flag, which can be used to restack the entire stack, but you have to be mindful to check out the top branch, then restacking onto the branch you edited. If you already have this workflow and like it, git-spice is still useful for navigating the stack and submitting PRs.

    When rebasing manually, and afterwards typing e.g. `gs ls`, you might see a warning like this:
    ```
    WRN could not update ref: retrying  
    error=
    | exit status 128
    | stderr:
    | fatal: update_ref failed for ref 'refs/spice/data': cannot lock ref 'refs/spice/data': is at f0000 but expected a01111
    ```
    which is just informational, and you can ignore it.

### Automated Restacking (The git-spice Way)

Instead, use git-spice's automated restacking:
```bash
# Go back to spatial-discretization
gs branch checkout feat/spatial-discretization
```
Make another improvement, e.g. add a docstring:
```julia
"""
    horizontal_derivative!(dudx, u, dx; boundary_condition=:periodic)

Computes the horizontal derivative of a 1D array `u` with spacing `dx`.
"""
function horizontal_derivative!(dudx, u, dx; boundary_condition=:periodic)
    # ...
end
```
Commit and restack automatically
```bash
gs commit create -am "Add documentation for boundary conditions"
```

The `gs commit create` command commits your changes AND automatically rebases all upstack branches. Check the result:
```bash
gs ls  # All branches now show they're up to date
```

### Key Commands for Mid-Stack Changes

- `gs commit create` (or `gs cc`) - Commit and restack upstack branches
- `gs upstack restack` (or `gs usr`) - Manually restack only upstack branches
- `gs stack restack` (or `gs sr`) - Restack the entire stack
- `gs branch restack` (or `gs br`) - Restack only the current branch

---

## Part 4: Submitting Stacked PRs

### Authentication

Before submitting PRs, authenticate with GitHub (once per device):
```bash
gs auth login
```

Select GitHub, then choose OAuth for secure authentication. Follow the device code flow to authorize git-spice.

### Submitting Individual PRs

Submit your first PR:
```bash
gs branch checkout feat/spatial-discretization
gs branch submit  # or gs bs
```

Fill out the PR information when prompted:
- **Title**: `Add spatial discretization with boundary conditions`
- **Body**: Describe the implementation and its purpose, or skip
- **Draft**: Press enter to select the default option, i.e. not a draft

git-spice will push the branch and create the PR automatically.

### Batch Submission

Submit all remaining branches at once:
```bash
gs stack submit  # or gs ss
```

This creates PRs for all unsubmitted branches in your stack. Notice how:
- Each PR automatically targets the correct base branch
- Navigation comments show the stack structure
- Dependencies are clearly visible

### Updating PRs

When you make changes, update all affected PRs easily:
```bash
# Make changes to any branch
gs commit create -a -m "Your changes"

# Update all affected PRs
gs stack submit
```

### Configuration Tips

Show clickable PR URLs in `gs log long` output:
```bash
git config --global spice.logLong.crFormat url
```

Make branch names always have your initials as a prefix
```bash
git config --global spice.branchCreate.prefix he/
```
Now, automatically generated branch names will have your initials as a prefix, e.g. `he/spatial-discretization` instead of `spatial-discretization`.

Always show all stacks in `gs log short` and `gs log long`, instead of just the current stack:
```bash
git config --global spice.log.all true
```

For other config options, see the [git-spice docs](https://abhinav.github.io/git-spice/cli/config/).

---

## Part 5: Handling Merges and Conflicts

### When PRs Get Merged

After a reviewer merges your first PR, sync your local repository:
```bash
gs repo sync
```

This command automatically:
1. Pulls latest changes to main
2. Detects merged branches and deletes them locally

to also automatically restack the current stack after syncing, you can add the `--restack` flag:
```bash
gs repo sync --restack
```
this saves you from also having to type `gs stack restack` after syncing.

If the remaining branches do not require additional changes, you can then submit/update the stack again on the remote with:
```bash
gs stack submit
```

### Creating Merge Conflicts

Conflicts occur when multiple branches modify the same lines. While this typically occurs when trying to fetch changes from the remote (e.g. someone else edited one of your branches), we can emulate this with the following scenario:

On the `feat/model-setup` branch, add input validation:
```julia
function model_setup(config)
    # Add input validation
    if !haskey(config, "dx") || config["dx"] <= 0
        error("Invalid dx: must be positive")
    end
    
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

```bash
# Note use of `git commit`: with `gs commit create` upstack branches are automatically restacked
git commit -am "Add input validation to model setup"
```

On the `feat/model-run` branch, modify the same function differently:
```julia
function model_setup(config)
    # Add comprehensive parameter checking
    required_keys = ["dx", "nx", "dt"]
    for key in required_keys
        if !haskey(config, key)
            error("Missing required parameter: $key")
        end
    end
    
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

```bash
git commit -am "Add comprehensive parameter checking"
```

If you now type `gs ls`, you will see that the `feat/model-run` branch says `(needs restack)`.

However, if we now do
```bash
gs stack restack
```

you will get a message like:
```bash
INF feat/spatial-discretization: branch does not need to be restacked.
INF feat/model-setup: branch does not need to be restacked.
ERR There was a conflict while rebasing.
ERR Resolve the conflict and run:
ERR   gs rebase continue
ERR Or abort the operation with:
ERR   gs rebase abort
FTL gs: rebase of feat/model-run interrupted by a conflict: exit status 1
FTL stderr:
FTL error: could not apply 0e6b95a... parameter checking
FTL hint: Resolve all conflicts manually, mark them as resolved with
FTL hint: "git add/rm <conflicted_files>", then run "git rebase --continue".
FTL hint: You can instead skip this commit: run "git rebase --skip".
FTL hint: To abort and get back to the state before "git rebase", run "git rebase --abort".
FTL Could not apply 0e6b95a... parameter checking
```

### Resolving Conflicts

When git-spice encounters a conflict, it pauses the rebase, just like `git rebase`. Check the conflict status with:
```bash
git status
```
you should see something like this:
```
Last commands done (2 commands done):
   pick af5ae5a Add model run
   pick 0e6b95a parameter checking
No commands remaining.
You are currently rebasing branch 'feat/model-run' on '26dc4cc'.
  (fix conflicts and then run "git rebase --continue")
  (use "git rebase --skip" to skip this patch)
  (use "git rebase --abort" to check out the original branch)
```

Open the conflicted file and look for conflict markers:
```julia
function model_setup(config)
<<<<<<< HEAD
    # Add input validation
    if !haskey(config, "dx") || config["dx"] <= 0
        error("Invalid dx: must be positive")
    end
=======
    # Add comprehensive parameter checking
    required_keys = ["dx", "nx", "dt"]
    for key in required_keys
        if !haskey(config, key)
            error("Missing required parameter: $key")
        end
    end
>>>>>>> 1a2b3c4... Add comprehensive parameter checking
    
    dx = config["dx"]
    # ... rest of function
end
```

Resolve by combining both approaches:
```julia
function model_setup(config)
    # Add comprehensive parameter checking
    required_keys = ["dx", "nx", "dt"]
    for key in required_keys
        if !haskey(config, key)
            error("Missing required parameter: $key")
        end
    end
    
    # Add specific validation for dx
    if config["dx"] <= 0
        error("Invalid dx: must be positive")
    end
    
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

Mark the conflict as resolved and continue:
```bash
git add model_setup.jl
gs rebase continue
```
By using `gs rebase continue` instead of `git rebase --continue`, the rest of the stack is automatically restacked.

### Conflict Resolution Commands

- `gs rebase continue` (or `gs rbc`) - Continue after resolving conflicts
- `gs rebase abort` (or `gs rba`) - Abort the rebase and return to previous state
- `git status` - Check which files have unresolved conflicts

---

## Best Practices

### Branch Naming
Use descriptive prefixes:
```bash
feat/spatial-discretization
feat/model-setup
feat/boundary-conditions
fix/memory-leak
refactor/config-parsing
```

### Commit Messages
Write clear, descriptive commits:
```bash
gs commit create -m "Add periodic boundary conditions

Implements configurable boundary conditions for spatial operators:
- Periodic boundaries for global models
- Zero-gradient boundaries for regional models"
```

### Stack Organization
Organize by logical dependencies:
```
main → data-collection → preprocessing → analysis → visualization → paper
```

### When to Use Stacking
**Good for stacking:**
- Interdependent features
- Large refactoring broken into steps
- Research workflows with clear phases
- When you want early feedback

**Not ideal for stacking:**
- Completely independent features
- Simple bug fixes
- When reviewers _really_ prefer large changes

---

## Troubleshooting

### Common Issues

**"gs command not found"**
- If you already have git-spice installed, try to restart your terminal. Otherwise,
- Install git-spice: `brew install git-spice`
- Verify: `gs --version`

**"No changes staged for commit"**
- Stage files first: `git add filename`
- Or use `-a` flag to automatically stage all modified or deleted files: `gs commit create -a`

**"Permission denied when pushing"**
- Ensure write access to repository
- Check authentication: `gs auth login`

**"Lost in the stack"**
- Check position: `gs ls`
- Interactive navigation: `gs branch checkout`

### Getting Help

- Command help: `gs <command> [<subcommand>] --help`, e.g. `gs branch create --help`
- Full command list: `gs --help`
- Documentation: [git-spice docs](https://abhinav.github.io/git-spice/)

---

## Summary

### Key Commands Reference

**Stack Creation:**
```bash
gs branch create <name>  # Create and track new branch
gs branch track          # Track existing branch
```

**Navigation:**
```bash
gs ls                    # Show stack
gs ll                    # Show stack and commits
gs up/down/top/bottom    # Navigate stack
gs branch checkout       # Interactive branch selection
```

**Modifications:**
```bash
gs commit create         # Commit and restack
gs stack restack         # Restack entire stack
```

**PR Submission:**
```bash
gs branch submit         # Submit current branch
gs stack submit          # Submit entire stack
gs repo sync             # Pull latest changes from the remote
gs repo sync --restack   # Sync and automatically restack after syncing
```

**Rebasing:**
```bash
gs rebase continue     # Continue after conflict resolution
gs rebase abort        # Abort problematic rebase
```

### Workflow Summary

1. **Create stack**: Break work into logical, interdependent pieces, create branches with `gs branch create` (`gs bc`)
2. **Develop iteratively**: Make changes, commit with `gs commit create` (`gs cc`)
3. **Submit for review**: Use `gs stack submit` (`gs ss`) for batch submission, or `gs branch submit` (`gs bs`) for individual branches
4. **Handle feedback**: Modify branches and update PRs automatically with `gs ss`
5. **Merge and maintain**: Use `gs repo sync` (`gs rs`) and `gs stack restack` (`gs sr`) to handle merged PRs (or combine the two with `gs rs --restack`)
