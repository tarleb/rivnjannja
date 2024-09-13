.PHONY: test

test:
	pandoc-lua test/runtests.lua test/perevirky

README.md: tools/docs.yaml tools/place-block.lua $(wildcard test/perevirky/*)
	pandoc -d tools/docs --output=$@
