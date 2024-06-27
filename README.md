# Precision, Compression, and Stochasticity (PCS)
Library aimed to enable experimentation with different floating point formats, compression, and introducing randomness/stochasticity in codes based on C++ and Fortran.

The idea is to provide a lightweight wrapper for different libraries and functionalities that modify IEEE floating point values, be it to a lower floating point precision, compression, or adding noise or other random disturbances.

# Functionality
The library revolves around the object `pcs_struct` which is initialized with the parameters one wants to modify and provides an in-place function `pcs` which carries out the transformation of the input vector.

# Compile and clone
```
git clone --recurse-submodules git@github.com:MartinKarp/pcs.git
```
Set correct compilers in makefile and for cpfloat in external/cpfloat.
```
make cpfloat
export INSTALL_LOCATION=WHEREVER
make PREFIX=${INSTALL_LOCATION}
```
default prefix is pcs/install.

After this using pcs should be a matter of adding  

```
-L${INSTALL_LOCATION}/lib -I${INSTALL_LOCATION}/include 
```
linking with

```
-lpcs_f -lpcs -lcpfloat -lpcg_random
```
and adding
```
${INSTALL_LOCATION}/lib 
```
to the LD\_LIBRARY\_PATH.
