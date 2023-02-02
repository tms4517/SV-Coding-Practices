git checkout master
git reset --hard
git checkout -b myBranchE
echo '// foo' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Alice.'
git checkout master
git reset --hard
git checkout -b myBranchF
echo '// bar' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Bob.'
git checkout myBranchF
git status
git merge myBranchE
