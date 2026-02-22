# BNT MemMan Toolkit – Git Usage and Workflow

This document defines the recommended Git and GitHub workflow for the **BNT MemMan Toolkit – Windows RAM & Standby List Optimizer**, focused on a single primary maintainer using VS Code with Git and AI extensions.

---

## 1. Core Git actions in VS Code

The VS Code Git menu surfaces common actions such as **Pull, Push, Clone, Checkout to…, Fetch, Commit, Branch, Remote, Tags**.  
This section explains what each does and how you should use it for this toolkit.

### 1.1 Action meanings and best practices


| Action | What it means | When you should use it | Command example | Best practice for BNT MemMan |
|--------|----------------|------------------------|-----------------|------------------------------|
| **Pull** | Get the latest commits from GitHub and merge them into your current local branch. | When you changed something on another machine or when collaborators updated the branch on GitHub. | `git pull` | Always pull before starting new work on an existing branch. Resolve conflicts immediately so you do not build on outdated code. |
| **Push** | Send your local commits to the remote branch on GitHub. | After staging and committing your changes locally and when you want the GitHub repo to reflect them. | `git push` | Commit small, coherent units of work and push frequently. For new feature branches, first push with `git push -u origin feature/...` so VS Code tracks the branch. |
| **Clone** | Create a local working copy of an existing remote repository. | The first time you bring `bnt-memman-toolkit` onto a new machine. | `git clone https://github.com/bnt-devsecops/bnt-memman-toolkit.git` | Prefer cloning over manual copying so remotes and history are configured correctly from the start. Then open the cloned folder in VS Code. |
| **Checkout to…** | Switch to another branch or create a new branch. | Before starting a new feature or experiment; create a `feature/...` branch and work there instead of on `main`. | `git checkout -b feature/v1.1-gui` | Keep `main` stable and releasable. Use descriptive feature branch names like `feature/gui-wrapper`, `feature/logging-improvements`, etc. |
| **Fetch** | Download remote commits and refs without merging them into your current branch. | When you want to see what changed on GitHub without altering your working tree. | `git fetch` | Fetch before large merges or rebases. In VS Code, fetch, review changes, then decide whether to pull. |
| **Commit** | Record a snapshot of staged changes with a message in the local repository. | After finishing a logical unit of work (for example, “Add BNT-Get-MemoryReport script”). | `git add .` then `git commit -m "Add BNT-Get-MemoryReport.ps1 diagnostic script"` | Write clear messages that describe intent. Commit often enough that rollbacks and reviews remain easy. |
| **Branch** | Create, list, switch, or delete branches. | To structure work: `main` for releases, `feature/...` for new work, and optionally `release/...` for staged versions. | `git branch` | Keep branches short-lived. Merge or delete them when work is complete and tested. Avoid long-running branches that drift far from `main`. |
| **Remote** | Show and manage remote repositories linked to your local repo. | To verify your GitHub URL or reconfigure the remote after a rename. | `git remote -v` | Maintain a single primary remote named `origin` pointing to `https://github.com/bnt-devsecops/bnt-memman-toolkit.git`. |
| **Tags** | Lightweight markers for specific commits, commonly used for releases. | When you cut a release such as `v1.0.0` and want to mark that commit. | `git tag v1.0.0` then `git push origin v1.0.0` | Use tags only for release points so version history stays clean and meaningful. |


---

## 1.2 BNT MemMan Toolkit – VS Code Git Menus Explained

This reference maps the VS Code Source Control context menus to Git concepts and shows how you should use them in real projects (dev, staging, prod).

Each subsection corresponds to what you see when you click the **three dots (…)** next to your repo in VS Code.

---

#### 1.1.1 Commit menu

