#Makefile for pcs

CC=gcc
FC=gfortran

root_dir=$(shell pwd)

ifndef ${PREFIX}
	PREFIX=${root_dir}/install
endif
pcs_dir=${root_dir}/src
cpfloat_dir=${root_dir}/external/cpfloat
cpfloat_paths=-I${cpfloat_dir}/build/include -L${cpfloat_dir}/build/lib -L${cpfloat_dir}/deps/pcg-c/src -I${cpfloat_dir}/deps/pcg-c/include
CLIBS=-lm -lcpfloat -lpcg_random
FCLIBS= -lcpfloat -lpcg_random 
CFLAGS=-Wall -Wextra -pedantic -march=native -std=gnu99

example: src/example

lib: src/libpcs.a src/libpcs.so src/libpcs_f.so src/libpcs_f.a

install: ${PREFIX} lib
	cp ${pcs_dir}/*.so ${PREFIX}/lib/.
	cp ${pcs_dir}/*.a ${PREFIX}/lib/.
	cp ${cpfloat_dir}/build/lib/* ${PREFIX}/lib/.
	cp ${cpfloat_dir}/deps/pcg-c/src/*.a ${PREFIX}/lib/.
	cp ${pcs_dir}/*.h ${PREFIX}/include/.
	cp ${pcs_dir}/*.mod ${PREFIX}/include/.
	cp ${cpfloat_dir}/build/include/* ${PREFIX}/include/.
	cp ${cpfloat_dir}/deps/pcg-c/include/* ${PREFIX}/include/.

${PREFIX}:
	mkdir ${PREFIX}
	mkdir ${PREFIX}/lib
	mkdir ${PREFIX}/include



src/example: lib install
	${CC} ${CFLAGS} -L${PREFIX}/lib -I${PREFIX}/include example/example.c -o example/example_c -lpcs ${CLIBS}
	${FC} ${FCFLAGS} -L${PREFIX}/lib -I${PREFIX}/include example/example.f90 -o example/example_f -lpcs_f -lpcs ${FCLIBS}


src/pcs.o: src/pcs.c src/pcs.h 
	${CC} ${CFLAGS} ${cpfloat_paths} -c src/pcs.c -o src/pcs.o ${CLIBS}

src/pcs_f.o: src/pcs_f.f90
	${FC} ${FCFLAGS} ${cpfloat_paths} -c src/pcs_f.f90 -o src/pcs_f.o ${FCLIBS}
	mv *.mod src

src/libpcs.so: src/pcs.o
	$(CC) -shared -o $@ $<

src/libpcs_f.so: src/pcs_f.o
	$(FC) -shared -o $@ $<

src/libpcs.a: src/pcs.o
	ar -cr $@ $< 

src/libpcs_f.a: src/pcs_f.o
	ar -cr $@ $< 

cpfloat: 
	cd ${cpfloat_dir} && make lib && cd ${root_dir}


clean:
	rm src/*.o
	rm src/*.so
	rm src/*.a
	rm src/*.mod

