appname := 0123HomeWork

defs :=

CC := nvcc
CFLAGS := -dc -arch sm_30 -g ${defs}

CXX := nvcc
LDFLAGS := -arch sm_30

srcfiles := $(shell find . -name "*.cu")
objects  := $(patsubst %.cu, %.o, $(srcfiles))

all: $(appname)

$(appname): $(objects)
	$(CXX) $(LDFLAGS) -o $(appname) $(objects)

%.o: %.cu
	$(CC) $(CFLAGS) $< -o $@

clean:
	rm -f $(objects)
	rm -f $(appname)

dist-clean: clean
	rm -f *~ .depend
