# modify the following path before building
CC=gcc
LD=gcc

LIBNAME := libaes.so

CPPFLAGS=	-DOPENCL_ENGINE="\"$(LIBNAME)\""
CFLAGS=		-fPIC -std=c99 -O2 -Wall -Wno-deprecated-declarations -g
LDFLAGS=	-lOpenCL -lcrypto

PROG_SRCS := main.c
PROG_OBJS := $(patsubst %.c,%.o,$(PROG_SRCS))
PROG := Benchmark-OpenCL

LIB_SRCS := opencl.c
LIB_OBJS := $(patsubst %.c,%.o,$(LIB_SRCS))

all: $(PROG)

$(PROG): $(PROG_OBJS) $(LIBNAME)
	$(LD) $(CFLAGS) -o $@ $(PROG_OBJS) $(LDFLAGS)

$(LIBNAME): $(LIB_OBJS)
	$(LD) $(CFLAGS) -shared -Wl,-soname,$(LIBNAME) -o $@ $^

clean:
	rm -f *.o *.dylib
	rm -f $(PROG) $(LIBNAME) hello

%.o: %.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
