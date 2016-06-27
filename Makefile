# modify the following path before building
OPENCLLIB= /usr/lib/x86_64-linux-gnu/libOpenCL.so.1


LIBOPENCL=-L$(OPENCLLIB)


CC= 		gcc
LD=			cc

CPPFLAGS=
CFLAGS=		-std=c99 -O3 -Wno-deprecated-declarations
LDFLAGS=	$(LIBOPENCL)

LIBNAME=

LIBOBJ=		opencl.o

SOURCES= 	opencl.c
HEADERS= 	opencl.h

BENCHMARKS=	Benchmark-OpenCL

all: $(LIBNAME) $(BENCHMARKS)

$(LIBNAME): $(LIBOBJ)
	$(LD) -shared -Wl,-soname,$(LIBNAME) $(LDFLAGS) -o $(LIBNAME) $(LIBOBJ)



$(LIBOBJ): $(SOURCES) $(HEADERS)
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o $(LIBOBJ) $(SOURCES)

clean:
	rm -f *.o *.dylib
	rm -f $(BENCHMARKS)

Benchmark-OpenCL: main.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LDFLAGS) -o $@ $^

# dependency
opencl.c: opencl.h