| Item (VS Code) | What it does in Git terms | When to use it | Example flow | Best practice |
|----------------|---------------------------|----------------|--------------|---------------|
| **Commit** | Creates a commit from all staged changes with the message in the box. | After you have reviewed the diff and are confident the staged changes form one logical unit. | Stage files, type `Add MemMan Git guide`, click Commit. | Keep commits small and focused. Use present tense and describe intent, for example `Add RAM diagnostics report script`. |
| **Commit Staged** | Same as Commit, but only uses files already staged in the “Staged Changes” section. | When you want to commit just a subset of your edits and leave others for later. | Stage only `docs/git-usage-and-workflow.md`, run Commit Staged. | Use when you have mixed work in your working tree but want clean commit boundaries. |
| **Commit All** | Stages **all** modified files and commits them in one action. | When every current change belongs to the same logical update and you have reviewed them. | Edit several docs, choose Commit All with message `Polish docs for v1.0.0`. | Use carefully; it is easy to commit temporary or debug edits by accident. |
| **Undo Last Commit** | Creates a new HEAD state by moving back one commit, keeping the changes in your working tree. Local only until pushed. | When you just committed locally and realize the message or content needs adjustment, and you have not pushed yet. | Immediately after a mistaken commit, choose Undo Last Commit, then re-commit with improved message. | Safe before pushing; avoid after push because history on GitHub will diverge. |
| **Commit (Amend)** | Rewrites the last commit by adding current staged changes and/or changing the message. | To fix small mistakes in the last commit before pushing to GitHub. | Stage an extra file, choose Commit (Amend) to roll it into the previous commit. | Only amend commits you have not pushed. Once on GitHub, use new commits or `git revert` instead. |
| **Commit Signed Off / Commit Staged (Signed Off)** | Adds a “Signed-off-by” line to the commit message (Developer Certificate of Origin style). | If a project or customer requires sign-off for compliance or legal traceability. | Use Commit (Signed Off) with message and let VS Code append sign-off. | For your own repos, use when you want DCO style tracking, particularly for shared or customer-visible projects. |

---

#### 1.1.2 Changes menu

| Item (VS Code) | What it does | When to use it | Example | Best practice |
|----------------|--------------|----------------|---------|---------------|
| **Stage All Changes** | Moves all modified files into the “Staged Changes” area. | Before a commit when all current edits belong together. | After finishing work on v1.0.0 docs, use Stage All Changes. | Review the diff pane first to avoid staging unintended files. |
| **Unstage All Changes** | Moves all files from “Staged Changes” back to “Changes”. | If you staged too much and want to rethink what to commit. | You realize some staged edits are experimental, so you unstage all and restage selectively. | Use this instead of discarding if you are unsure what should be committed. |
| **Discard All Changes** | Reverts all **uncommitted** changes to the last committed state. | When you are certain you want to throw away all current modifications in the working tree. | You tested a risky refactor that you do not want to keep; use Discard All Changes. | Extremely destructive. Only use when you are 100 percent sure you do not need the local edits. |
| **Copy Changes (Patch)** | Copies a textual patch of current changes to the clipboard. | When you want to share a small diff in a chat or note without pushing a branch. | Copy patch for a bugfix and paste it into an issue comment. | Useful when assisting customers or showing suggested changes without editing their repo. |
| **Share as Cloud Patch…** | Publishes a patch via a cloud service supported by your extensions (for example GitLens). | To share changes as a link rather than as a branch or full PR. | Send a patch link to a customer for review. | Good for quick collaboration; not required for your own solo workflow. |

---

#### 1.1.3 Pull, Push menu

| Item (VS Code) | Git concept | When to use it | Example | Best practice |
|----------------|------------|----------------|---------|--------------|
| **Sync** | Runs pull then push for the current branch. | When you want to both fetch changes and upload your own in one step. | After finishing a small feature and expecting no conflicts, run Sync. | Safe for solo work. In team settings, consider pulling and resolving conflicts before pushing. |
| **Pull** | `git pull` (fetch + merge) for current branch. | Before starting work, especially on shared branches. | Start day: Pull on `main` before creating a feature branch. | Do this regularly on `main` and active feature branches to avoid large, painful merges. |
| **Pull (Rebase)** | `git pull --rebase` (fetch + replay local commits on top of remote). | When you want a linear history without merge commits. | With two local commits and new remote commits, use Pull (Rebase) to reapply your work on top. | Use only if you are comfortable resolving rebase conflicts. Avoid rebasing commits that are already pushed and used by others. |
| **Pull from…** | Pull from a specific remote or branch. | When multiple remotes exist (for example `origin` and a customer mirror) or you want to pull a non-default branch. | Pull from a customer fork to test their changes locally. | For BNT MemMan Toolkit, you usually pull from `origin/main` or `origin/feature/...`. |
| **Push** | `git push` for current branch to its tracked remote. | After one or more commits on the current branch. | Commit scripts, then Push to update GitHub. | Push frequently in feature branches to avoid risk of local loss and to prepare for PRs. |
| **Push to…** | Push to a specific remote or branch name. | First push of a new local branch, or pushing to a differently named remote branch. | Push `feature/gui-experiment` to `origin/feature/gui-experiment`. | For new branches, use this once and then stick with normal Push. |
| **Fetch** | `git fetch` for current remote. | To see remote changes without merging. | Fetch before deciding to pull `main` and review the log. | Good habit when you know others are pushing; for solo projects, less critical. |
| **Fetch (Prune)** | `git fetch --prune` removes references to remote branches that no longer exist. | When many old remote branches were deleted and your local branch list is cluttered. | After a cleanup of old feature branches on GitHub, run Fetch (Prune). | Helps keep your GitHub branch list clean and reduces confusion in VS Code. |
| **Fetch From All Remotes** | Fetch from every configured remote. | When you have multiple remotes (for example origin plus customer forks) and want an up-to-date view everywhere. | In a consulting repo with both upstream and customer remotes, fetch from all. | For BNT MemMan Toolkit, you typically have only `origin`, so normal Fetch is enough. |

