# Precision, Compression, and Stochasticity (PCS)
Library aimed to enable experimentation with different floating point formats, compression, and introducing randomness/stochasticity in codes based on C++ and Fortran.

The idea is to provide a lightweight wrapper for different libraries and functionalities that modify IEEE floating point values, be it to a lower floating point precision, compression, or adding noise or other random disturbances.

# Functionality
The library revolves around the object `pcs_struct` which is initialized with the parameters one wants to modify and provides an in-place function `pcs` which carries out the transformation of the input vector.




