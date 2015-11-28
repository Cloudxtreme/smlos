.PHONY: all fmt clean e8fmt tags test run

all:
	e8 -test=false -golike -initpc=0x10000000 # compile

run:
	e8vm -n=10000000 -s -rom=./bin ../bin/os8.e8 # run in simulator

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
