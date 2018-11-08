appname := 0123HomeWork

defs :=

CC := nvcc
CFLAGS := -arch sm_30 -g -Wall ${defs}

CXX := nvcc
LDFLAGS := -arch sm_30

srcfiles := $(shell find . -name "*.cu")
objects  := $(patsubst %.c, %.o, $(srcfiles))

all: $(appname)

$(appname): $(objects)
	$(CXX) $(LDFLAGS) -o $(appname) $(objects)

clean:
	rm -f $(objects)
	rm -f $(appname)

dist-clean: clean
	rm -f *~ .depend
