#include "mex.h"
#include "stdio.h"


/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{


  double * p = mxGetPr(prhs[0]);
  size_t   C = mxGetM(prhs[0]);
  size_t   N = mxGetN(prhs[0]);

  //printf("%d %d \n", C, N);

  double sum_max_val = 0;
  const double __nINF = -mxGetInf();
  
  for(int n=0; n<N; n++){
    double max_val = __nINF;
    for(int c=0; c<C; c++){
      //printf("%f %f \n", max_val, p[c + n*C]);
      max_val = max_val > p[c + n*C] ? max_val : p[c + n*C];

    }
    sum_max_val = sum_max_val + max_val;
    //printf("%f ", sum_max_val);
  }

  double nom = N;

  plhs[0] = mxCreateDoubleScalar(sum_max_val/nom);

}
