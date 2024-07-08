#include <stdio.h>
#include "cpfloat.h"
#include "pcg_variants.h"
#include "pcs.h"

//Set standard arguments to single precision
pcs_struct *init_pcs_struct(){
    pcs_struct *opts = malloc(sizeof(*opts));
    opts->fpopts = init_optstruct();
    opts->oper = PCS_CPFLOAT;
    opts->fpopts->precision = 24;
    opts->fpopts->emax = 127;
    opts->fpopts->emin = -126;
    opts->fpopts->round = CPFLOAT_RND_NE;
    opts->fpopts->bitseed = NULL;
    opts->fpopts->randseedf = NULL;
    opts->fpopts->randseed= NULL;
    strcpy(opts->fpopts->format, "");
    opts->fpopts->p = 0.0;
    opts->fpopts->infinity = 0;
    opts->fpopts->flip=CPFLOAT_SOFTERR_NO;
    opts->fpopts->subnormal=CPFLOAT_SUBN_USE;
    opts->fpopts->explim = CPFLOAT_EXPRANGE_TARG;
    opts->fpopts->saturation=CPFLOAT_SAT_NO;
    return opts;
}

int free_pcs_struct(pcs_struct *opts){
   int ierr = 0;
   ierr = free_optstruct(opts->fpopts);
   free(opts);
   return ierr;
}

int validate_pcs_struct(pcs_struct *opts){
   int ierr = 0;
   if (opts->oper == PCS_CPFLOAT){
      ierr = cpfloat_validate_optstruct(opts->fpopts);
  }
    return ierr;
}



int pcs(double *X, const double *A, const size_t n_el, pcs_struct *opts){
    operation_t op = opts->oper;
    int out = 0;
    if (op == PCS_CPFLOAT){
        if (opts->fpopts->precision == 0) printf("Warning precision 0 in pcs/cpfloat \n");
        out = cpfloat(X,A,n_el,opts->fpopts);
    }
    else if (op == PCS_UNIFORM_NOISE){
        double scale = pow(2.0,-64);
        for (size_t i=0; i<n_el;i++){
            uint64_t rand = pcg64_random();
            double noise = (double)rand*scale;
            X[i] = (1 + (noise - 0.5) * opts-> arbitrary_amp)*A[i];
        } 
    }
    else if (op == PCS_ARBITRARY_ROUND){
        for (size_t i=0; i<n_el;i++){
            double val = A[i]/opts->arbitrary_amp;
            int intval = round(val);
            X[i] = ((double)intval)*opts->arbitrary_amp;
        }
    }
    else {
        printf("nononono");
        out = 1;
    }
    return out;
}

