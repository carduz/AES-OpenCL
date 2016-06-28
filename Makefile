# modify the following path before building
CC=gcc
LD=gcc

PWD := $(shell pwd)

CPPFLAGS =	-DOPENCL_ENGINE="\"$(PWD)/$(LIB_NAME)\""
CFLAGS   :=	-fPIC -std=c99 -O2 -Wall -Wno-deprecated-declarations -g

ifeq ($(wildcard /usr/lib/x86_64-linux-gnu/libOpenCL.so.1),)
	LIB_OCL := -lOpenCL
else
	LIB_OCL := /usr/lib/x86_64-linux-gnu/libOpenCL.so.1
endif

PROG_NAME := Benchmark-OpenCL
PROG_SRCS := main.c
PROG_OBJS := $(patsubst %.c,%.o,$(PROG_SRCS))
PROG_LDFLAGS := -lcrypto $(LIB_OCL)

LIB_NAME := libaes.so
LIB_SRCS := opencl.c
LIB_OBJS := $(patsubst %.c,%.o,$(LIB_SRCS))
LIB_LDFLAGS := $(LIB_OCL)

all: $(PROG_NAME)

$(PROG_NAME): $(PROG_OBJS) $(LIB_NAME)
	$(LD) $(CFLAGS) -o $@ $(PROG_OBJS) $(PROG_LDFLAGS)

$(LIB_NAME): $(LIB_OBJS)
	$(LD) $(CFLAGS) -shared -Wl,-soname,$(LIB_NAME) -o $@ $^ $(LIB_LDFLAGS)

clean:
	rm -f *.o *.dylib
	rm -f $(PROG_NAME) $(LIB_NAME)

%.o: %.c
	$(CC) -c -o $@ $(CPPFLAGS) $(CFLAGS) $<
	
bench: SHELL:=/bin/bash
bench: $(PROG_NAME)
	@for mem in 1 2 4; do \
	  for wi in 16 64 128 256; do \
	    echo "MEMORY: $$mem GB"; echo "WORK_ITEMS: $$wi"; \
	    BENCH_TOTAL_MEMORY="$$(($$mem * 1024))" \
	    BENCH_CHUNK_SIZE="$$(($$mem * 32))" \
	    OPENSSL_OPENCL_LOCAL_WORK_SIZE="$$wi" \
	    ./$(PROG_NAME); done; done;
	
.PHONY: bench	
