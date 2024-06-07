#include "cpfloat.h"
#include "pcg_variants.h"

typedef enum {
  //If operation defined by CPFloat
  PCS_CPFLOAT = 0,
  PCS_UNIFORM_NOISE = 1,
  PCS_ARBITRARY_ROUND = 2
} operation_t;


typedef struct {
    operation_t oper;
    double arbitrary_amp;
    optstruct *fpopts;
} pcs_struct;

//init
pcs_struct *init_pcs_struct();
//validate
int validate_pcs_struct(pcs_struct *opts);
//Use same interface as CPFloat
int pcs(double *X, const double *A, const size_t n_el, pcs_struct *opts);

