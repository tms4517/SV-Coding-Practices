
.PHONY: default
default: SemVerRtl.pdf

DATE_ISO8601 := $(shell date +"%Y-%m-%d")
TIME_ISO8601 := $(shell date +"%H:%M:%S")
DATETIME_ISO8601 := ${DATE_ISO8601}T${TIME_ISO8601}

PANDOC_FLAGS := -f markdown
#PANDOC_FLAGS += --metadata "title=Addendum to SemVer: System-on-Chip Packages"
#PANDOC_FLAGS += --metadata "author=Dave McEwan"
#PANDOC_FLAGS += --metadata "date=${DATETIME_ISO8601}"
PANDOC_FLAGS += --metadata "keywords=SemVer"
PANDOC_FLAGS += --metadata "keywords=SoC"
PANDOC_FLAGS += --metadata "keywords=SystemVerilog"
PANDOC_FLAGS += --metadata "keywords=Verilog"
PANDOC_FLAGS += --metadata "keywords=VHDL"
PANDOC_FLAGS += --variable=colorlinks
PANDOC_FLAGS += --variable=papersize:a4

# Minor tweaks for nicer formatting of PDF.
%.intermediateTex.md: %.md
	sed \
		-e 's/MAJOR/{\color{red}MAJOR}/' \
		-e 's/MINOR/{\color{orange}MINOR}/' \
		-e 's/PATCH/{\color{blue}PATCH}/' \
		$*.md > $@

#%.pdf: %.intermediateTex.md
#	pandoc -i $*.intermediateTex.md \
#

%.pdf: %.md
	@pandoc --version
	pandoc -i $*.md \
		${PANDOC_FLAGS} \
		-o $@

.PHONY: clean
clean:
	rm -f *.pdf
	rm -f *.intermediate*.*
