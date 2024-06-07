/* SPDX-FileCopyrightText: 2020 Massimiliano Fasi and Mantas Mikaitis */
/* SPDX-License-Identifier: LGPL-2.1-or-later                         */

#include <stdio.h>

#include "cpfloat.h"
#include "pcg_variants.h"
#include "pcs.h"

#define N 100

pcs_struct *init_pcs_struct(){
    pcs_struct *opts = malloc(sizeof(*opts));
    opts->fpopts = init_optstruct();
    opts->oper = PCS_CPFLOAT;
    return opts;
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

/*
 * CPFloat - Custom Precision Floating-point numbers.
 *
 * Copyright 2020 Massimiliano Fasi and Mantas Mikaitis
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with this library; if not, write to the Free Software Foundation, Inc., 51
 * Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */
