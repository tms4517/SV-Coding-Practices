echo '// HARMLESS' >> rtl/IntroProject.sv
git difftool
B1=origin/variant/1.0_2022.10.03_pab2
B2=origin/variant/1.0_2022_05_04_maac
F=rtl/IntroProject.sv
git difftool ${B1}:${F} ${B2}:${F}
