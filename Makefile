.PHONY: help
help: # Display help
	@awk -F ':|##' \
		'/^[^\t].+?:.*?##/ {\
			printf "\033[36m%-30s\033[0m %s\n", $$1, $$NF \
		}' $(MAKEFILE_LIST) | sort

.PHONY: build
build: convert merge ## run both convert and merge

.PHONY: convert
convert:  ## convert markdown to html
	./tools/convert.sh

.PHONY: merge
merge:  ## move converted files to gh-pages branch
	./tools/merge.sh

.PHONY: deploy
deploy:  ## deploy to gh-page branch
	git add remote upstream git@github.com:CiscoCloud/vaquero-docs.git || true
	git add -A
	git commit -am "Updates"
	git push upstream gh-pages

all: convert merge deploy
