# MISSION DAY 15: GIT BRANCHING & MERGING CONCEPTS

## What is a Branch?
- A branch is not a copy of the code. It is a lightweight, movable **pointer** to a specific commit.
- The default branch is called `main` (or `master`).
- `HEAD` is another special pointer that points to the branch you are currently working on.

## Why is Branching the Standard Professional Workflow?
- **Isolation:** You can work on a new, experimental feature (e.g., `dark-mode`) on its own branch without affecting the stable `main` branch. If the feature fails, you can just delete the branch.
- **Collaboration:** Multiple developers can work on different features on different branches simultaneously without interfering with each other.
- **Safety & Stability:** The `main` branch is treated as sacred. It should always contain production-ready, working code. Merges into `main` are typically controlled and tested.

## The Basic Feature Branch Workflow
1.  **Sync `main`:** Before starting new work, always make sure your local `main` branch is up-to-date with the remote repository (`git pull origin main`).
2.  **Create Branch:** Create a new branch for your specific task. Naming is important. Good names are `feat/add-user-login` or `fix/correct-typo-on-homepage`.
    - `git branch <branch-name>`
3.  **Switch to Branch:** Check out the new branch to begin working on it.
    - `git checkout <branch-name>`
    - (Shortcut for steps 2 & 3: `git checkout -b <branch-name>`)
4.  **Work and Commit:** Make your code changes. Commit your work in small, logical chunks to this feature branch.
    - `git add .`
    - `git commit -m "FEAT: Add email field to login form"`
5.  **Merge Back to `main`:** Once the feature is complete and working:
    - `git checkout main`
    - `git merge <branch-name>`
6.  **Clean Up:** After a successful merge, the feature branch has served its purpose and can be deleted.
    - `git branch -d <branch-name>` (safe delete)