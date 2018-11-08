appname := 0123HomeWork

defs :=

CC := nvcc
CFLAGS := -g -Wall ${defs}

CXX := nvcc
LDFLAGS :=

srcfiles := $(shell find . -name "*.cu")
objects  := $(patsubst %.c, %.o, $(srcfiles))

all: $(appname)

$(appname): $(objects)
	$(CXX) $(LDFLAGS) -o $(appname) $(objects) ${LDFLAGS}

clean:
	rm -f $(objects)
	rm -f $(appname)

dist-clean: clean
	rm -f *~ .depend