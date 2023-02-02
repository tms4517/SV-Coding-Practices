echo -e 'hello\nworld' > foo.txt
echo -e 'red\nblue' > bar.txt
ls -al ./ RCS/
mkdir RCS
ci -u foo.txt bar.txt
ls -al ./ RCS/
cat RCS/foo.txt,v
echo writableNo >> foo.txt
co -l foo.txt
echo writableYes >> foo.txt
ls -al ./ RCS/
rcsdiff
