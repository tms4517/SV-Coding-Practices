cd /work/${USER}/
dogit ip IntroProject
cd ./Workspace_IntroProject/ip/IntroProject/
vc && tools
pushd ../../ && ls -l ip/ && popd
git log
rw
git log
git branch
git remote -v
git branch -a
git config --global diff.tool tkdiff
git config --global merge.tool kdiff3
echo BREAKTHINGS >> ./rtl/IntroProject.sv
git pull
git stash
git pull
git stash pop
git reset --hard
git revert <commit>
feature/[free text]_JIRAKEY-1234
bugfix/[free text]_JIRAKEY-1234
playground/[free text]
git push --set-upstream origin feature/noJira
