# The Professional GitHub Workflow: Pull Requests (PRs)

This is how teams collaborate on code safely. Instead of merging directly into `main` on your local machine, you ask for your changes to be "pulled in" through the GitHub interface.

**The Full Cycle:**

1.  **Create a Feature Branch (Local):** Start your work on a new, separate branch to keep `main` clean.
    - `git checkout -b <branch-name>`

2.  **Do the Work & Commit (Local):** Create your files (`Dockerfile`, `main.py`, etc.) and save your progress with commits on this branch.
    - `git add .`
    - `git commit -m "Your descriptive message"`

3.  **Push the Branch to GitHub (Remote):** Make your local branch available on the remote GitHub repository.
    - `git push origin <branch-name>`

4.  **Open a Pull Request (on GitHub):** In the GitHub web interface, you "request" to merge your new branch into the `main` branch. This opens a discussion forum for your code.

5.  **Code Review (on GitHub):** In a team, this is where other engineers would review your code, add comments, and request changes. (Today, you will be your own reviewer).

6.  **Merge the Pull Request (on GitHub):** Once the code is approved, an authorized person clicks the "Merge pull request" button on the website. This merges your code into the `main` branch *on GitHub*.

7.  **Local Cleanup (Local):** Your local machine doesn't know the merge happened yet. You must sync up and clean up.
    - `git checkout main` (Switch back to your local main branch).
    - `git pull origin main` (Pull the newly merged changes from GitHub down to your local main branch).
    - `git branch -d <branch-name>` (Delete the now-unneeded local feature branch).