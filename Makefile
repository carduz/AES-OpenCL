# modify the following path before building
CC=gcc
LD=gcc

CPPFLAGS=
CFLAGS=		-fpic -fPIC -fpie -fPIE -std=c99 -O2 -Wno-deprecated-declarations
LDFLAGS=	/usr/lib/x86_64-linux-gnu/libOpenCL.so.1 -lcrypto

SRCS := $(wildcard *.c)
OBJS := $(patsubst %.c,%.o,$(SRCS))
PROG := Benchmark-OpenCL

all: $(PROG)

$(PROG): $(OBJS)
	$(LD) $(CFLAGS) -o $@ $^ $(LDFLAGS)

clean:
	rm -f *.o *.dylib
	rm -f $(PROG)

# dependency
%.c: %.o
	$(CC) $(CPPFLAGS) $(CFLAGS)