---

#### 1.1.4 Branch menu

| Item (VS Code) | Git concept | When to use it | Example | Best practice |
|----------------|------------|----------------|---------|--------------|
| **Merge…** | Merge another branch into the current branch. | To bring finished work from a feature branch into a local `main` before pushing, or to keep a feature branch up to date with `main`. | Checked out `feature/gui`, choose Merge… and select `main` to bring latest changes in. | Prefer GitHub PRs for merging into `main`. Use local merges mainly to update feature branches. |
| **Rebase Branch…** | Rebase the current branch onto another branch. | To replay feature-branch commits on top of a newer `main` while keeping history linear. | In `feature/gui`, choose Rebase Branch… and select `main`. | Powerful but can be complex. Do not rebase branches others are already using. |
| **Create Branch…** | Create a new branch from the current HEAD. | Before starting new work so you do not develop directly on `main`. | From `main`, Create Branch… → `feature/v1.1-gui`. | Always branch for non-trivial changes; keep `main` clean. |
| **Create Branch From…** | Create a branch from a specific commit or branch, not necessarily the current one. | For backporting or hotfixes from older releases. | Create a `hotfix/v1.0.1` branch from tag `v1.0.0`. | Useful when supporting production while main is far ahead. |
| **Rename Branch…** | Rename the current branch. | When you want to improve branch naming clarity. | Rename `feature/gui` to `feature/v1.1-gui`. | After renaming, run `git push origin -u new-name` and optionally delete the old remote name. |
| **Delete Branch…** | Delete a local branch. | After a feature branch is merged and no longer needed locally. | Delete `feature/v1.1-gui` after merging. | Only delete branches you are certain are merged or obsolete. |
| **Delete Remote Branch…** | Delete a branch on the remote (GitHub). | After the feature branch has been merged or is no longer required. | Delete remote `feature/v1.1-gui`. | Keeps GitHub branch list clean and easier for customers to navigate. |
| **Publish Branch…** | Push a new local branch to the remote and set upstream tracking. | First time you want a branch to appear on GitHub. | On `feature/v1.1-gui`, select Publish Branch…. | Equivalent to `git push -u origin feature/v1.1-gui`; use it once per new branch. |

---

#### 1.1.5 Remote menu

| Item (VS Code) | What it does | When to use it | Example | Best practice |
|----------------|--------------|----------------|---------|---------------|
| **Add Remote…** | Configure a new remote URL for the repo (for example `origin`, `upstream`, `customer`). | When wiring your local repo to GitHub the first time, or adding a second remote. | Add `origin` → `https://github.com/bnt-devsecops/bnt-memman-toolkit.git`. | For this toolkit, you usually only need `origin`. For customer mirrors, name them clearly (`customer-xyz`). |
| **Remove Remote…** | Remove an existing remote. | When a remote is no longer valid (for example repo moved or customer contract ended). | Remove an old `customer-test` remote. | Do not remove `origin` unless you intentionally disconnect from GitHub. |

---

#### 1.1.6 Stash menu

