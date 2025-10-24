### Q: What are the steps for the Pull Request (PR) workflow?

A: The Pull Request workflow is how professional teams add new code to a project. It involves doing work on a separate branch locally and then asking for it to be merged into the main project on GitHub.

1.  **Create a Branch:** Start a new, separate timeline for your feature.
    *   `git checkout -b my-new-feature`

2.  **Do Your Work & Commit:** Create or edit files, and then save your work as one or more commits on this new branch.
    *   `git add .` (Stage all changes)
    *   `git commit -m "FEAT: Add the new feature"` (Save the changes with a descriptive message)

3.  **Push Your Branch to GitHub:** Make your local branch visible on the remote GitHub server. **Crucially, you push your feature branch, not `main`.**
    *   `git push origin my-new-feature`

#### Part 2: On the GitHub Website

4.  **Create the Pull Request:** Go to the repository on GitHub. A yellow banner will appear.
    *   Click the green **"Compare & pull request"** button.
    *   Give your PR a title and click **"Create pull request"**.

5.  **Review and Merge:** Now the formal review happens. (For personal projects, you are your own reviewer).
    *   Click the green **"Merge pull request"** button.
    *   Click **"Confirm merge"**. The code is now officially in the `main` branch on GitHub.

#### Part 3: Back on Your Local Machine (Cleanup)

6.  **Sync and Clean Up:** Update your local `main` branch and delete the now-unnecessary feature branch.
    *   `git checkout main` (Switch back to the main timeline)
    *   `git pull origin main` (Download the changes you just merged from GitHub)
    *   `git branch -d my-new-feature` (Safely delete the local feature branch)


    <!-- ======================================================================== -->

### Q: What is the difference between a Docker Image and a Docker Container?

A: The relationship between an Image and a Container is like the relationship between a LEGO blueprint and the actual, built LEGO model.

*   A **Docker Image** is the **blueprint**. It is a read-only template that contains everything needed to run an application: the code, a runtime (like Python), libraries, and environment variables. You build an Image once from a `Dockerfile`.

*   A **Docker Container** is the **running instance** of an Image. It's the blueprint brought to life. You can start, stop, and interact with a Container. You can run many separate Containers from the exact same Image, just like you can build many identical LEGO cars from the same blueprint box.

<!-- ======================================================================= -->

### Q: What is the core problem that a tool like Alembic solves?

A: Alembic solves the massive problem of **managing and synchronizing database schema changes** over time in a safe, repeatable, and version-controlled way.

Manually changing a database (e.g., by running `ALTER TABLE` yourself) is a bad practice for several key reasons:

1.  **It's Risky and Error-Prone:** A simple human typo could lead to deleting the wrong table, adding a column with the wrong data type, or even dropping an entire production database by mistake.

2.  **It's Not Repeatable:** When a new developer joins the team, how do they set up their database? You would need to give them a long, complex list of SQL commands to run in the correct order, which is inefficient and unreliable.

3.  **It's Not Version-Controlled:** Your application code lives in Git, where you have a clear history of every change. If you change the database manually, that history is lost. You don't know who made the change, when, or why.

**Alembic solves this by treating your database schema like code.** It generates Python scripts for every change, which can be saved in Git. This makes the process automated, safe, and part of your project's official history.

<!-- ===================================================================== -->

### Q: What do these three key Alembic commands do?

A: These three commands represent the core workflow for managing database migrations.

1.  **`alembic init alembic`**
    *   This command creates the initial `alembic` directory and `alembic.ini` configuration file, setting up the necessary environment to start using Alembic in a project.

2.  **`alembic revision --autogenerate -m "A message"`**
    *   This command automatically compares your current SQLAlchemy models against the state of the database and generates a new migration script in the `versions` folder that contains the SQL needed to sync them.

3.  **`alembic upgrade head`**
    *   This command applies all available and unapplied migration scripts to the database, bringing its schema fully up-to-date with the latest revision (`head`).

    <!-- ================================================================ -->

