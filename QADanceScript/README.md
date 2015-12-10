From the script itself:

## Use case

You are in the middle of coding and QA wants new stuff that are on development branch. Example after a pull request was merged. This script will then save your current state (stash+current branch), checkout and pull development branch so that you're up to date from origin, do the same for qa branch (pull origin), then merge the new stuff from development branch into the qa branch and push it up. Then it will restore your state (stash+branch). All in less than 30 seconds.


## What will happen

1. CD to your project folder (`REPO_DIR`)
2. Stash any temporary work in a new stash
2.5 Save the current branch name (so we can go back automatically)
3. Checkout `BRANCH_TO_MERGE_FROM` branch
4. Pull `BRANCH_TO_MERGE_FROM` branch to ensure up-to-dateness
5. Checkout `BRANCH_TO_MERGE_INTO` branch
6. Pull `BRANCH_TO_MERGE_INTO` branch to ensure up-to-dateness
7. Merge `BRANCH_TO_MERGE_FROM` INTO `BRANCH_TO_MERGE_INTO`
8. Push `BRANCH_TO_MERGE_INTO` to origin/`BRANCH_TO_MERGE_INTO`
9. Checkout the previous/saved/working branch from step 2.5
10. Apply the saved stash