| Item (VS Code) | Git concept | When to use it | Example | Best practice |
|----------------|------------|----------------|---------|--------------|
| **Stash** | `git stash` – save current tracked changes on a stack and revert working tree to clean state. | When you need to temporarily shelve work-in-progress to switch branches or pull, without committing. | You are mid-change but must quickly check out `main` to fix a hotfix; stash your work first. | Use descriptive stash messages so you know what each stash contains. |
| **Stash (Include Untracked)** | Stash plus untracked files. | When your work includes new files that you also want to shelve. | New script plus edits; use Stash (Include Untracked). | Helpful when prototyping new scripts or docs you are not ready to commit. |
| **Stash Staged** | Stash only the staged changes. | When you staged some files but want to temporarily remove them from staging/workspace. | Stash staged docs but leave code edits visible. | Rarely needed; normal Stash covers most workflows. |
| **Apply Latest Stash** | Apply the most recent stash without removing it from the stash stack. | When you want to reapply work but may want the stash available as a backup. | After switching back to your feature branch, apply latest stash. | If the result looks good, you can later drop the stash. |
| **Apply Stash…** | Apply a specific stash from the list. | When you have multiple stashes and want a particular one. | Choose the stash labelled `WIP: GUI layout changes`. | Keep stash names meaningful to make selection easier. |
| **Pop Latest Stash** | Apply the most recent stash and remove it from the stash list. | When you are confident you want to restore that work and no longer need the stash. | Pop your last stash after returning to the branch. | Use when you are sure; otherwise, apply first and drop manually. |
| **Pop Stash…** | Pop a specific stash by name. | Similar to Apply Stash…, but removes the stash after applying. | Pop an older stash once you know it is correct. | Be careful: if conflicts occur and you cancel, you may lose that stash. |
| **Drop Stash…** | Delete a specific stash without applying it. | When you are sure a particular stash is no longer needed. | Drop an experimental stash after finishing a better solution. | This action is permanent; double-check before dropping. |
| **Drop All Stashes…** | Delete all stashes. | Major cleanup when many stashes have accumulated and none are needed. | After a long refactor where all useful changes are already merged. | Very destructive. Consider exporting patches or branches first. |
| **View Stash…** | Show the list of stashes (and often their diffs, depending on extensions). | When you want to inspect what each stash contains. | View stashes before deciding which one to apply or drop. | Use before applying or dropping to confirm contents. |

---

#### 1.1.7 Tags menu

| Item (VS Code) | Git concept | When to use it | Example | Best practice |
|----------------|------------|----------------|---------|--------------|
| **Create Tag…** | Create a tag on a specific commit (usually the current one). | When you mark a release or important snapshot, such as `v1.0.0`. | After finishing initial release, create tag `v1.0.0`. | Use semantic versioning for tags (v1.0.0, v1.1.0) so customers can align binaries and docs. |
| **Delete Tag…** | Delete a local tag. | When you created a tag by mistake or want to rename it. | Delete an incorrectly named `v1.00`. | Only delete tags you are certain are not referenced by others. |
| **Delete Remote Tag…** | Delete a tag from the remote (GitHub). | When a published tag is wrong and must be removed. | Delete remote `v1.0.0-rc1` after deciding not to support that label. | Coordinate with any consumers before removing remote tags. |
| **Push Tags** | Push local tags to the remote. | After creating or updating tags locally so GitHub has the same tags. | Tag `v1.0.0`, then Push Tags. | Run this after creating release tags so your GitHub Releases and documentation link to correct commits. |

---

#### 1.1.8 Worktrees menu (advanced)

| Item (VS Code) | What it does | When to use it | Example | Best practice |
|----------------|--------------|----------------|---------|---------------|
| **Create Worktree…** | Creates an additional working directory for a different branch of the same repo, all linked to one `.git` folder. | When you want to have two branches checked out at the same time in separate folders (for example, `main` and a long-running feature). | Create a worktree for `feature/experimental-branch` while keeping `main` open separately. | Advanced feature. For most BNT MemMan work, one working copy is enough. Use worktrees when juggling long-lived branches on the same machine. |

You now have a one-to-one mapping between the VS Code menus in your screenshots and Git concepts plus usage guidance, ready to support both your own development and customer coaching on dev/stage/prod workflows.


