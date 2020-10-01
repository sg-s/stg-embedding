


#include <cmath>
#include <limits>
#include "mex.h"
#include <vector>       // std::vector



void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {


    if (nrhs < 2) {
        mexErrMsgTxt("Not enough input arguments");
    }

    // define helper functions
    double distanceToClosestNonZeroBin(int, double*, int);

    plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL);
    double *D;
    D = mxGetPr(plhs[0]);
    D[0] = 0;


    double * AA = mxGetPr(prhs[0]);
    double * BB = mxGetPr(prhs[1]);

    const mwSize *NN;
    NN = mxGetDimensions(prhs[0]);
    int N = NN[0];
    if (N==1) {
        N = NN[1];
    }



    double DA = 0;
    double DB = 0;

    int NA = 0;
    int NB = 0;

    


    // find closest bin in B to each bin in A
    for (int i = 0; i < N; i ++) {
        if (AA[i] == 1) {
            DA += distanceToClosestNonZeroBin(i,BB, N);
            NA++;
        }
    }

    // mexPrintf("NA=%i\n",NA);
    // mexPrintf("DA=%f\n",DA);

    // now the same deal for B 
    for (int i = 0; i < N; i ++) {
        if (BB[i] == 1) {
            DB += distanceToClosestNonZeroBin(i,AA, N);
            NB++;
        }
    }

    // mexPrintf("DB=%f\n",DB);
    // mexPrintf("NB=%i\n",NB);

    D[0] = DA/NA + DB/NB;


}





// perform a iterative search going outwards from this bin
// and stop when we find the first non-zero bin
// this is faster than a sequential search
double distanceToClosestNonZeroBin(int this_pos, double *Y, int N) {

    double ClosestBin = N;

    // short circuit
    if (Y[this_pos] == 1) {
        ClosestBin = this_pos;
        return 0;
    }

    

    int left = 0;
    int right = 0;


    int offset = 1;

    while (true) {
        left = this_pos - offset;
        right = this_pos + offset;

        if (left < 0 & right > N) {
            break;
        }

        if (left >= 0) {
            if (Y[left] == 1) {
                ClosestBin = left;
                break;
            }
        }

        if (right <= N) {
            if (Y[right] == 1) {
                ClosestBin = right;
                break;
            }
        }

        offset++;
    }

    return abs(ClosestBin - this_pos);
}