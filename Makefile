#Makefile for pcs

CC=gcc
FC=gfortran

root_dir=$(shell pwd)
cpfloat_dir=${root_dir}/external/cpfloat
cpfloat_paths=-I${cpfloat_dir}/build/include -L${cpfloat_dir}/build/lib -L${cpfloat_dir}/deps/pcg-c/src -I${cpfloat_dir}/deps/pcg-c/include
CLIBS=-lm -lcpfloat -lpcg_random
CFLAGS=-Wall -Wextra -pedantic -march=native -std=gnu99


src/example: src/libpcs.a src/libpcs.so
	${CC} ${CFLAGS} ${cpfloat_paths} -Lsrc src/example.c -o src/example -lpcs ${CLIBS}

src/pcs.o: src/pcs.c src/pcs.h 
	${CC} ${CFLAGS} ${cpfloat_paths} -c src/pcs.c -o src/pcs.o ${CLIBS}

src/libpcs.so: src/pcs.o
	$(CC) -shared -o $@ $<

src/libpcs.a: src/pcs.o
	ar -cr $@ $< 

cpfloat: ${cpfloat_dir}/build/include/cpfloat.h
	cd ${cpfloat_dir} && make lib && cd ${root_dir}


clean:
	rm src/pcs

