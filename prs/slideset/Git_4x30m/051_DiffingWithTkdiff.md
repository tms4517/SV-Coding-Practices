
## Diffing with `tkdiff` 1of1
- Let's introduce a harmless change to a tracked file.
  - `echo '// HARMLESS' >> rtl/IntroProject.sv`
  - `git difftool`
- We can also use `tkdiff` to diff over branches.
  - `B1=origin/variant/1.0_2022.10.03_pab2`
  - `B2=origin/variant/1.0_2022_05_04_maac`
  - `F=rtl/IntroProject.sv`
  - `git difftool ${B1}:${F} ${B2}:${F}`
- First argument is LHS, second argument is RHS.
- Use `n` and `p` to move quickly to next and previous changes.
- See the documentation for all the ways you can diff.
  - <https://git-scm.com/docs/git-diff>
  - <https://git-scm.com/docs/git-difftool>
