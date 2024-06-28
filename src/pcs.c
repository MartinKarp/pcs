#include <stdio.h>
#include "cpfloat.h"
#include "pcg_variants.h"
#include "pcs.h"


pcs_struct *init_pcs_struct(){
    pcs_struct *opts = malloc(sizeof(*opts));
    opts->fpopts = init_optstruct();
    opts->oper = PCS_CPFLOAT;
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
    int out;
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

