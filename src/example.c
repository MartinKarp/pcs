#include <stdio.h>
#include "pcs.h"
//#include "cpfloat.h"
//#include "pcg.h"

#define N 100

int main () {
  // Allocate the data structure for target formats and rounding parameters.
  pcs_struct *opts = init_pcs_struct();
  optstruct *fpopts = opts->fpopts;
  opts->oper = PCS_UNIFORM_NOISE;
  opts->arbitrary_amp = 0.5;

  // Set up the parameters for binary16 target format.
  fpopts->precision = 11;                 // Bits in the significand + 1.
  fpopts->emax = 15;                      // The maximum exponent value.
  fpopts->subnormal = CPFLOAT_SUBN_USE;   // Support for subnormals is on.
  fpopts->round = CPFLOAT_RND_TP;         // Round toward +infinity.
  fpopts->flip = CPFLOAT_SOFTERR_FP;      // Bit flips are off.
  fpopts->p = 0;                          // Bit flip probability (not used).
  fpopts->explim = CPFLOAT_EXPRANGE_TARG; // Limited exponent in target format.

  // Validate the parameters in fpopts.
  int retval = validate_pcs_struct(opts);
  printf("The validation function returned %d.\n", retval);

  // Initialize C array with arbitrary elements.
  double X[N] = { (double)5/3, M_PI, M_E, 4,5,6,7,8,9,10 };
  double Y[N] = { 1.5, 1.5, 1.5 };
  double Z[N];
  printf("X in binary64:\n  %.15e %.15e %.15e\n", X[0], X[1], X[2]);

  // Round the values of X to the binary16 format and store in Z.
  pcs(Z, X, N, opts);
  for (size_t i = 0; i< N; i++){
      printf("X: %.15e Rounded X: %.15e Reldif: %.15e absdif: %.15e \n", X[i], Z[i], (Z[i])/X[i], (Z[i]-X[i]));
  }
  free_optstruct(fpopts);
}

