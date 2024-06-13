#include <stdio.h>
#include "pcs.h"
//#include "cpfloat.h"
//#include "pcg.h"

#define N 10

int main () {
  // Allocate the data structure for target formats and rounding parameters.
  pcs_struct *opts = init_pcs_struct(); //Explicit allocation necessary in c

  double * test = malloc(sizeof(double)*N);
  double * testout = malloc(sizeof(double)*N);
  for (size_t i = 0; i<N; i++) {
      double j = (double)i + 1.0;
      test[i] = (j*0.2)*(j*0.2) +j*1.32;
  }
  double maxdif = 0.0;
  double maxreldif = 0.0;
  // Validate the parameters in opts.
  opts->oper = PCS_ARBITRARY_ROUND;
  opts->arbitrary_amp = 0.1;
  int retval = validate_pcs_struct(opts);
  printf("The validation function returned %d.\n", retval);
  printf("Round to arbitrary fixxed precision");
  printf("Round to closest %.15e Max dif < %.15e \n", opts->arbitrary_amp, opts->arbitrary_amp/2.0);

  retval = pcs(testout, test, N, opts);

  for (size_t i = 0; i< N; i++){
      printf("In: %.15e Out: %.15e\n", test[i], testout[i]);
      maxdif = fmax(fabs(test[i]-testout[i]),maxdif);
      maxreldif = fmax(fabs((test[i]-testout[i])/test[i]),maxreldif);
  }
  printf("Maxdif: %.15e Maxreldif: %.15e\n",maxdif, maxreldif);
  opts->oper = PCS_CPFLOAT;
  opts->fpopts->precision = 11;
  opts->fpopts->emax = 15;
  opts->fpopts->emin = -14;
  opts->fpopts->round = CPFLOAT_RND_NE;
  retval = validate_pcs_struct(opts);
  printf("The validation function returned %d.\n", retval);
  printf("Round to nearest, FP16 with CPFloat\n");
  printf("Max rel dif < %.15e \n", pow(2.0,-1.0*opts->fpopts->precision));

  retval = pcs(testout, test, N, opts);
  maxdif = 0.0;
  maxreldif = 0.0;

  for (size_t i = 0; i< N; i++){
      printf("In: %.15e Out: %.15e\n", test[i], testout[i]);
      maxdif = fmax(fabs(test[i]-testout[i]),maxdif);
      maxreldif = fmax(fabs((test[i]-testout[i])/test[i]),maxreldif);
  }
  printf("Maxdif: %.15e Maxreldif: %.15e\n",maxdif, maxreldif);
  opts->oper = PCS_CPFLOAT;
  opts->fpopts->precision = 11;
  opts->fpopts->emax = 15;
  opts->fpopts->emin = -14;
  opts->fpopts->round = CPFLOAT_RND_SP;
  retval = validate_pcs_struct(opts);
  printf("The validation function returned %d.\n", retval);
  printf("Propoprtional stochastic rounding, FP16 with CPFloat\n");
  printf("Max rel dif(for round to nearest)  < %.15e \n", pow(2.0,-1.0*opts->fpopts->precision));

  retval = pcs(testout, test, N, opts);
  maxdif = 0.0;
  maxreldif = 0.0;

  for (size_t i = 0; i< N; i++){
      printf("In: %.15e Out: %.15e\n", test[i], testout[i]);
      maxdif = fmax(fabs(test[i]-testout[i]),maxdif);
      maxreldif = fmax(fabs((test[i]-testout[i])/test[i]),maxreldif);
  }
  printf("Maxdif: %.15e Maxreldif: %.15e\n",maxdif, maxreldif);

  //Uniform noise
  opts->oper = PCS_UNIFORM_NOISE;
  opts->arbitrary_amp = 0.1;

  pcg64_srandom(4, 1);

  printf("Add uniform noise, in interval x*[1-r,1+r] r in U(-0.05,0.05)\n");
  printf("Max rel dif < %.15e \n", opts->arbitrary_amp/2.0);

  retval = pcs(testout, test, N, opts);
  maxdif = 0.0;
  maxreldif = 0.0;

  for (size_t i = 0; i< N; i++){
      printf("In: %.15e Out: %.15e\n", test[i], testout[i]);
      maxdif = fmax(fabs(test[i]-testout[i]),maxdif);
      maxreldif = fmax(fabs((test[i]-testout[i])/test[i]),maxreldif);
  }
  printf("Maxdif: %.15e Maxreldif: %.15e\n",maxdif, maxreldif);

}
