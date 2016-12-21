.PHONY: all fmt clean gfmt tags test

all:
	@rm -rf _
	sml -test=false -std=/ -golike -initpc=0x8000 # compile
	make -C _toys
	gofmt -l -w `find . -name "*.g"`
	gotags `find . -name "*.g"` > tags
	smlvm -n=100000000 -rom=_rom -seed=2 -s _/bin/smlos.e8

static:
	sml -test=false -golike -initpc=0x8000 -static
	
tall:
	sml -test=false -std=/ -golike -initpc=0x8000 # compile
	sml -n=100000000 -rom=_rom -seed=0 bin/smlos/sync/tests.e8

test:
	sml -golike -std=/ -initpc=0x8000
	gofmt -l -w `find . -name "*.g"`

gfmt:
	gfmt `find . -name "*.g"`

fmt:
	gofmt -l -w `find . -name "*.g"`

clean:
	rm -rf bin log

tags:
	gotags `find . -name "*.g"` > tags

lc:
	wc -l `find . -name "*.g"`
