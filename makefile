.PHONY: all fmt clean e8fmt tags test

all:
	e8 -test=false -golike -initpc=0x8000 # compile
	make -C usr
	gofmt -l -w `find src -name "*.g"`
	gofmt -l -w `find usr/src -name "*.g"`
	gotags `find src -name "*.g"` > tags
	e8vm -n=100000000 -rom=./rom -seed=2 -s bin/os8.e8 # run in simulator

static:
	e8 -test=false -golike -initpc=0x8000 -static
	
tall:
	e8 -test=false -golike -initpc=0x8000 # compile
	e8vm -n=100000000 -rom=./rom -seed=0 bin/os8/sync/tests.e8 # run in simulator

test:
	e8 -golike -initpc=0x8000
	gofmt -l -w `find src -name "*.g"`

e8fmt:
	e8fmt `find src -name "*.g"`

fmt:
	gofmt -l -w `find src -name "*.g"`

clean:
	rm -rf bin log

tags:
	gotags `find src -name "*.g"` > tags

lc:
	wc -l `find src -name "*.g"`
