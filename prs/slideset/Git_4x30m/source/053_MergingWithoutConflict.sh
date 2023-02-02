git checkout master
git reset --hard
git checkout -b myBranchC
echo '// foo' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Alice.'
git checkout master
git reset --hard
git checkout -b myBranchD
echo '// foo' >> abc/Design.fl
git add !$
git commit -m 'Add foo comment, by Bob.'
git checkout myBranchC
git status
git merge myBranchD
