
PDF ?= slides.pdf
SRC_MD ?= $(shell find . -maxdepth 1 -regex '\./[0-9]+.*\.md' | sort)

default:
	pandoc -t beamer ${SRC_MD} -o ${PDF}

.PHONY: clean
clean:
	rm ${PDF}

