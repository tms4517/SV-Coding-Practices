echo -e 'hello\nworld' > foo.txt
echo -e 'red\nblue' > bar.txt
ls -al
git init
find . | sort
git config user.name
git config user.name "Foo McBar"
git config user.name
git add foo.txt bar.txt
echo writableYes >> foo.txt
git diff
git add foo.txt
git diff --cached
git init --bare BriBucket
ls BriBucket/
git remote add bb path/to/BriBucket
git push bb master
git gui &
gitk --all &
git checkout -b firstBranch
echo apples >> foo.txt && git add . && git commit -m 'Add apples.'
git checkout master && git checkout -b secondBranch
echo oranges >> foo.txt && git add . && git commit -m 'Add oranges.'
git checkout master
git merge firstBranch
git merge secondBranch
