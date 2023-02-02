git checkout master
git reset --hard
git checkout -b myBranchG
echo '// foo' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Alice.'
git checkout master
git checkout -b myBranchH
echo '// bar' >> rtl/IntroProject.sv
git add !$
git commit -m 'Add foo comment, by Bob.'
git checkout myBranchG
git status
git merge myBranchH
git mergetool
