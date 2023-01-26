- Syllabus:
  - git vs dogit
  - semver
  - Implementations of RCS, CVS, SVN, git, dogit.
  - Merging howto.
    - temp branch onto master
    - non-master to non-master
      - checkout destination
      - git merge source
      - commit, push

- History RCS
  - <https://www.gnu.org/software/rcs/>
  - 1st generation, but not obsolete!
  - Specifically a collection of utilities (not a single exe):
    ci, co, ident, rcs, rcsclean, rcsdiff, rcsfreeze, rcsmerge, rlog
  - stores separate/unmerged reverse deltas, line-based.
  - lock indicates that somebody intents to deposit a new revision later.
  - branches are on version numbers, symbolic name is a prefix shortcut.
  - Concept of joining is similar to merging.
  - Stamping, like `$Header$`, doesn't exist but note CI/CD.
  - An edit script is a patchfile.
- History CVS
  - <https://cvs.nongnu.org/>
  - 2nd generation, mostly obsolete.
  - Frontend to RCS bringing client/server model
  - Composed of fewer executables (cvs, cvspserver).
  - Delta compression distinguishes between text and binary.
  - Project is a set of related files.
  - Introduced "loginfo" similar to githooks.
  - Centralised repository, usually accessed over RSH (predecessor to SSH).
- History SVN
  - <https://subversion.apache.org/>
  - 2nd generation, mostly obsolete.
  - Intended to be successor to CVS, and mostly compatible.
  - Many implementations of both clients and servers.
  - Centralised repository, accessed over SSH, HTTP, or HTTPS
  - Atomic commits to multiple files.
  - Properties (key/value pairs).
  - The SVN tool is version controlled, with incompatibilities.
  - Relies heavily on conventions (trunk, branches, tags) so it's easy to make
    a mess.
- History Git
  - <https://git-scm.com/>
  - 3rd/current generation.
  - Distributed network of repositories, accessed over SSH or HTTPS.
  - Every repository has a full copy of history.
    Locking concept doesn't apply, but can be emulated.
  - Concepts of branches and tags are first-class citizens with precise
    definitions.
  - Concept of version numbering is intentionally avoided.
  - Concept of stamping, like `$Header$`, doesn't exist but note CI/CD.
- History SemVer
  - <https://semver.org/>
  - Specification of how version numbering scheme on one page.
  - Used for many/most open-source project releases.
  - Used as basis for Nordic's internal IP/HDN releases.
  - ...Show the tiny webpage...


- 1030..1100 Meet and greet, coffee.
  - Miss the traffic, low stress.
  - Get some work done in the morning.
  - ...plus last-minute prep for me.
  - Morning will be background, with almost nothing that's specific to Nordic.
  - Afternoon will cover Nordic-specific tooling, then merging and some tips
    for usability.
- 1100..1200 History
  - Start easy, low importance, let the coffee soak in.
  - Introduction and agenda.
  - Will cover RCS, then CVS, SVN, git, and semver.
    - Other VCSes exist, but these have been the most popular and relevant for
      Nordic.
  - RCS tracks one file.
    - The utilities can take multiple arguments, but they're processed
      individually, i.e. not atomic.
    - The repository is in files on your filesystem.
    - Versioning scheme is tied to its concept of branching.
- 1100..1200 Practical
  - Practical before lunch means they're not falling asleep.
  - Shouldn't feel scary.
  - Practical helps the salient points sink in.
- 1200..1300 Lunch
- 1300..1400 NoRRIS, Dogit

- RCS Practical 10min
  - <https://www.madboa.com/geek/rcs/>
  - Let's start by making the directory for RCS to keep its data.
    - `mkdir RCS`
  - And make a couple of files to play with.
    - `echo -e 'hello\nworld' > foo.txt`
    - `echo -e 'red\nblue' > bar.txt`
    - `ls -al ./ RCS/`
  - Next, let's tell RCS to manage these files.
    By default, RCS will delete the original files on checkin, so you usually
    want the `-u` option to keep them in the working directory.
    - `ci -u foo.txt bar.txt`
    - `ls -al ./ RCS/`
    - `cat RCS/foo.txt,v`
  - Now let's try making a change to `foo.txt`
    - `echo writableNo >> foo.txt`
  - But wait! You need to checkout first.
    - `co -l foo.txt`
    - `echo writableYes >> foo.txt`
    - `ls -al ./ RCS/`
  - And finally, we can observe that we've made changes.
    - `rcsdiff`
  - The point of this was just to get familiar with inspecting the system and
    give a point of comparison against git.

- Git Practical 30min
  - Follows then extends what we just did with RCS.
  - Let's start by initialising the repository.
    - `git init`
  - And make a couple of files to play with.
    - `echo -e 'hello\nworld' > foo.txt`
    - `echo -e 'red\nblue' > bar.txt`
    - `ls -al ./ .git/`
  - Immediately noticable is that the management structure looks more like a
    database.
    Git commands mostly work on these files, so let's see an example of that
    with `.git/config`.
    - `cat .git/config` and/or `git config user.name`
    - `git config user.name "Foo McBar"`
    - `cat .git/config` and/or `git config user.name`
  - Next, let's tell git to manage our files.
    This has two steps (add to the staging area, then the atomic commit).
    - `git add foo.txt bar.txt`
    - `git commit -m 'Little message about the changes.'.
  - Also different from RCS is that we can always edit our working files.
    - `echo writableYes >> foo.txt`
  - We can see changes between the working directory and the staging area (also
    known as the cache).
    - `git diff`
  - And changes between the staging area and the commited files.
    - `git add foo.txt`
    - `git diff --cached`
  - Those things are immediately comparable to RCS.
    You can see exactly what is meant by atomicity, and how things are arranged
    in your local directory.
    Now let's have a look at the distributed and decentralised features.
  - Create a bare repository that can work like BitBucket, then have a
    look inside.
    - `git init --bare BriBucket`
    - `ls BriBucket/`
  - Now we can add that as a remote for our original, note that this does
    nothing to BriBucket yet.
    We're using the name `bb`, but BitBucket and GitHub suggest the name
    `origin` in their documentation (it's your choice and affects nobody else).
    - `git remote add bb path/to/BriBucket`
  - When we push our original repo, that's when the network access occurs.
    - `git push bb master`
    - Now have a look around BriBucket where you can see that the contents
      under `objects/` is identical to those in our local copy.
  - You can add as many remotes as you like, name them however you like, and
    synchronise them however you like.
    To see a nice overview use the included GUIs `git gui &` (for working with
    local changes) and `gitk --all &` (for seeing what your local repo knows
    about other repos).
  - Finally, let's play with a merge which has a little conflict.
    Remember, merging the changes from a branch in your local repo is the same
    as merging the changes from a branch on a remote repo - just fetch first.
    - `git checkout -b firstBranch`
    - `echo apples >> foo.txt && git add . && git commit -m 'Add apples.'`
    - `git checkout master && git checkout -b secondBranch`
    - `echo oranges >> foo.txt && git add . && git commit -m 'Add oranges.'`
    - `git checkout master`
  - Now our working directory is pointing at the HEAD of master.
    We'll merge the first branch, then the second.
    - `git merge firstBranch`
    - `git merge secondBranch`
  - That didn't work because, in the second merge, changes had been made to the
    same part of the file touched by a commit since their common ancestor.
    We could also have made this conflict by adding the "apples" line directly
    on the master branch.
  - To fix the conflict, we need to choose what is right.
    The simplest way to do this is to accept either change using `git gui`,
    then modify it manually before the merge is committed.
    We'll go over different ways of merging in the afternoon.
