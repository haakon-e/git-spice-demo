# Workshop structure

## Slide Set 1: Opening & Problem Setup (10 mins)
- Keynote slides

## Slide Set 2: Core Concepts (8 mins)
- Keynote slides

## Live Demo 1: Tool Introduction + First Stack (25 mins)
- VSCode

### 🎯 Learning Goal
Participants will create a 3-branch stack and understand basic navigation

References:
- [git-spice homepage](https://abhinav.github.io/git-spice/)
- [installation](https://abhinav.github.io/git-spice/start/install/)

### Pre-demo Setup Checklist
- [ ] Terminal ready in clean directory
- [ ] Go to https://abhinav.github.io/git-spice/start/install/ and follow the instructions to install git-spice (I used `brew install git-spice`)
- [ ] git-spice installed and working (`gs --version`)
- [ ] GitHub account ready

### 📝 Step-by-Step Script

#### **Setup Phase (3 minutes)**

**Say**: "Let's create our research project from scratch"

**Do**:
- [ ] Go to github.com > New repository > Use suggested name with all defaults

**Say**: "Let's clone the repository to our local machine and open it in an editor of your choice. I'll use Cursor. Next, we'll create our first file and commit it."

**Type**:
```bash
git clone https://github.com/haakon-e/<repo-name>.git
cursor <repo-name>
# Create a new file called `README.md`
# Write in file: "This is my awesome project"
# Create a new file called `.gitignore`
# Write in file: ".vscode"
git add README.md
git commit -m "Initial commit"
```

**Say**: "So far, we've created a new repository, cloned it, and made our first commit, all with regular git commands. Now, let's see how git-spice can help us. Let's start by initializing git-spice in this repository."

**Type**:
```bash
gs repo init
# INF Using remote: origin
# INF Initialized repository  trunk=main
```

**SAY**: *"Now we initialize git-spice. This creates internal storage for tracking our branches. You only do this once per repository."*

**CHECKPOINT**: *"Everyone with me so far? You should see 'Initialized git-spice repository' message."*

---

#### **First Branch - New climate model (7 minutes)**

**SAY**: *"Let's create our first branch. In this scenario, we're writing a climate model and our first step is implementing some differential operators."*

**TYPE**: 
- Create a new file called `spatial_discretization.jl`
- Write in file:
```julia
function horizontal_derivative!(dudx, u, dx)
    n = length(u)
    for i in 1:n
        if i == 1
            dudx[i] = (u[i+1] - u[i]) / dx
        elseif i == n
            dudx[i] = (u[i] - u[i-1]) / dx
        else
            dudx[i] = (u[i+1] - u[i-1]) / (2 * dx)
        end
    end
    nothing
end
# TODO: Vertical derivative

```
- Add the file to the staging area in cursor

**SAY**: *"Now that we've done some work, we'll want to create a new branch with our changes. You can do this with normal git commands:"*

**TYPE**:
```bash
git switch -c feat/spatial-discretization
git commit -m "Implement horizontal derivative"
```

**SAY**: *"Now we've created a new branch and committed our changes. Let's make git-spice aware of our new branch."*

**TYPE**:
```bash
gs branch track feat/spatial-discretization
gs log long
```

**SAY**: *"The log command shows us that we're on the new branch, the commits on that branch, and that its base is the main branch."*

**CHECKPOINT**: *"Everyone with me so far? You should see the new branch in the log output."*

---

#### **Second Branch - Model setup (7 minutes)**

**SAY**: *"So far, we've implemented a spatial discretization. Now, we'll want to implement a model setup."*

**TYPE**:
```bash
# Create a new file called `model_setup.jl`
# Write in file:
function model_setup(config)
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

**SAY**: *"With stacking, it's good practice to frequently check the status of your stack. I already did this by typing `gs log long`. The cool thing about git-spice is that all commands have a short form. To see what that is, type:"*

**TYPE**:
```bash
gs log long --help
# Usage: gs log (l) long (l) [flags]
# 
# List branches and commits
# [...]
```

**SAY**: *"The short form for each word is shown in the parenthesis. Multiple words are combined without spaces For example, `gs log long` is `gs ll`."*

**TYPE**:
```bash
gs ll
```

**SAY**: *"The top-level help shows all commands and their short forms. You can simply type `gs`, or `gs --help` to see all commands. For a sub-command, we can learn about it with, e.g., `gs log --help`."*

**TYPE**:
```bash
gs
gs --help
gs log --help
```

**SAY**: *"Back to our model setup. The new code depends on the spatial discretization that we just implemented, but is a conceptually separate step. So, we'll want to create a new branch for this. We could do this with normal git commands, as before, but git-spice has a shortcut for this."*

**DO**:
- Add `model_setup.jl` to the staging area

**SAY**: *"We've staged our changes. Now watch this magic..."*

**TYPE**:
```bash
gs branch create feat/model-setup
# write commit message: "Add model setup"
```

**SAY**: *"Notice what happened: git-spice created the branch AND committed our staged changes automatically. This is different from regular git where you'd need separate commands."*

**SAY**: "Let's add another file called `model_run.jl` and write some code to run the model."

**TYPE**:
```julia
# Create a new file called `model_run.jl`
# Write in file:
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

**SAY**: *"Okay, now we have another set of changes that we'll want to put into its own PR. Let's see if there's any shortcuts we can learn in the process."*

**TYPE**:
```bash
gs branch create --help
```

**SAY**: *"From the help, we can see that `gs branch create` has the shortcut `gs bc`. As with normal `git`, we can add the flag `-a` to automatically stage any modified files."*

**TYPE**:
```bash
gs bc feat/model-run -a -m "Add model run"
```

**SAY**: *"Oh, Right. For newly created files, the `-a` doesn't include them. So, let's modify the commit that we just created. We can do this with the `gs commit amend` command. As with git, if we don't want to edit the commit message, we can use the `--no-edit` flag."*

**TYPE**:
```bash
gs commit amend --no-edit
```

**SAY**: *"Now we have three branches, one for the spatial discretization, one for the model setup, and one for the model run. Let's see how we can navigate between them."*

**TYPE**:
```bash
gs ls  # Say: remember that `gs ls` is the short form for `gs log long`
gs down
gs ls  # check that we're on `feat/model-setup`
gs down
gs ls  # check that we're on `feat/spatial-discretization`
gs top
gs ls  # check that we're on `feat/model-run`
gs bottom
gs ls  # check that we're on `feat/spatial-discretization`
gs trunk
gs ls  # check that we're on `main`
```

**SAY**: *"As with the other commands, they have convenient short forms. For example, `gs d` for `gs down` and `gs t` for `gs top`. For `top` and `bottom`, we capitalize `up` and `down`, that is, `gs U` and `gs D`."*

### 🔄 Transition to Next Section
**SAY**: *"Great! We've built our first stack. But here's where it gets really powerful - what happens when we need to modify a branch in the middle of our stack? That's what we'll tackle next..."*


## Live Demo 2: Modifying Mid-Stack (15 minutes)

### 🎯 Learning Goal
Participants will modify a branch in the middle of their stack and understand how to restack dependent branches

### 📝 Step-by-Step Script

#### **The Scenario (2 minutes)**

**SAY**: *"Now we have our stack: main → feat/spatial-discretization → feat/model-setup → feat/model-run. But here's a common scenario you might encounter: while working on the model run, you realize there's an issue with your spatial discretization. Maybe you need to add boundary conditions, or you want to implement a more accurate finite difference scheme."*

**TYPE**:
```bash
gs ls  # Show current stack
```

**SAY**: *"Let's say we're currently working on the model-run branch, but we realize our horizontal derivative function is too simple. We need to add proper boundary conditions. This is exactly the kind of interdependent change that makes stacking so powerful."*

---

#### **Navigate to Mid-Stack Branch (2 minutes)**

**SAY**: *"First, let's navigate to the spatial discretization branch where we need to make our changes. Since it's the bottom branch, we could simply do `gs bottom`, but let me show you another way to do it."*

**TYPE**:
```bash
gs branch checkout
# navigate with arrows to the `feat/spatial-discretization` branch
```

**SAY**: *"We could also use relative navigation. From model-run, we could go `gs down` twice, or `gs bottom`. But I wanted to show the checkout command, which gives you an interactive menu if you don't specify a branch name."*

**TYPE**:
```bash
gs ls  # Confirm we're on feat/spatial-discretization
```

---

#### **Make the Improvement (4 minutes)**

**SAY**: *"Now let's improve our spatial discretization by adding proper boundary condition handling and making it more robust."*

**DO**: 
- Open `spatial_discretization.jl`
- Modify the function to:

```julia
function horizontal_derivative!(dudx, u, dx; boundary_condition=:periodic)
    n = length(u)
    for i in 1:n
        if boundary_condition == :periodic
            # Periodic boundary conditions
            im1 = i == 1 ? n : i - 1
            ip1 = i == n ? 1 : i + 1
            dudx[i] = (u[ip1] - u[im1]) / (2 * dx)
        elseif boundary_condition == :zero_gradient
            # Zero gradient boundary conditions
            if i == 1
                dudx[i] = (u[i+1] - u[i]) / dx
            elseif i == n
                dudx[i] = (u[i] - u[i-1]) / dx
            else
                dudx[i] = (u[i+1] - u[i-1]) / (2 * dx)
            end
        end
    end
    nothing
end


# TODO: Vertical derivative with same boundary condition support
```

**SAY**: *"Now we have a much more robust spatial discretization with proper boundary conditions. Let's commit this improvement."*

---

#### **Commit and See the Problem (3 minutes)**

- add `spatial_discretization.jl` to the staging area
**TYPE**:
```bash
git commit -m "Add boundary condition support to horizontal derivative"
```

**SAY**: *"Now let's see what happened to our stack:"*

**TYPE**:
```bash
gs ls
```

**SAY**: *"Notice something important here! The branches above our current one (feat/model-setup and feat/model-run) are now based on the OLD version of feat/spatial-discretization. They don't know about our boundary condition improvements. This is shown in the git-spice log - you might see indicators that they're out of sync."*

**SAY**: *"Let's check what this means by looking at the model-setup branch:"*

**TYPE**:
```bash
gs up  # Go to feat/model-setup
cat spatial_discretization.jl
```

**SAY**: *"See? The model-setup branch still has the old version without boundary conditions. This is the core challenge of stacking - when you modify a base branch, all dependent branches need to be updated."*

---

#### **The Manual Approach (2 minutes)**

**SAY**: *"We could fix this manually with git commands. Let's see what that would look like:"*

**TYPE**:
```bash
# Stay on feat/model-setup branch
git rebase feat/spatial-discretization
```

**SAY**: *"This rebases model-setup on top of the updated spatial-discretization. Now let's check:"*

**TYPE**:
```bash
cat spatial_discretization.jl  # Should now show the updated version
```

**SAY**: *"Good! But we'd still need to do this for model-run too:"*

**TYPE**:
```bash
gs up  # Go to feat/model-run
git rebase feat/model-setup  # Rebase on the updated feat/model-setup
```

**SAY**: *"This works, but imagine doing this for a stack of 5 or 10 branches! There's a better way..."*

---

#### **The git-spice Way (2 minutes)**

**SAY**: *"Let's go back and see how git-spice makes this easier. First, let me undo what we just did to show you the automated approach:"*

**TYPE**:
```bash
# Go back to feat/spatial-discretization
gs bco feat/spatial-discretization

# Let's make another small improvement to demonstrate the automated flow
```

**DO**:
- Add a comment to the file:
```julia
# Enhanced spatial discretization with configurable boundary conditions
function horizontal_derivative!(dudx, u, dx; boundary_condition=:periodic)
    # ... rest of function stays the same
```

**TYPE**:
```bash
# Instead of git add + git commit, let's use git-spice:
gs commit create -a -m "Add documentation for boundary conditions"
```

**SAY**: *"Watch what happened!"*

**TYPE**:
```bash
gs ls
```

**SAY**: *"git-spice automatically rebased all the upstack branches! The `gs commit create` command (or `gs cc`) commits your changes AND restacks everything above it. No manual rebasing needed."*

**CHECKPOINT**: *"Everyone see how feat/model-setup and feat/model-run now show they're based on the latest feat/spatial-discretization? This is the power of automated restacking."*

---

### 🚨 Common Issues & Responses

**"I got a merge conflict during rebase"**
- *"That's normal! git-spice will pause and let you resolve it. Fix the conflicts, then run `gs rebase continue` (or `gs rbc`)."*

**"I'm confused about which branch I'm on"**
- *"Run `gs ls` anytime to see your current position and the stack structure. The current branch is marked clearly."*

**"What if I want to restack everything in the stack?"**
- *"Great question! Use `gs stack restack` (or `gs sr`) to restack the entire stack, not just upstack branches."*

### 🔄 Transition to Next Section
**SAY**: *"Excellent! Now you understand how to safely modify branches in the middle of your stack. But there's one more crucial piece - how do we get these changes reviewed and merged? That's where submitting Pull Requests becomes really interesting with stacked branches. Let's see how git-spice handles that..."*

---

## Live Demo 3: Submitting Stacked PRs (20 minutes)

### 🎯 Learning Goal
Participants will authenticate with GitHub and submit a stack of interdependent Pull Requests

### 📝 Step-by-Step Script

#### **Authentication Setup (5 minutes)**

**SAY**: *"Now comes the really exciting part - getting your stacked changes reviewed! But first, we need to authenticate git-spice with GitHub so it can create Pull Requests for us."*

**TYPE**:
```bash
gs auth login
```

**SAY**: *"git-spice will ask us which service we want to authenticate with. Since we're using GitHub, let's select that."*

**EXPECTED OUTPUT**:
```
Select a service to authenticate with:
  > GitHub
    GitLab
```

**DO**: Select GitHub

**SAY**: *"Now git-spice gives us several authentication options. We'll use OAuth, which is secure and convenient."*

**EXPECTED OUTPUT**:
```
Select an authentication method:
  > OAuth
    OAuth: Public repositories only
    GitHub App
    Personal Access Token
    GitHub CLI
```

**DO**: Select OAuth

**SAY**: *"git-spice will now give us a device code and a URL. We need to visit the URL in our browser and enter the code."*

**EXPECTED OUTPUT**:
```
1. Visit https://github.com/login/device
2. Enter code: ABCD-1234
The code expires in a few minutes.
It will take a few seconds to verify after you enter it.
```

**DO**: 
- Open browser to https://github.com/login/device
- Enter the displayed code
- Authorize git-spice

**SAY**: *"While we're waiting for the authorization, this OAuth flow is nice because it's secure - git-spice gets limited permissions and only for this device. You can revoke access anytime from your GitHub settings."*

**EXPECTED**: Success message like:
```
INF github: successfully logged in
```

**CHECKPOINT**: *"Everyone successfully authenticated? You should see a success message. If you had issues, we can troubleshoot after the demo."*

---

#### **Submitting the First PR (4 minutes)**

**SAY**: *"Now let's submit our first Pull Request. We have three branches in our stack, so let's start with the bottom one - feat/spatial-discretization."*

**TYPE**:
```bash
gs bco feat/spatial-discretization
gs ls  # Show we're on the right branch
```


**SAY**: *"To submit a PR for the current branch, we use `gs branch submit`, or the short form `gs bs`:"*

**TYPE**:
```bash
gs bs
```

**SAY**: *"git-spice will now prompt us for PR information. Let's fill this out together:"*

**EXPECTED PROMPTS**:
```
Title: Implement horizontal derivative
```

**DO**: Enter a good title like: `Add spatial discretization with boundary conditions`

**EXPECTED**:
```
Body:
```

**DO**: Enter description like:
```
Implements horizontal derivative function with configurable boundary conditions:
- Periodic boundary conditions for global models
- Zero gradient boundary conditions for regional models

This provides the foundation for our climate model spatial operators.
```

**EXPECTED**:
```
Draft: [y/N]
```

**DO**: Press Enter (No - ready for review)

**SAY**: *"And git-spice creates our PR! Notice it automatically pushed the branch and created the Pull Request."*

**EXPECTED OUTPUT**:
```
INF Created #1: https://github.com/username/repo/pull/1
```

**SAY**: *"Let's open that URL and see our PR."*

**DO**: Open the PR URL in browser

**SAY**: *"See how it's a normal GitHub PR, but it's based on main. This is our foundation branch. Now let's stack the next PR on top of it."*

---

#### **The Power of Stack Submission (8 minutes)**

**SAY**: *"Now for the magic - instead of submitting each branch individually, let's see git-spice's real superpower: stack submission. We can create all remaining PRs at once."*

**TYPE**:
```bash
gs stack submit --help
```

**SAY**: *"The `gs stack submit` command (or `gs ss`) can submit all branches in the stack at once."*

**TYPE**:
```bash
gs ss
```

**EXPECTED OUTPUT**:
```
INF PR #1 is up-to-date: https://github.com/username/repo/pull/1
INF Created #2: https://github.com/username/repo/pull/2
INF Created #3: https://github.com/username/repo/pull/3
```

**SAY**: *"Amazing! git-spice created PRs #2 and #3, and automatically figured out their dependencies. Let's look at these new PRs."*

**DO**: Open PR #2 in browser

**SAY**: *"Look at the base branch! Instead of being based on 'main', this PR is based on our 'spatial-discretization' branch. git-spice automatically figured out the dependency relationship."*

**SAY**: *"Also notice the navigation comment at the top - git-spice added a helpful diagram showing where this PR fits in the stack!"*

**DO**: Open PR #3 in browser

**SAY**: *"And PR #3 is based on the 'model-setup' branch. Each PR builds on the previous one, creating a chain of dependencies."*

**TYPE**:
```bash
gs ls
```

**SAY**: *"Perfect! Each branch now shows its associated PR number in the log output. We created three interdependent PRs with just two commands!"*

**SAY**: *"One more thing. I usually like to be able to easily click to the PR in the browser from the log output. We cam edit how the log output looks by adding a config option to our git config."*

**TYPE**:
```bash
git config --global -add spice.logLong.crFormat url"
# if we want this for for short and long log, do `spice.log.crFormat`
git config --global --list
```


---

#### **Updating PRs After Changes (3 minutes)**

**SAY**: *"Now let's see what happens when we make changes and need to update our PRs. Remember our mid-stack modification from earlier? Let's make another improvement."*

**TYPE**:
```bash
gs bco feat/spatial-discretization
```

**DO**: Add another function to `spatial_discretization.jl`:
```julia
function vertical_derivative!(dvdz, v, dz; boundary_condition=:periodic)
    n = length(v)
    for i in 1:n
        if boundary_condition == :periodic
            im1 = i == 1 ? n : i - 1
            ip1 = i == n ? 1 : i + 1
            dvdz[i] = (v[ip1] - v[im1]) / (2 * dz)
        elseif boundary_condition == :zero_gradient
            if i == 1
                dvdz[i] = (v[i+1] - v[i]) / dz
            elseif i == n
                dvdz[i] = (v[i] - v[i-1]) / dz
            else
                dvdz[i] = (v[i+1] - v[i-1]) / (2 * dz)
            end
        end
    end
    nothing
end
```

**TYPE**:
```bash
gs cc -a -m "Add vertical derivative function"
```

**SAY**: *"Now let's update all affected PRs:"*

**TYPE**:
```bash
gs stack submit
```

**EXPECTED OUTPUT**:
```
INF Updated #1: https://github.com/username/repo/pull/1
INF Updated #2: https://github.com/username/repo/pull/2
INF Updated #3: https://github.com/username/repo/pull/3
```

**SAY**: *"git-spice automatically pushed the updated branches and updated all three PRs! The dependent PRs now include our new vertical derivative function."*

**DO**: Refresh PR #1 in browser

**SAY**: *"See the new commits? And notice that git-spice updated the navigation comments in all the PRs to reflect the current state of the stack."*

---

### 🚨 Common Issues & Responses

**"Authentication failed"**
- *"Make sure you entered the device code correctly and authorized git-spice in your browser. You can try `gs auth login` again."*

**"Permission denied when pushing"**
- *"Make sure you have write access to the repository. For forks, you might need to push to your fork first."*

**"PR creation failed"**
- *"Check your network connection and GitHub status. You can retry with `gs bs` - git-spice is idempotent."*

**"I don't see the stack navigation comment"**
- *"It might take a moment to appear, or check your repository settings. Some organizations disable certain comment types."*

### 🔄 Transition to Next Section
**SAY**: *"Fantastic! Now you've seen the complete workflow - creating stacked branches, modifying them, and submitting stacked PRs efficiently. You can submit PRs individually with `gs bs` when you need fine control, or use `gs ss --fill` for rapid batch submission. Your reviewers can now review each piece independently, and you can iterate on individual components without blocking the whole stack. This is the power of stacked development for research workflows!"*

## Live Demo 4: Merging & Handling Conflicts (18 minutes)

### 🎯 Learning Goal
Participants will understand how to handle merged PRs and resolve merge conflicts during restacking

### 📝 Step-by-Step Script

#### **Part 1: Merging a PR and Syncing (8 minutes)**

**SAY**: *"Now let's see what happens in the real world when your PRs start getting reviewed and merged. This is where the rubber meets the road with stacked development."*

**TYPE**:
```bash
gs ls  # Show current stack with all PRs
```

**SAY**: *"We have our three PRs: feat/spatial-discretization (#1), feat/model-setup (#2), and feat/model-run (#3). Let's say our reviewer looked at PR #1 and approved it. Time to merge!"*

---

##### **Merging the PR (3 minutes)**

**DO**: Switch to browser, go to PR #1

**SAY**: *"In GitHub, we can merge this PR just like any other."*

**DO**: 
- Click "Merge pull request"
- Keep the default commit message or edit as needed
- Confirm the merge
- Delete the branch when prompted (optional)

**SAY**: *"Great! PR #1 is now merged into main. But notice what happened to PRs #2 and #3 - they still show they're based on the old feat/spatial-discretization branch that no longer exists. This is the classic stacked PR challenge."*

**DO**: Show PR #2 in browser - point out it still references the old branch

---

##### **Local Sync with git-spice (5 minutes)**

**SAY**: *"Now comes the magic. Let's sync our local repository with what happened on GitHub."*

**TYPE**:
```bash
gs repo sync
```

**EXPECTED OUTPUT**:
```
INF main: pulled 1 new commit(s)
INF feat/spatial-discretization: #1 was merged
INF feat/spatial-discretization: deleted (was a1b2c3d)
INF feat/model-setup: restacked on main
INF feat/model-run: restacked on feat/model-setup
```

**SAY**: *"Look at what git-spice just did automatically!"*

**TYPE**:
```bash
gs ls
```

**SAY**: *"Amazing! git-spice:"*
- *"1. Pulled the latest changes to main"*
- *"2. Detected that feat/spatial-discretization was merged and deleted the local branch"*
- *"3. Automatically rebased feat/model-setup onto main"*
- *"4. Rebased model-run onto the new model-setup"*
- *"5. Updated our stack structure"*

**DO**: Check PRs #2 and #3 in browser

**SAY**: *"And if we check our remaining PRs, git-spice has automatically updated them to be based on main instead of the old branch. The stack is now properly maintained!"*


---

#### **Part 2: Handling Merge Conflicts (10 minutes)**

**SAY**: *"Now let's tackle the other reality of development - merge conflicts. These happen when git can't automatically merge changes, and they're especially common in stacked development."*

---

##### **Setting Up a Conflict Scenario (3 minutes)**

**SAY**: *"Let's create a realistic conflict scenario. We'll have both branches modify the same file in the same location - this commonly happens when multiple people work on configuration or when you're iterating on the same function."*

**TYPE**:
```bash
gs bco model-setup
```

**DO**: Modify `model_setup.jl` to add error checking at the top:
```julia
function model_setup(config)
    # Add input validation
    if !haskey(config, "dx") || config["dx"] <= 0
        error("Invalid dx: must be positive")
    end
    
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

**TYPE**:
```bash
gs cc -a -m "Add input validation to model setup"
```

**SAY**: *"Now let's go to the model-run branch and modify the SAME function, but in a different way:"*

**TYPE**:
```bash
gs up  # Go to model-run
```

**DO**: Go back and modify the SAME `model_setup.jl` file, but add different validation:
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
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

**SAY**: *"Now both branches have modified the same lines in model_setup.jl - one adds simple dx validation, the other adds comprehensive parameter checking. This will definitely create a conflict when git-spice tries to restack!"*

---

##### **Triggering the Conflict (2 minutes)**

**TYPE**:
```bash
gs cc -a -m "Add timing information to model run"
```

**SAY**: *"git-spice will try to restack model-run on top of the modified model-setup, but both branches modified the same lines in model_setup.jl with different validation approaches. Let's see what happens:"*

**EXPECTED OUTPUT**:
```
CONFLICT (content): Merge conflict in model_setup.jl
error: could not apply 1a2b3c4... Add comprehensive parameter checking to model setup
hint: Resolve all conflicts manually, mark them as resolved with
hint: "git add/rm <conflicted_files>", then run "gs rebase continue".
```

**SAY**: *"Perfect! This is exactly what we expect. git-spice detected the conflict in model_setup.jl and paused the rebase operation for us to resolve it."*

---

##### **Resolving the Conflict (5 minutes)**

**SAY**: *"Now we need to resolve this conflict. Let's see what git is telling us:"*

**TYPE**:
```bash
git status
```

**EXPECTED OUTPUT**:
```
interactive rebase in progress; onto a1b2c3d
Last command done (1 command done):
   pick 4e5f6a7 Add comprehensive parameter checking to model setup
No commands remaining.
You are currently rebasing branch 'model-run' on 'a1b2c3d'.
  (fix conflicts and run "git rebase --continue")

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   model_setup.jl
```

**DO**: Open `model_setup.jl` in editor

**SAY**: *"Here's the conflict. Git has marked the conflicting sections where both branches modified the same lines:"*

**SHOW**: The conflict markers in the file:
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
>>>>>>> 1a2b3c4... Add comprehensive parameter checking to model setup
    
    dx = config["dx"]
    u = zeros(length(config["nx"]))
    dudx = similar(u)
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

**SAY**: *"We need to manually fix this by deciding which validation approach to use, or combining both. The HEAD version has simple dx validation, and our version has comprehensive parameter checking. Let's combine the best of both:"*

**DO**: Fix the conflict by editing to:
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
    # Initialize derivative field
    horizontal_derivative!(dudx, u, dx)
    return (; dx, u, dudx)
end
```

**SAY**: *"Now we've resolved the conflict by combining both validation approaches - we check for all required parameters AND validate that dx is positive. Let's mark it as resolved and continue:"*

**TYPE**:
```bash
git add model_setup.jl
gs rebase continue
```

**EXPECTED OUTPUT**:
```
INF model-run: restacked on model-setup
```

**SAY**: *"Excellent! git-spice has completed the rebase. Our model-run branch now properly incorporates the enhanced validation from model-setup, plus our additional parameter checking improvements."*

**TYPE**:
```bash
gs ls
```

**SAY**: *"Perfect! The stack is now consistent again, and our conflict is resolved."*

---

### 🚨 Common Issues & Responses

**"I'm confused about which version to keep"**
- *"Look at the conflict markers carefully. `<<<<<<< HEAD` is the version from the target branch, `>>>>>>> commit` is your version. Usually you want to combine both changes."*

**"git rebase continue failed"**
- *"Make sure you've added all resolved files with `git add`. You can check `git status` to see what's still unresolved."*

**"I want to abort the rebase"**
- *"No problem! Use `gs rebase abort` (or `gs rba`) to go back to where you started."*

**"The conflict is too complex"**
- *"For complex conflicts, you might want to use a merge tool like `git mergetool` or resolve it in your editor with better conflict resolution support."*

### 🎯 Key Points to Emphasize

1. **gs repo sync is powerful**: Automatically handles merged PRs and restacks remaining branches
2. **Conflicts are normal**: Especially common in stacked development, don't panic
3. **git-spice helps with conflicts**: Pauses at the right moment and provides clear next steps
4. **Resolution workflow**: Fix conflicts → `git add` → `gs rebase continue`
5. **You can always abort**: `gs rebase abort` if things get too complex
6. **Stacked PRs get updated**: Changes automatically propagate to dependent PRs

### ⏰ Timing Checkpoints
- **3 min**: PR merged in GitHub
- **8 min**: Local sync completed and explained
- **11 min**: Conflict scenario set up
- **13 min**: Conflict triggered and explained
- **18 min**: Conflict resolved and stack restored

### 🔄 Transition to Next Section
**SAY**: *"Fantastic! Now you've seen the complete lifecycle - from creating stacked branches, to submitting PRs, to handling merges and conflicts. These are the real-world skills you need for effective stacked development. You're equipped to handle almost any scenario that comes up in your research workflows!"*

**SLIDE CUE**: Switch to "Best Practices & Patterns" slides or Q&A
