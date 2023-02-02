
## Merging With Conflict(s) 1of4
- This is the simplest kind of merge, where the same changes have been made on
  converging branches.
- First, let's get back to a known state and make a change on one branch.
  - `git checkout master`
  - `git reset --hard`
  - `git checkout -b myBranchE`
  - `echo '// foo' >> rtl/IntroProject.sv`
  - `git add !$`
  - `git commit -m 'Add foo comment, by Alice.'`

## Merging With Conflict(s) 2of4
- Second, get back to a known state and make a conflicting change on another
  branch.
  - `git checkout master`
  - `git reset --hard`
  - `git checkout -b myBranchF`
  - `echo '// bar' >> rtl/IntroProject.sv`
  - `git add !$`
  - `git commit -m 'Add foo comment, by Bob.'`

## Merging With Conflict(s) 3of4
- To start the merge, first switch to the "destination" branch, i.e. the one
  that will still be worked upon.
  Let's choose to merge `myBranchE` into `myBranchF`.
  - `git checkout myBranchF`
  - `git status`
  - `git merge myBranchE`
  - ... This needs some attention.

## Merging With Conflict(s) 4of4
- Look at the conflicts with `git gui`.
- Search for conflicts with `<<<<<`, `=====`, and `>>>>>`.
- Fixup the file, commit, and look at the history.
- A simple strategy is to accept the "remote" version, then make (and stage)
  edits, then commit.