[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 2. Where feature branches store their files and how to switch

Git branches do **not** create separate folders automatically. All branches share the same working directory; Git swaps the file content when you change branches.

For this toolkit:

- Local repo path:  
  `C:\Users\brian\OneDrive\Brian-Secure\00_Cloud-Projects\Project_BY-Williams\03_Channel_BRAINNG\06_BNT-Toolkits\Windows\bnt-memman-toolkit`

### 2.1 main vs feature branches

- When you run:

  ```powershell
  git checkout main
  ```

  The files in that folder represent the current state of the `main` branch.

- When you run:

  ```powershell
  git checkout -b feature/v1.1-gui
  ```

  You remain in the same folder, but Git now tracks changes on `feature/v1.1-gui`. Any edits in VS Code belong to that branch until you switch again.

- To switch back to `main` later:

  ```powershell
  git checkout main
  ```

  The working files are updated to match the latest `main` branch.

### 2.2 Typical branch switching workflow

1. Start from `main` and ensure it is up to date:

   ```powershell
   git checkout main
   git pull
   ```

2. Create and switch to a feature branch:

   ```powershell
   git checkout -b feature/v1.1-gui
   ```

3. Work in VS Code, commit changes as needed:

   ```powershell
   git add .
   git commit -m "Implement GUI shell for BNT MemMan Toolkit"
   ```

4. Push the feature branch once:

   ```powershell
   git push -u origin feature/v1.1-gui
   ```

5. When you are ready to test against the latest `main`:

   ```powershell
   git checkout main
   git pull
   git checkout feature/v1.1-gui
   git merge main
   ```

   Resolve any merge conflicts, test, then push again:

   ```powershell
   git push
   ```

6. After the feature is merged via PR, switch back to `main` for new work:

   ```powershell
   git checkout main
   git pull
   ```

### 2.3 Seeing which branch is active

- Command line:

  ```powershell
  git status
  ```

  The first line shows `On branch main` or `On branch feature/...`.

- VS Code:

  - The current branch name is displayed in the lower-left status bar.  
  - You can click it to quickly switch or create branches.

[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 3. Recommended branch and PR workflow

Even as a single maintainer, use **feature branches and pull requests** to maintain clean history and self-review.

### 3.1 Branch strategy

- `main`  
  - Stable, releasable code only.  
  - Tagged releases (`v1.0.0`, `v1.1.0`, etc.).

- `feature/...`  
  - New features, experiments, refactors.  
  - Examples: `feature/v1.1-gui`, `feature/logging-enhancements`, `feature/docs-git-workflow`.

### 3.2 Basic PR workflow



| Step | Action | Example | Best practice |
|------|--------|---------|--------------|
| 1 | Create feature branch from `main`. | `git checkout main`, then `git pull`, then `git checkout -b feature/v1.1-gui` | Always start from an up-to-date `main` so your feature branch is current. |
| 2 | Implement, stage, and commit changes. | `git add .` then `git commit -m "Add initial WPF GUI shell for BNT MemMan Toolkit"` | Use multiple commits if needed, but keep each commit logically consistent. |
| 3 | Push branch to GitHub. | `git push -u origin feature/v1.1-gui` | The `-u` option sets upstream tracking, making future pushes simple from VS Code. |
| 4 | Open a pull request (PR). | Use GitHub UI → “Compare & pull request”. | In the PR description, document purpose, main changes, and any risks. |
| 5 | Self-review using GitHub diff. | Use GitHub → PR → “Files changed”. | Treat this as a proper code review: check safety, error handling, logging, and BNT conventions. |
| 6 | Merge into `main`. | Use GitHub → “Merge pull request”. | Merge only when your tests (manual or automated) and self-review pass. |
| 7 | Clean up the feature branch. | `git checkout main`, `git pull`, `git branch -d feature/v1.1-gui`, `git push origin --delete feature/v1.1-gui` | Delete completed feature branches locally and on GitHub to keep the branch list clean. |


[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 4. Reverting changes safely

Use **revert** for commits already pushed to GitHub. Reserve **reset** for local-only cleanup before pushing.

### 4.1 Revert the last commit on main

```powershell
git checkout main
git pull
git revert HEAD
git push origin main
```

### 4.2 Revert an older commit on main

```powershell
git checkout main
git pull
git log --oneline -n 10   # find hash, e.g. abc1234

git revert abc1234
git push origin main
```

[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 5. Reverting after merging a feature branch (undo a PR)

### 5.1 Using GitHub’s Revert button

1. Open the merged PR on GitHub.  
2. Click **Revert**.  
3. GitHub creates a new PR that inverses the merge.  
4. Review and merge that PR into `main`.

### 5.2 Reverting a merge commit locally

```powershell
git checkout main
git pull
git log --oneline --graph --decorate -n 10   # identify merge hash, e.g. abcd1234

git revert -m 1 abcd1234
git push origin main
```

[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 6. When and how to use git reset

Use `git reset` primarily **before** pushing to GitHub:

### 6.1 Fix the last local commit (before push)

```powershell
git reset --soft HEAD~1
# adjust files or message
git commit -m "Better, accurate description of the change"
git push origin main
```

After a commit is already on GitHub, prefer **git revert** instead of `git reset --hard` and `push --force`, unless you consciously want to rewrite history and understand the implications.

[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)

---

## 7. Branch cleanup and visibility

### 7.1 Listing branches

```powershell
git branch      # local branches
git branch -r   # remote branches
```

### 7.2 Deleting a completed feature branch

```powershell
# Local
git branch -d feature/v1.1-gui

# Remote
git push origin --delete feature/v1.1-gui
```

Cleaning up branches regularly keeps your GitHub repo and VS Code branch list readable.

[Back to top](#bnt-memman-toolkit--git-usage-and-workflow)
