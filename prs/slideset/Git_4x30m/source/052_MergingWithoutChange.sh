git checkout master
git reset --hard
git checkout -b myBranchA
echo '// foo' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Alice.'
git checkout master
git reset --hard
git checkout -b myBranchB
echo '// foo' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Bob.'
git checkout myBranchA
git checkout master
git checkout myBranchB
git status
git merge myBranchA
