# modify the following path before building
CC=gcc
LD=gcc

LIBNAME := libaes.so

CPPFLAGS=	-DOPENCL_ENGINE="$(LIBNAME)"
CFLAGS=		-fpic -fPIC -fpie -fPIE -std=c99 -O2 -Wno-deprecated-declarations -g
LDFLAGS=	-Wl,--trace /usr/lib/x86_64-linux-gnu/libOpenCL.so.1 -lcrypto

PORG_SRCS := main.c
PROG_OBJS := $(patsubst %.c,%.o,$(PROG_SRCS))
PROG := Benchmark-OpenCL

LIB_SRCS := opencl.c
LIB_OBJS := $(patsubst %.c,%.o,$(LIB_SRCS))

all: $(PROG)

$(PROG): $(PROG_OBJS)
	$(LD) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(LIBNAME): $(LIB_OBJS)
	$(LD) $(CFLAGS) -Wl,--trace -shared -Wl,-soname,$(LIBNAME) -o $@ $^

$(PROG): $(LIBNAME)

hello: hello.o
	$(LD) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f *.o *.dylib
	rm -f $(PROG) $(LIBNAME) hello

%.o: %.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
