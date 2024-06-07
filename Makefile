#Makefile for pcs

CC=gcc

root_dir=$(shell pwd)
cpfloat_dir=${root_dir}/external/cpfloat
cpfloat_paths=-I${cpfloat_dir}/build/include -L${cpfloat_dir}/build/lib -L${cpfloat_dir}/deps/pcg-c/src -I${cpfloat_dir}/deps/pcg-c/include
CLIBS=-lm -lcpfloat -lpcg_random
CFLAGS=-Wall -Wextra -pedantic -march=native -std=gnu99


src/pcs: 
	${CC} ${CFLAGS} ${cpfloat_paths} src/pcs.c src/pcs.h -o src/pcs ${CLIBS}



cpfloat: 
	cd ${cpfloat_dir} && make lib && cd ${root_dir}


clean:
	rm src/pcs

