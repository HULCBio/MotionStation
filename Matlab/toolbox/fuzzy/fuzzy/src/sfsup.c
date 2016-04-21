#ifndef S_FUNCTION_NAME
# define S_FUNCTION_NAME
#endif

#ifndef S_FUNCTION_LEVEL
# define S_FUNCTION_LEVEL 2
#endif

#include "simstruc.h"

#ifndef __STDC__
# define __STDC__ 1
#endif

/*
  * Copyright 1994-2001 The MathWorks, Inc. 
 */
#ifndef __FIS__
# define __FIS__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/***********************************************************************
 Macros and definitions
 **********************************************************************/
/* Define portable printf and double */
#if defined(MATLAB_MEX_FILE)
# define PRINTF mexPrintf
# define DOUBLE real_T
#elif defined(__SIMSTRUC__)
# define PRINTF ssPrintf
# define DOUBLE real_T
#else
# define PRINTF printf
# define DOUBLE double
#endif

#ifndef ABS
# define ABS(x)   ( (x) > (0) ? (x): (-(x)) )
#endif
#ifndef MAX
# define MAX(x,y) ( (x) > (y) ? (x) : (y) )
#endif
#ifndef MIN
# define MIN(x,y) ( (x) < (y) ? (x) : (y) )
#endif
#define MF_PARA_N 4
#define STR_LEN 500
#define MF_POINT_N 101

/* debugging macros */
/*
#define PRINT(expr) printf(#expr " = %g\n", (double)expr)
#define PRINTMAT(mat,m,n) printf(#mat " = \n"); fisPrintMatrix(mat,m,n)
#define FREEMAT(mat,m) printf("Free " #mat " ...\n"); fisFreeMatrix(mat,m)
#define FREEARRAY(array) printf("Free " #array " ...\n"); free(array)
*/

#if (defined(MATLAB_MEX_FILE) && !defined(__SIMSTRUC__))
# define FREE mxFree
#else
# define FREE free
#endif

#define FREEMAT(mat,m) fisFreeMatrix(mat,m)
#define FREEARRAY(array) FREE(array)

/***********************************************************************
 Data types
 **********************************************************************/

typedef struct fis_node {
	int handle;
	int load_param;
	char name[STR_LEN];
	char type[STR_LEN];
	char andMethod[STR_LEN];
	char orMethod[STR_LEN];
	char impMethod[STR_LEN];
	char aggMethod[STR_LEN];
	char defuzzMethod[STR_LEN];
	int userDefinedAnd;
	int userDefinedOr;
	int userDefinedImp;
	int userDefinedAgg;
	int userDefinedDefuzz;
	int in_n;
	int out_n;
	int rule_n;
	int **rule_list;
	DOUBLE *rule_weight;
	int *and_or;	/* AND-OR indicator */
	DOUBLE *firing_strength;
	DOUBLE *rule_output;
	/* Sugeno: output for each rules */
	/* Mamdani: constrained output MF values of rules */
	struct io_node **input;
	struct io_node **output;
	DOUBLE (*andFcn)(DOUBLE, DOUBLE);
	DOUBLE (*orFcn)(DOUBLE, DOUBLE);
	DOUBLE (*impFcn)(DOUBLE, DOUBLE);
	DOUBLE (*aggFcn)(DOUBLE, DOUBLE);
	DOUBLE (*defuzzFcn)();
	DOUBLE *BigOutMfMatrix;	/* used for Mamdani system only */
    DOUBLE *BigWeightMatrix;/* used for Mamdani system only */
	DOUBLE *mfs_of_rule;	/* MF values in a rule */
	struct fis_node *next;
} FIS;



typedef struct io_node {
	char name[STR_LEN];
	int mf_n;
	DOUBLE bound[2];
	DOUBLE value;
	struct mf_node **mf;
} IO;



typedef struct mf_node {
	char label[STR_LEN];	/* MF name */
	char type[STR_LEN];		/* MF type */
	int nparams;			/* length of params field */
	DOUBLE *params;			/* MF parameters */
	int userDefined;		/* 1 if the MF is user-defined */
	DOUBLE (*mfFcn)(DOUBLE, DOUBLE *); /* pointer to a mem. fcn */ 
	DOUBLE value;		    /* for Sugeno only */
	DOUBLE *value_array;	/* for Mamdani only, array of MF values */
} MF;

#endif /* __FIS__ */
/***********************************************************************
 File, arrays, matrices operations 
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* display error message and exit */
static void fisError(char *msg)
{
#ifdef MATLAB_MEX_FILE
	mexErrMsgTxt(msg);
#else
	PRINTF("%s\n",msg);
    exit(1);
#endif
}

#ifndef NO_PRINTF         /*in case for rtw and dSPACE use */

/* an friendly interface to fopen() */
static FILE *fisOpenFile(char *file, char *mode)
{
	FILE *fp, *fopen();

	if ((fp = fopen(file, mode)) == NULL){
		PRINTF("The file %s cannot be opened.", file);
		fisError("\n");
	}
	return(fp);
}

#endif


/* define a standard memory access function with error checking */
void *fisCalloc(int num_of_x, int size_of_x)
{
	void *ptr;

#if (defined(MATLAB_MEX_FILE) &&  !defined(__SIMSTRUC__))
	/* datstruc.c ln325 requires ptr = NULL when it supplies num_of_x = 0 */
	if (num_of_x == 0) 
            ptr = NULL; /* mxCalloc returns a NULL pointer if num_of_x or size_of_x = 0 */
	else {
            ptr = mxCalloc(num_of_x, size_of_x);
            /* however we still need to check that memory was allocated successfully,
               exclude the case when num_of_x = 0, and if unsuccessful issue an error */
            if (ptr == NULL)
                fisError("Could not allocate memory in mxCalloc function call.");}
#else /* a Simulink file (defined(__SIMSTRUC__)), or standalone is being created */
	if (num_of_x == 0) 
            ptr = NULL; /* calloc returns a NULL pointer if num_of_x or size_of_x = 0 */
	else {
            ptr = calloc(num_of_x, size_of_x);
            /* however we still need to check that memory was allocated successfully,
               exclude the case when num_of_x = 0, and if unsuccessful issue an error */
            if (ptr == NULL)
                fisError("Could not allocate memory in calloc function call.");}
#endif

        return(ptr);
}


char **fisCreateMatrix(int row_n, int col_n, int element_size)
{
	char **matrix;
	int i;

	if (row_n == 0 && col_n == 0)
		return(NULL);
	matrix = (char **)fisCalloc(row_n, sizeof(char *));
	if (matrix == NULL)
		fisError("Calloc error in fisCreateMatrix!");
	for (i = 0; i < row_n; i++) { 
		matrix[i] = (char *)fisCalloc(col_n, element_size);
		if (matrix[i] == NULL)
			fisError("Calloc error in fisCreateMatrix!");
	}
	return(matrix);
}


/* won't complain if given matrix is already freed */
static void fisFreeMatrix(void **matrix, int row_n)
{
	int i;
	if (matrix != NULL) {
		for (i = 0; i < row_n; i++) {
			FREE(matrix[i]);
		}
		FREE(matrix);
	}
}


static DOUBLE**fisCopyMatrix(DOUBLE **source, int row_n, int col_n)
{
	DOUBLE **target;
	int i, j;

	target = (DOUBLE **)fisCreateMatrix(row_n, col_n, sizeof(DOUBLE));
	for (i = 0; i < row_n; i++)
		for (j = 0; j < col_n; j++)
			target[i][j] = source[i][j];
	return(target);
}


#ifndef NO_PRINTF        /* not available for RTW and dSPACE */

static void fisPrintMatrix(DOUBLE **matrix, int row_n, int col_n)
{
	int i, j;
	for (i = 0; i < row_n; i++) {
		for (j = 0; j < col_n; j++)
			PRINTF("%.3f ", matrix[i][j]);
		PRINTF("\n");
	}
}

static void fisPrintArray(DOUBLE *array, int size)
{
	int i;
	for (i = 0; i < size; i++)
		PRINTF("%.3f ", array[i]);
	PRINTF("\n");
}

static void
fisPause()
{
	PRINTF("Hit RETURN to continue ...\n");
	getc(stdin);
}

#endif
/***********************************************************************
 Parameterized membership functions
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* Triangular membership function */
static DOUBLE fisTriangleMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], b = params[1], c = params[2];

	if (a>b)
		fisError("Illegal parameters in fisTriangleMf() --> a > b");
	if (b>c)
		fisError("Illegal parameters in fisTriangleMf() --> b > c");

	if (a == b && b == c)
		return(x == a);
	if (a == b)
		return((c-x)/(c-b)*(b<=x)*(x<=c));
	if (b == c)
		return((x-a)/(b-a)*(a<=x)*(x<=b));
	return(MAX(MIN((x-a)/(b-a), (c-x)/(c-b)), 0));
}

/* Trapezpoidal membership function */
static DOUBLE fisTrapezoidMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], b = params[1], c = params[2], d = params[3];
	DOUBLE y1 = 0, y2 = 0;

	if (a>b) {
		PRINTF("a = %f, b = %f, c = %f, d = %f\n", a, b, c, d);
		fisError("Illegal parameters in fisTrapezoidMf() --> a > b");
	}
        if (b>c)
         {
                PRINTF("a = %f, b = %f, c = %f, d = %f\n", a, b, c, d);      
                fisError("Illegal parameters in fisTrapezoidMf() --> b > c");
         }
	if (c>d) {
		PRINTF("a = %f, b = %f, c = %f, d = %f\n", a, b, c, d);
		fisError("Illegal parameters in fisTrapezoidMf() --> c > d");
	}

	if (b <= x)
		y1 = 1;
	else if (x < a)
		y1 = 0;
	else if (a != b)
		y1 = (x-a)/(b-a);

	if (x <= c)
		y2 = 1;
	else if (d < x)
		y2 = 0;
	else if (c != d)
		y2 = (d-x)/(d-c);

	return(MIN(y1, y2));
	/*
	if (a == b && c == d)
		return((b<=x)*(x<=c));
	if (a == b)
		return(MIN(1, (d-x)/(d-c))*(b<=x)*(x<=d));
	if (c == d)
		return(MIN((x-a)/(b-a), 1)*(a<=x)*(x<=c));
	return(MAX(MIN(MIN((x-a)/(b-a), 1), (d-x)/(d-c)), 0));
	*/
}

/* Gaussian membership function */
static DOUBLE fisGaussianMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE sigma = params[0], c = params[1];
	DOUBLE tmp;

	if (sigma==0)
		fisError("Illegal parameters in fisGaussianMF() --> sigma = 0");
	tmp = (x-c)/sigma;
	return(exp(-tmp*tmp/2));
}

/* Extended Gaussian membership function */
static DOUBLE fisGaussian2Mf(DOUBLE x, DOUBLE *params)
{
	DOUBLE sigma1 = params[0], c1 = params[1];
	DOUBLE sigma2 = params[2], c2 = params[3];
	DOUBLE tmp1, tmp2;

	if ((sigma1 == 0) || (sigma2 == 0))
		fisError("Illegal parameters in fisGaussian2MF() --> sigma1 or sigma2 is zero");

	tmp1 = x >= c1? 1:exp(-pow((x-c1)/sigma1, 2.0)/2);
	tmp2 = x <= c2? 1:exp(-pow((x-c2)/sigma2, 2.0)/2);
	return(tmp1*tmp2);
}

/* Sigmoidal membership function */
static DOUBLE fisSigmoidMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], c = params[1];
	return(1/(1+exp(-a*(x-c))));
}

/* Product of two sigmoidal functions */
static DOUBLE fisProductSigmoidMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a1 = params[0], c1 = params[1], a2 = params[2], c2 = params[3];
	DOUBLE tmp1 = 1/(1+exp(-a1*(x-c1)));
	DOUBLE tmp2 = 1/(1+exp(-a2*(x-c2)));
	return(tmp1*tmp2);
}

/* Absolute difference of two sigmoidal functions */
static DOUBLE fisDifferenceSigmoidMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a1 = params[0], c1 = params[1], a2 = params[2], c2 = params[3];
	DOUBLE tmp1 = 1/(1+exp(-a1*(x-c1)));
	DOUBLE tmp2 = 1/(1+exp(-a2*(x-c2)));
	return(fabs(tmp1-tmp2));
}

/* Generalized bell membership function */
static DOUBLE fisGeneralizedBellMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], b = params[1], c = params[2];
	DOUBLE tmp;
	if (a==0)
		fisError("Illegal parameters in fisGeneralizedBellMf() --> a = 0");
	tmp = pow((x-c)/a, 2.0);
	if (tmp == 0 && b == 0)
		return(0.5);
	else if (tmp == 0 && b < 0)
		return(0.0);
	else
		return(1/(1+pow(tmp, b)));
}

/* S membership function */
static DOUBLE fisSMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], b = params[1];
	DOUBLE out;

	if (a >= b)
		return(x >= (a+b)/2);

	if (x <= a)
		out = 0;
	else if (x <= (a + b)/2)
		out = 2*pow((x-a)/(b-a), 2.0);
	else if (x <= b)
		out = 1-2*pow((b-x)/(b-a), 2.0);
	else
		out = 1;
	return(out);
}

/* Z membership function */
static DOUBLE fisZMf(DOUBLE x, DOUBLE *params)
{
	DOUBLE a = params[0], b = params[1];
	DOUBLE out;

	if (a >= b)
		return(x <= (a+b)/2);

	if (x <= a)
		out = 1;
	else if (x <= (a + b)/2)
		out = 1 - 2*pow((x-a)/(b-a), 2.0);
	else if (x <= b)
		out = 2*pow((b-x)/(b-a), 2.0);
	else
		out = 0;
	return(out);
}

/* pi membership function */
static DOUBLE fisPiMf(DOUBLE x, DOUBLE *params)
{
	return(fisSMf(x, params)*fisZMf(x, params+2));
}

/* all membership function */
static DOUBLE fisAllMf(DOUBLE x, DOUBLE *params)
{
	return(1);
}

/* returns the number of parameters of MF */
static int fisGetMfParaN(char *mfType)
{
	if (strcmp(mfType, "trimf") == 0)
		return(3);
	if (strcmp(mfType, "trapmf") == 0)
		return(4);
	if (strcmp(mfType, "gaussmf") == 0)
		return(2);
	if (strcmp(mfType, "gauss2mf") == 0)
		return(4);
	if (strcmp(mfType, "sigmf") == 0)
		return(2);
	if (strcmp(mfType, "dsigmf") == 0)
		return(4);
	if (strcmp(mfType, "psigmf") == 0)
		return(4);
	if (strcmp(mfType, "gbellmf") == 0)
		return(3);
	if (strcmp(mfType, "smf") == 0)
		return(2);
	if (strcmp(mfType, "zmf") == 0)
		return(2);
	if (strcmp(mfType, "pimf") == 0)
		return(4);
	PRINTF("Given MF type (%s) is unknown.\n", mfType);
	exit(1);
	return(0);	/* get rid of compiler warning */
}
/***********************************************************************
 T-norm and T-conorm operators
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

static DOUBLE fisMin(DOUBLE x, DOUBLE y)
{return((x) < (y) ? (x) : (y));}

static DOUBLE fisMax(DOUBLE x, DOUBLE y)
{return((x) > (y) ? (x) : (y));}

static DOUBLE fisProduct(DOUBLE x, DOUBLE y)
{return(x*y);} 

static DOUBLE fisProbOr(DOUBLE x, DOUBLE y)
{return(x + y - x*y);} 

static DOUBLE fisSum(DOUBLE x, DOUBLE y)
{return(x + y);} 

/* apply given function to an array */
static DOUBLE fisArrayOperation(DOUBLE *array, int size, DOUBLE (*fcn)())
{
	int i;
	DOUBLE out;

	if (size == 0)
		fisError("Given size is zero!");

	out = array[0];
	for (i = 1; i < size; i++)
		out = (*fcn)(out, array[i]);
	return(out);
}
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/***********************************************************************
 Defuzzification methods
 **********************************************************************/

/* return the center of area of combined output MF (specified by mf)
   of output m */
/* numofpoints is the number of partition for integration */
static DOUBLE defuzzCentroid(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1);
	DOUBLE total_mf = 0;
	DOUBLE sum = 0;
	int i;

	for (i = 0; i < numofpoints; i++){
		total_mf += mf[i];
       		sum += mf[i]*(min + step*i);
	}
	if (total_mf == 0) {
		PRINTF("Total area is zero in defuzzCentroid() for output %d.\n", m+1);
		PRINTF("Average of the range of this output variable is used as the output value.\n\n");
		return((fis->output[m]->bound[0] + fis->output[m]->bound[1])/2);
	} 
	return(sum/total_mf);
}

/* return the bisector of area of mf */
static DOUBLE defuzzBisector(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE area, sub_area;
	int i;

	/* find the total area */
	area = 0;
	for (i = 0; i < numofpoints; i++)
		area += mf[i];

	if (area == 0) {
		PRINTF("Total area is zero in defuzzBisector() for output %d.\n", m+1);
		PRINTF("Average of the range of this output variable is used as the output value.\n");
		return((fis->output[m]->bound[0] + fis->output[m]->bound[1])/2);
	} 
     
	sub_area = 0;
	for (i = 0; i < numofpoints; i++) {
		sub_area += mf[i];
		if (sub_area >= area/2)
			break;
	}
	return(min + step*i);
}

/* Returns the mean of maximizing x of mf */
static DOUBLE defuzzMeanOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	DOUBLE sum;
	int count;
	int i;

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);

	sum = 0;
	count = 0;
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			count++;
			sum += i;
		}
	return(min+step*sum/count);
}

/* Returns the smallest (in magnitude) maximizing x of mf */
static DOUBLE defuzzSmallestOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	int i, min_index = 0;
	DOUBLE min_distance = pow(2.0, 31.0)-1;
	DOUBLE distance; /* distance to the origin */

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			distance = ABS(min + step*i);
			if (min_distance > distance) {
				min_distance = distance;
				min_index = i;
			}
		}
	return(min + step*min_index);
}

/* Returns the largest (in magnitude) maximizing x of mf */
static DOUBLE defuzzLargestOfMax(FIS *fis, int m, DOUBLE *mf, int numofpoints)
{
	DOUBLE min = fis->output[m]->bound[0];
	DOUBLE max = fis->output[m]->bound[1];
	DOUBLE step = (max - min)/(numofpoints - 1); 
	DOUBLE mf_max;
	int i, max_index = 0;
	DOUBLE max_distance = -(pow(2.0, 31.0)-1);
	DOUBLE distance; /* distance to the origin */

	mf_max = fisArrayOperation(mf, numofpoints, fisMax);
	for (i = 0; i < numofpoints; i++)
		if (mf[i] == mf_max) {
			distance = ABS(min + step*i);
			if (max_distance < distance) {
				max_distance = distance;
				max_index = i;
			}
		}
	return(min + step*max_index);
}
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

#ifdef MATLAB_MEX_FILE
/***********************************************************************
 MATLAB function calls 
 **********************************************************************/

/* V4 --> v5
mxFreeMatrix --> mxDestroyArray
Matrix --> mxArray;
mxCreateFull(*, *, 0) --> mxCreateDoubleMatrix(*, *, mxREAL)
mexCallMATLAB(*, *, prhs, *) --> mexCallMATLAB(*, *, (mxArray **)prhs, *)
*/

/* execute MATLAB MF function, scalar version */
static DOUBLE fisCallMatlabMf(DOUBLE x, int nparams, DOUBLE *params, char *mf_type)
{
	int i;
	mxArray *PARA = mxCreateDoubleMatrix(nparams, 1, mxREAL);
	mxArray *X = mxCreateDoubleMatrix(1, 1, mxREAL);
	mxArray *OUT;
	DOUBLE out;
	mxArray *prhs[2];

	/* data transfer */
	for (i = 0; i < nparams; i++)
		mxGetPr(PARA)[i] = params[i];
	mxGetPr(X)[0] = x;

	prhs[0] = X; prhs[1] = PARA;
	
	/* call matlab MF function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, mf_type);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(PARA);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB MF function, vector version */
/* this is used in fisComputeOutputMfValueArray() */ 
static void fisCallMatlabMf2(DOUBLE *x, int nparams, DOUBLE *params, char *mf_type, int leng, DOUBLE *out)
{
	int i;
	mxArray *PARA = mxCreateDoubleMatrix(nparams, 1, mxREAL);
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	mxArray *prhs[2];

	/* transfer data in */
	for (i = 0; i < nparams; i++)
		mxGetPr(PARA)[i] = params[i];
	for (i = 0; i < leng; i++)
		mxGetPr(X)[i] = x[i];

	prhs[0] = X; prhs[1] = PARA;
	/* call matlab MF function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, mf_type);

	/* transfer data out */
	for (i = 0; i < leng; i++)
		out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(PARA);
	mxDestroyArray(OUT);
}


/* use MATLAB 'exist' to check the type of a variable or function */
static DOUBLE fisCallMatlabExist(char *variable)
{
	DOUBLE out;
	mxArray *VARIABLE = mxCreateString(variable);
	mxArray *OUT;

	/* call matlab 'exist' */
	mexCallMATLAB(1, &OUT, 1, &VARIABLE, "exist");
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(VARIABLE);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB function with a vector input */
/* qualified MATLAB functions are min, sum, max, etc */
static DOUBLE fisCallMatlabFcn(DOUBLE *x, int leng, char *func)
{
	DOUBLE out;
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	int i;

	/* transfer data */
	for (i = 0; i < leng; i++)
		mxGetPr(X)[i] = x[i];

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 1, &X, func);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}


/* execute MATLAB function with a matrix input */
/* qualified MATLAB functions are min, sum, max, etc */
static void fisCallMatlabFcn1(DOUBLE *x, int m, int n, char *func, DOUBLE *out)
{
	mxArray *X, *OUT;
	int i;

	/* allocate memory */
	X = mxCreateDoubleMatrix(m, n, mxREAL);

	/* transfer data in */
	for (i = 0; i < m*n; i++)
		mxGetPr(X)[i] = x[i];

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 1, &X, func);

	/* transfer data out */
	if (m == 1)
		out[0] = mxGetScalar(OUT);
	else
		for (i = 0; i < n; i++)
			out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(OUT);
}


/* execute MATLAB function with two matrix inputs */
/* qualified MATLAB functions are min, sum, max, etc */
static void fisCallMatlabFcn2(DOUBLE *x, DOUBLE *y, int m, int n, char *func, DOUBLE *out)
{
	mxArray *X, *Y, *OUT, *prhs[2];
	int i;

	/* allocate memory */
	X = mxCreateDoubleMatrix(m, n, mxREAL);
	Y = mxCreateDoubleMatrix(m, n, mxREAL);
	prhs[0] = X;
	prhs[1] = Y;

	/* transfer data in */
	for (i = 0; i < m*n; i++) {
		mxGetPr(X)[i] = x[i];
		mxGetPr(Y)[i] = y[i];
	}

	/* call matlab function */
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, func);

	/* transfer data out */
	for (i = 0; i < m*n; i++)
			out[i] = mxGetPr(OUT)[i]; 

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(Y);
	mxDestroyArray(OUT);
}


/* execute MATLAB function for defuzzification */
static DOUBLE fisCallMatlabDefuzz(DOUBLE *x, DOUBLE *mf, int leng, char *defuzz_fcn)
{
	DOUBLE out;
	mxArray *X = mxCreateDoubleMatrix(leng, 1, mxREAL);
	/* MF is used as type word in fis.h */
	/* gcc is ok with MF being used here, but cc needs a different name */
	mxArray *MF_ = mxCreateDoubleMatrix(leng, 1, mxREAL);
	mxArray *OUT;
	mxArray *prhs[2];
	int i;

	/* transfer data */
	for (i = 0; i < leng; i++) {
		mxGetPr(X)[i] = x[i];
		mxGetPr(MF_)[i] = mf[i];
	}

	/* call matlab function */
	prhs[0] = X;
	prhs[1] = MF_;
	mexCallMATLAB(1, &OUT, 2, (mxArray **)prhs, defuzz_fcn);
	out = mxGetScalar(OUT);

	/* free allocated matrix */
	mxDestroyArray(X);
	mxDestroyArray(MF_);
	mxDestroyArray(OUT);

	/* return output */
	return(out);
}
#else

# define fisCallMatlabMf(x,nparams,params,mf_type)               /* do nothing */
# define fisCallMatlabMf2(x,nparams,params, mf_type, leng, out) /* do nothing */
# define fisCallMatlabExist(variable)                  /* do nothing */
# define fisCallMatlabFcn(x, leng, func)               /* do nothing */
# define fisCallMatlabFcn1(x, m, n, func, out)         /* do nothing */
# define fisCallMatlabFcn2(x, y, m, n, func, out)      /* do nothing */
# define fisCallMatlabDefuzz(x, mf, leng, defuzz_fcn)  /* do nothing */

#endif /* MATLAB_MEX_FILE */
/***********************************************************************
 Data structure: construction, printing, and destruction 
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

IO *fisBuildIoList(int node_n, int *mf_n)
{
	IO *io_list;
	int i, j;

	io_list = (IO *)fisCalloc(node_n, sizeof(IO));
	for (i = 0; i < node_n; i++) {
		io_list[i].mf_n = mf_n[i];
		io_list[i].mf = (MF **)fisCalloc(mf_n[i], sizeof(MF *));
		if (mf_n[i] > 0)	/* check if no MF at all */
			io_list[i].mf[0] = (MF *)fisCalloc(mf_n[i], sizeof(MF));
		for (j = 0; j < mf_n[i]; j++)
			io_list[i].mf[j] = io_list[i].mf[0] + j;
	}
	return(io_list);
}

/* Assign a MF pointer to each MF node based on the MF node's type */
void fisAssignMfPointer(FIS *fis)
{
	int i, j, k, mfTypeN = 13, found;
	MF *mf_node;
	struct command {
		char *mfType;
        DOUBLE (*mfFcn)(DOUBLE, DOUBLE *);
	} dispatch[] = {
		{ "trimf",	fisTriangleMf },
		{ "trapmf",	fisTrapezoidMf },
		{ "gaussmf",	fisGaussianMf },
		{ "gauss2mf",	fisGaussian2Mf },
		{ "sigmf",	fisSigmoidMf },
		{ "dsigmf",	fisDifferenceSigmoidMf },
		{ "psigmf",	fisProductSigmoidMf },
		{ "gbellmf",	fisGeneralizedBellMf },
		{ "smf",	fisSMf },
		{ "zmf",	fisZMf },
		{ "pimf",	fisPiMf },
		{ "linear",	NULL },
		{ "constant",	NULL }
	};

	/* input MF's */
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			mf_node = fis->input[i]->mf[j];
			found = 0;
			for (k = 0; k < mfTypeN-2; k++) {
				if (strcmp(mf_node->type, dispatch[k].mfType) == 0) {
					mf_node->mfFcn = dispatch[k].mfFcn;
					found = 1;
					break;
				}
			}
			if (found == 0) {
#ifdef MATLAB_MEX_FILE
			{
				DOUBLE function_type;
				function_type = fisCallMatlabExist(mf_node->type);
				if (function_type == 0) {
					PRINTF("MF '%s' does not exist!\n", mf_node->type);
					fisError("Exiting ...");
				}
				if (function_type == 1) {
					PRINTF("MF '%s' is a MATLAB variable!\n", mf_node->type);
					fisError("Exiting ...");
				}
				mf_node->userDefined = 1;
			}
#else
				PRINTF("MF type '%s' for input %d is unknown.\n",
					mf_node->type, i+1);
				PRINTF("Legal input MF types: ");
				for (i = 0; i < mfTypeN-2; i++)
					PRINTF("%s ", dispatch[i].mfType);
				fisError("\n");
#endif
			}
		}

	/* output MF's */
	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			found = 0;
			for (k = 0; k < mfTypeN; k++) {
				if (strcmp(mf_node->type, dispatch[k].mfType) == 0) {
					mf_node->mfFcn = dispatch[k].mfFcn;
					found = 1;
					break;
				}
			}
			if (found == 0) {
#ifdef MATLAB_MEX_FILE
			{
				DOUBLE function_type;
				function_type = fisCallMatlabExist(mf_node->type);
				if (function_type == 0) {
					PRINTF("MATLAB function '%s' does not exist!\n", mf_node->type);
					fisError("Exiting ...");
				}
				if (function_type == 1) {
					PRINTF("'%s' is a MATLAB variable!\n", mf_node->type);
					fisError("Exiting ...");
				}
				mf_node->userDefined = 1;
			}
#else
				PRINTF("MF type '%s' for output %d is unknown.\n",
					mf_node->type, i+1);
				PRINTF("Legal output MF types: ");
				for (i = 0; i < mfTypeN-1; i++)
					PRINTF("%s ", dispatch[i].mfType);
				fisError("\n");
#endif
			}
		}
}

/* Assign a other function pointers */
void fisAssignFunctionPointer(FIS *fis)
{
	/* assign andMethod function pointer */
	if (strcmp(fis->andMethod, "prod") == 0)
		fis->andFcn = fisProduct;
	else if (strcmp(fis->andMethod, "min") == 0)
		fis->andFcn = fisMin;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->andMethod);
		if (function_type == 0) {
			PRINTF("AND function '%s' does not exist!\n", fis->andMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("AND function '%s' is a MATLAB variable!\n", fis->andMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedAnd = 1;
	}
#else
		PRINTF("Given andMethod %s is unknown.\n", fis->andMethod);
		fisError("Legal andMethod: min, prod");
#endif
	}

	/* assign orMethod function pointer */
	if (strcmp(fis->orMethod, "probor") == 0)
		fis->orFcn = fisProbOr;
	else if (strcmp(fis->orMethod, "max") == 0)
		fis->orFcn = fisMax;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->orMethod);
		if (function_type == 0) {
			PRINTF("OR function '%s' does not exist!\n", fis->orMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("OR function '%s' is a MATLAB variable!\n", fis->orMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedOr = 1;
	}
#else
		PRINTF("Given orMethod %s is unknown.\n", fis->orMethod);
		fisError("Legal orMethod: max, probor");
#endif
	}

	/* assign impMethod function pointer */
	if (strcmp(fis->impMethod, "prod") == 0)
		fis->impFcn = fisProduct;
	else if (strcmp(fis->impMethod, "min") == 0)
		fis->impFcn = fisMin;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->impMethod);
		if (function_type == 0) {
			PRINTF("IMPLICATION function '%s' does not exist!\n", fis->impMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("IMPLICATION function '%s' is a MATLAB variable!\n", fis->impMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedImp = 1;
	}
#else
		PRINTF("Given impMethod %s is unknown.\n", fis->impMethod);
		fisError("Legal impMethod: min, prod");
#endif
	}

	/* assign aggMethod function pointer */
	if (strcmp(fis->aggMethod, "max") == 0)
		fis->aggFcn = fisMax;
	else if (strcmp(fis->aggMethod, "probor") == 0)
		fis->aggFcn = fisProbOr;
	else if (strcmp(fis->aggMethod, "sum") == 0)
		fis->aggFcn = fisSum;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->aggMethod);
		if (function_type == 0) {
			PRINTF("AGGREGATE function '%s' does not exist!\n", fis->aggMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("AGGREGATE function '%s' is a MATLAB variable!\n", fis->aggMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedAgg = 1;
	}
#else
		PRINTF("Given aggMethod %s is unknown.\n", fis->aggMethod);
		fisError("Legal aggMethod: max, probor, sum");
#endif
	}

	/* assign defuzzification function pointer */
	if (strcmp(fis->defuzzMethod, "centroid") == 0)
		fis->defuzzFcn = defuzzCentroid;
	else if (strcmp(fis->defuzzMethod, "bisector") == 0)
		fis->defuzzFcn = defuzzBisector;
	else if (strcmp(fis->defuzzMethod, "mom") == 0)
		fis->defuzzFcn = defuzzMeanOfMax;
	else if (strcmp(fis->defuzzMethod, "som") == 0)
		fis->defuzzFcn = defuzzSmallestOfMax;
	else if (strcmp(fis->defuzzMethod, "lom") == 0)
		fis->defuzzFcn = defuzzLargestOfMax;
	else if (strcmp(fis->defuzzMethod, "wtaver") == 0)
		;
	else if (strcmp(fis->defuzzMethod, "wtsum") == 0)
		;
	else {
#ifdef MATLAB_MEX_FILE
	{
		DOUBLE function_type;
		function_type = fisCallMatlabExist(fis->defuzzMethod);
		if (function_type == 0) {
			PRINTF("DEFUZZIFICATION function '%s' does not exist!\n", fis->defuzzMethod);
			fisError("Exiting ...");
		}
		if (function_type == 1) {
			PRINTF("DEFUZZIFICATION function '%s' is a MATLAB variable!\n", fis->defuzzMethod);
			fisError("Exiting ...");
		}
		fis->userDefinedDefuzz = 1;
	}
#else
		PRINTF("Given defuzzification method %s is unknown.\n", fis->defuzzMethod);
		fisError("Legal defuzzification methods: centroid, bisector, mom, som, lom, wtaver, wtsum");
#endif
	}
}

#ifndef NO_PRINTF
static void fisPrintData(FIS *fis)
{
	int i, j, k;

	if (fis == NULL)
		fisError("Given fis pointer is NULL, no data to print!");

	PRINTF("fis_name = %s\n", fis->name);
	PRINTF("fis_type = %s\n", fis->type);
	PRINTF("in_n = %d\n", fis->in_n);
	PRINTF("out_n = %d\n", fis->out_n);

	PRINTF("in_mf_n: ");
	for (i = 0; i < fis->in_n; i++)
		PRINTF("%d ", fis->input[i]->mf_n);
	PRINTF("\n");

	PRINTF("out_mf_n: ");
	for (i = 0; i < fis->out_n; i++)
		PRINTF("%d ", fis->output[i]->mf_n);
	PRINTF("\n");

	PRINTF("rule_n = %d\n", fis->rule_n);

	PRINTF("andMethod = %s\n", fis->andMethod);
	PRINTF("orMethod = %s\n", fis->orMethod);
	PRINTF("impMethod = %s\n", fis->impMethod);
	PRINTF("aggMethod = %s\n", fis->aggMethod);
	PRINTF("defuzzMethod = %s\n", fis->defuzzMethod);

	/*
	for (i = 0; i < fis->in_n; i++) {
		printf("Input variable %d = %s\n", i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++)
			printf("\t Label for MF %d = %s\n", j+1, fis->input[i]->mf[j]->label);
	}

	for (i = 0; i < fis->out_n; i++) {
		printf("Output variable %d = %s\n", i+1, fis->output[i]->name);
		for (j = 0; j < fis->output[i]->mf_n; j++)
			printf("\t Label for MF %d = %s\n", j+1, fis->output[i]->mf[j]->label);
	}
	*/

	for (i = 0; i < fis->in_n; i++)
		PRINTF("Bounds for input variable %d: [%6.3f %6.3f]\n", i+1,
			fis->input[i]->bound[0], fis->input[i]->bound[1]);

	for (i = 0; i < fis->out_n; i++)
		PRINTF("Bounds for output variable %d: [%6.3f %6.3f]\n", i+1,
			fis->output[i]->bound[0], fis->output[i]->bound[1]);

	for (i = 0; i < fis->in_n; i++) {
		PRINTF("MF for input variable %d (%s):\n", i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++)
			PRINTF("\t Type for MF %d = %s\n", j+1, fis->input[i]->mf[j]->type);
	}

	for (i = 0; i < fis->out_n; i++) {
		PRINTF("MF for output variable %d (%s):\n", i+1, fis->output[i]->name);
		for (j = 0; j < fis->output[i]->mf_n; j++)
			PRINTF("\t Type for MF %d = %s\n", j+1, fis->output[i]->mf[j]->type);
	}

	PRINTF("Rule list:\n");
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			PRINTF("%d ", fis->rule_list[i][j]);
		PRINTF("\n");
	}

	PRINTF("Rule weights:\n");
	for (i = 0; i < fis->rule_n; i++)
		PRINTF("%f\n", fis->rule_weight[i]);

	PRINTF("AND-OR indicator:\n");
	for (i = 0; i < fis->rule_n; i++)
		PRINTF("%d\n", fis->and_or[i]);

	for (i = 0; i < fis->in_n; i++) {
		PRINTF("MF parameters for input variable %d (%s):\n",
			i+1, fis->input[i]->name);
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			PRINTF("\tParameters for MF %d (%s) (%s): ",
				j+1, fis->input[i]->mf[j]->label,
				fis->input[i]->mf[j]->type);
			for (k = 0; k < fis->input[i]->mf[j]->nparams; k++)
				PRINTF("%6.3f ", fis->input[i]->mf[j]->params[k]);
			PRINTF("\n");
		}
	}

	for (i = 0; i < fis->out_n; i++) {
		PRINTF("MF parameters for output variable %d (%s):\n",
				i+1, fis->output[i]->name);
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				PRINTF("\tParameters for MF %d (%s) (%s): ",
					j+1, fis->output[i]->mf[j]->label,
					fis->output[i]->mf[j]->type);
				for (k = 0; k < fis->output[i]->mf[j]->nparams; k++)
					PRINTF("%6.3f ", fis->output[i]->mf[j]->params[k]);
				PRINTF("\n");
			}
	}
}
#endif


static void fisFreeMfList(MF *mf_list, int n)
{
	int i;

	for (i = 0; i < n; i++) {
		FREE(mf_list[i].params);
		FREE(mf_list[i].value_array);
	}
	FREE(mf_list);
}


static void fisFreeIoList(IO *io_list, int n)
{
	int i;
	for (i = 0; i < n; i++) {
		if (io_list[i].mf_n > 0)	/* check if no MF at all */
			fisFreeMfList(io_list[i].mf[0], io_list[i].mf_n);
		FREE(io_list[i].mf);
	}
	FREE(io_list);
}

void fisFreeFisNode(FIS *fis)
{
	if (fis == NULL)
		return;
	fisFreeIoList(fis->input[0], fis->in_n);
	FREE(fis->input);
	fisFreeIoList(fis->output[0], fis->out_n);
	FREE(fis->output);
#ifdef FREEMAT
	FREEMAT((void **)fis->rule_list, fis->rule_n);
#else
	fisFreeMatrix((void **)fis->rule_list, fis->rule_n);
#endif
	FREE(fis->rule_weight);
	FREE(fis->and_or);
	FREE(fis->firing_strength);
	FREE(fis->rule_output);
	FREE(fis->BigOutMfMatrix);
	FREE(fis->BigWeightMatrix);
	FREE(fis->mfs_of_rule);
	FREE(fis);
}

/* Compute arrays of MF values (for Mamdani model only) */
/* This is done whenever new parameters are loaded */
void fisComputeOutputMfValueArray(FIS *fis, int numofpoints)
{
	int i, j, k;
	DOUBLE x, lx, ux, dx;
	MF *mf_node;
	for (i = 0; i < fis->out_n; i++) {
		lx = fis->output[i]->bound[0];
		ux = fis->output[i]->bound[1];
		dx = (ux - lx)/(numofpoints - 1);
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			if (!mf_node->userDefined)
				for (k = 0; k < numofpoints; k++) {
					x = lx + k*dx;
					mf_node->value_array[k] =
					(*mf_node->mfFcn)(x, mf_node->params);
				}
			else { 	/* user defined MF */
#ifdef MATLAB_MEX_FILE
				/* this is vector version */
				{
					DOUBLE *X;
					X = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
					/*	double X[numofpoints]; */
					for (k = 0; k < numofpoints; k++)
						X[k] = lx + k*dx;
					fisCallMatlabMf2(X, mf_node->nparams, mf_node->params, 
						mf_node->type, numofpoints, mf_node->value_array);
					FREE(X);
				}
#else
				PRINTF("Cannot find MF type %s!\n", mf_node->type);
				fisError("Exiting ...");
#endif
			}
		}
	}
}

/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* copy string (the first 'length' characters) from array to target string */
static void fisGetString2(char *target, DOUBLE *array, int max_leng)
{
	int i;
	int actual_leng;

	/* Find the actual length of the string */
	/* If the string is not ended with 0, take max_leng */
	for (actual_leng = 0; actual_leng < max_leng; actual_leng++)
		if (array[actual_leng] == 0)
			break;

	if (actual_leng + 1 > STR_LEN) {
		PRINTF("actual_leng = %d\n", actual_leng);
		PRINTF("STR_LEN = %d\n", STR_LEN);
		fisError("String too long!");
	}
	for (i = 0; i < actual_leng; i++)
		target[i] = (char)array[i];
	target[actual_leng] = 0;
}

/* Check if there are abnormal situations is the FIS data structure */
/* Things being checked:
	1. MF indices out of bound.
	2. Rules with no premise part.
	3. Sugeno system with negated consequent.
	4. Sugeno system with zero consequent.
*/
void fisCheckDataStructure(FIS *fis)
{
	int i, j, mf_index;
	int found;

	/* check if MF indices are out of bound */
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n; j++) {
			mf_index = fis->rule_list[i][j];
			if (ABS(mf_index) > fis->input[j]->mf_n) {
				PRINTF("MF index for input %d in rule %d is out of bound.\n", 
					j+1, i+1);
				fisFreeFisNode(fis);
				fisError("Exiting ...");
			}
		}
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (ABS(mf_index) > fis->output[j]->mf_n) {
				PRINTF("MF index for output %d in rule %d is out of bound.\n", 
					j+1, i+1);
				fisFreeFisNode(fis);
				fisError("Exiting ...");
			}
		}
	}
	/* check if there is a rule whose premise MF indice are all zeros */ 
	for (i = 0; i < fis->rule_n; i++) {
		found = 1;
		for (j = 0; j < fis->in_n; j++) {
			mf_index = fis->rule_list[i][j];
			if (mf_index != 0) {
				found = 0;
				break;
			}
		}
		if (found == 1) {
			PRINTF("Rule %d has no premise part.\n", i+1);
			fisFreeFisNode(fis);
			fisError("Exiting ...");
		}
	}
	/* check if it's sugeno system with "NOT" consequent */
	if (strcmp(fis->type, "sugeno") == 0)
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (mf_index < 0) {
				PRINTF("Rule %d has a 'NOT' consequent.\n", i+1);
				PRINTF("Sugeno fuzzy inference system does not allow this.\n");
				fisError("Exiting ...");
			}
		}
	/* check if it's sugeno system with zero consequent */
	if (strcmp(fis->type, "sugeno") == 0)
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < fis->out_n; j++) {
			mf_index = fis->rule_list[i][fis->in_n+j];
			if (mf_index == 0) {
				PRINTF("Warning: Output %d in rule %d has a zero MF index.\n", j+1, i+1);
				PRINTF("This output in the rule is assumed zero in subsequent calculation.\n\n");
			}
		}
}

/* Build FIS node and load parameter from fismatrix directly */
/* col_n is the number of columns of the fismatrix */
static void fisBuildFisNode(FIS *fis, DOUBLE **fismatrix, int col_n, int numofpoints)
{
	int i, j, k;
	int *in_mf_n, *out_mf_n;
	IO *io_list;
	int start;

	fisGetString2(fis->name, fismatrix[0], col_n);
	fisGetString2(fis->type, fismatrix[1], col_n);
	fis->in_n  = (int) fismatrix[2][0];
	fis->out_n = (int) fismatrix[2][1];

	/* create input node list */
	in_mf_n = (int *)fisCalloc(fis->in_n, sizeof(int));
	for (i = 0; i < fis->in_n; i++)
		in_mf_n[i] = (int) fismatrix[3][i];
	io_list = fisBuildIoList(fis->in_n, in_mf_n);
	FREE(in_mf_n);
	fis->input = (IO **)fisCalloc(fis->in_n, sizeof(IO *));
	for (i = 0; i < fis->in_n; i++)
		fis->input[i] = io_list+i;

	/* create output node list */
	out_mf_n = (int *)fisCalloc(fis->out_n, sizeof(int));
	for (i = 0; i < fis->out_n; i++)
		out_mf_n[i] = (int) fismatrix[4][i];
	io_list = fisBuildIoList(fis->out_n, out_mf_n);
	FREE(out_mf_n);
	fis->output = (IO **)fisCalloc(fis->out_n, sizeof(IO *));
	for (i = 0; i < fis->out_n; i++)
		fis->output[i] = io_list+i;

	fis->rule_n = (int) fismatrix[5][0];

	fisGetString2(fis->andMethod, fismatrix[6], col_n);
	fisGetString2(fis->orMethod, fismatrix[7], col_n);
	fisGetString2(fis->impMethod, fismatrix[8], col_n);
	fisGetString2(fis->aggMethod, fismatrix[9], col_n);
	fisGetString2(fis->defuzzMethod, fismatrix[10], col_n);

	start = 11;
	/* For efficiency, I/O names and MF labels are not stored */
	for (i = 0; i < fis->in_n; i++) {
		fis->input[i]->name[0] = '\0';
		for (j = 0; j < fis->input[i]->mf_n; j++)
			fis->input[i]->mf[j]->label[0] = '\0';
	}
	for (i = 0; i < fis->out_n; i++) {
		fis->output[i]->name[0] = '\0';
		for (j = 0; j < fis->output[i]->mf_n; j++)
			fis->output[i]->mf[j]->label[0] = '\0';
	}

	start = start + fis->in_n + fis->out_n;
	for (i = start; i < start + fis->in_n; i++) {
		fis->input[i-start]->bound[0] = fismatrix[i][0];
		fis->input[i-start]->bound[1] = fismatrix[i][1];
	}

	start = start + fis->in_n;
	for (i = start; i < start + fis->out_n; i++) {
		fis->output[i-start]->bound[0] = fismatrix[i][0];
		fis->output[i-start]->bound[1] = fismatrix[i][1];
	}

	/* update "start" to skip reading of MF labels */
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);

	start = start + fis->out_n;
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fisGetString2(fis->input[i]->mf[j]->type, fismatrix[start], col_n);
			start++;
		}

	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			fisGetString2(fis->output[i]->mf[j]->type, fismatrix[start], col_n);
			start++;
		}

	fisAssignMfPointer(fis);
	fisAssignFunctionPointer(fis);

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++) {
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fis->input[i]->mf[j]->nparams = MF_PARA_N;
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < MF_PARA_N; k++)
				fis->input[i]->mf[j]->params[k] = fismatrix[start][k];
			start++;
		}
	}

	/* get Mamdani output MF parameters and compute MF value array */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->value_array =
					(DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
				fis->output[i]->mf[j]->nparams = MF_PARA_N;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < MF_PARA_N; k++)
					fis->output[i]->mf[j]->params[k] = fismatrix[start][k];
				start++;
			}
		fisComputeOutputMfValueArray(fis, numofpoints);
	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] = fismatrix[start][k];
				start++;
			}
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}

	fis->rule_list = (int **)fisCreateMatrix
		(fis->rule_n, fis->in_n + fis->out_n, sizeof(int));
	fis->rule_weight = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->and_or = (int *)fisCalloc(fis->rule_n, sizeof(int));
	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			fis->rule_list[i][j] = (int)fismatrix[start][j];
		fis->rule_weight[i] = fismatrix[start][fis->in_n+fis->out_n];
		fis->and_or[i] = (int)fismatrix[start][fis->in_n+fis->out_n+1];
		start++;
	}

	fis->firing_strength = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->rule_output = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	if (strcmp(fis->type, "mamdani") == 0) {
		fis->BigOutMfMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
		fis->BigWeightMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
	}
	fis->mfs_of_rule = (DOUBLE *)fisCalloc(fis->in_n, sizeof(DOUBLE));
	fisCheckDataStructure(fis);
}


/* load parameters and rule list from given fismatrix */
static void fisLoadParameter(FIS *fis, DOUBLE **fismatrix, int numofpoints)
{
	int start;
	int i, j, k;

	start = 11 + 2*(fis->in_n + fis->out_n);
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);
	for (i = 0; i < fis->in_n; start += fis->input[i]->mf_n, i++);
	for (i = 0; i < fis->out_n; start += fis->output[i]->mf_n, i++);

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++) {
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			fis->input[i]->mf[j]->nparams = MF_PARA_N;
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < MF_PARA_N; k++)
				fis->input[i]->mf[j]->params[k] = fismatrix[start][k];
			start++;
		}
	}

	/* get Mamdani output MF parameters */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = MF_PARA_N;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < MF_PARA_N; k++)
					fis->output[i]->mf[j]->params[k] =
						fismatrix[start][k];
				start++;
			}
		fisComputeOutputMfValueArray(fis, numofpoints);

	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] =
						fismatrix[start][k];
				start++;
			}
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}

	for (i = 0; i < fis->rule_n; i++) {
		for (j = 0; j < fis->in_n + fis->out_n; j++)
			fis->rule_list[i][j] = (int)fismatrix[start][j];
		fis->rule_weight[i] = fismatrix[start][fis->in_n+fis->out_n];
		fis->and_or[i] = (int)fismatrix[start][fis->in_n+fis->out_n+1];
		start++;
	}
}

/* load parameters contain in the given parameter array */
/* (Note that the array is compact, no zero padding */
static void fisLoadParameter1(FIS *fis, DOUBLE *para_array, int numofpoints)
{
	int start = 0;
	int paraN;
	int i, j, k;

	/* get input MF parameters */
	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			paraN = fisGetMfParaN(fis->input[i]->mf[j]->type);
			fis->input[i]->mf[j]->nparams = paraN;
			fis->input[i]->mf[j]->params = 
				(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
			for (k = 0; k < paraN; k++)
				fis->input[i]->mf[j]->params[k] = para_array[start++];
		}

	/* get Mamdani output MF parameters */
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++) {
				paraN = fisGetMfParaN(fis->input[i]->mf[j]->type);
				fis->output[i]->mf[j]->nparams = paraN;
				fis->output[i]->mf[j]->params = 
					(DOUBLE *)fisCalloc(MF_PARA_N,sizeof(DOUBLE));
				for (k = 0; k < paraN; k++)
					fis->output[i]->mf[j]->params[k] = para_array[start++];
			}
		fisComputeOutputMfValueArray(fis, numofpoints);
	/* get Sugeno output equation parameters */
	} else if (strcmp(fis->type, "sugeno") == 0) {
		for (i = 0; i < fis->out_n; i++)
			for (j = 0; j < fis->output[i]->mf_n; j++)
				fis->output[i]->mf[j]->nparams = fis->in_n+1;
				fis->output[i]->mf[j]->params =
					(DOUBLE *)fisCalloc(fis->in_n+1, sizeof(DOUBLE));
				for (k = 0; k < fis->in_n+1; k++)
					fis->output[i]->mf[j]->params[k] =
						para_array[start++];
	} else {
		PRINTF("fis->type = %s\n", fis->type);
		fisError("Unknown fis type!");
	}
}

/* Returns a FIS pointer if there is a match; otherwise signals error */
static FIS *fisMatchHandle(FIS *head, int handle)
{
	FIS *p;

	for (p = head; p != NULL; p = p->next)
		if (p->handle == handle)
			break;
	if (p == NULL) {
		PRINTF("Given handle is %d.\n", handle);
		fisError("Cannot find an FIS with this handle.");
	}
	return(p);
}

/* Returns the FIS handle that matches a given name */
/* If more than two are qualified, the largest handle is returned.  */
static FIS *fisMatchName(FIS *head, char *name)
{
	FIS *p, *matched_p = NULL;

	for (p = head; p != NULL; p = p->next)
		if (strcmp(p->name, name) == 0)
			matched_p = p;
	return(matched_p);
}

static int fisFindMaxHandle(FIS *head)
{
	FIS *p;
	int max_handle = 0;

	if (head == NULL)
		return(0);

	for (p = head; p != NULL; p = p->next)
		if (p->handle > max_handle)
			max_handle = p->handle;
	return(max_handle);
}
/***********************************************************************
 Main functions for fuzzy inference 
 **********************************************************************/
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: $  $Date: $  */

/* Compute MF values for all input variables */
static void fisComputeInputMfValue(FIS *fis)
{
	int i, j;
	MF *mf_node;

	for (i = 0; i < fis->in_n; i++)
		for (j = 0; j < fis->input[i]->mf_n; j++) {
			mf_node = fis->input[i]->mf[j];
			if (!mf_node->userDefined)
				mf_node->value = (*mf_node->mfFcn)
					(fis->input[i]->value, mf_node->params);
			else {
#ifdef MATLAB_MEX_FILE
				mf_node->value =
					fisCallMatlabMf(fis->input[i]->value, mf_node->nparams, mf_node->params, mf_node->type);
#else
				PRINTF("Given MF %s is unknown.\n", mf_node->label);
				fisError("Exiting ...");
#endif
			}
		}
}

/* Compute rule output (for Sugeno model only) */
static void fisComputeTskRuleOutput(FIS *fis)
{
	int i, j, k;
	DOUBLE out;
	MF *mf_node;

	for (i = 0; i < fis->out_n; i++)
		for (j = 0; j < fis->output[i]->mf_n; j++) {
			mf_node = fis->output[i]->mf[j];
			out = 0;
			for (k = 0; k < fis->in_n; k++)
				out += (fis->input[k]->value)*(mf_node->params[k]);
			out = out + mf_node->params[fis->in_n];
			mf_node->value = out;
		}
}


/* Compute firing strengths */
static void fisComputeFiringStrength(FIS *fis)
{
	DOUBLE out = 0, mf_value;
	int i, j, which_mf;

	/* Compute original firing strengths via andFcn or orFcn */
	for (i = 0; i < fis->rule_n; i++) {
		if (fis->and_or[i] == 1) {	/* AND premise */
			for (j = 0; j < fis->in_n; j++) {
				which_mf = fis->rule_list[i][j];
				if (which_mf > 0)
					mf_value =fis->input[j]->mf[which_mf-1]->value;
				else if (which_mf == 0) /* Don't care */
					mf_value = 1;
				else		/* Linguistic hedge NOT */
					mf_value = 1 - fis->input[j]->mf[-which_mf-1]->value;
				fis->mfs_of_rule[j] = mf_value;
			}
			if (!fis->userDefinedAnd)
				out = fisArrayOperation(
					fis->mfs_of_rule, fis->in_n, fis->andFcn);
			else {
#ifdef MATLAB_MEX_FILE
				out = fisCallMatlabFcn(
					fis->mfs_of_rule, fis->in_n, fis->andMethod);
#else
				PRINTF("Given AND method %s is unknown.\n", fis->andMethod);
				fisError("Exiting ...");
#endif
			}
		} else {			/* OR premise */
			for (j = 0; j < fis->in_n; j++) {
				which_mf = fis->rule_list[i][j];
				if (which_mf > 0)
					mf_value =fis->input[j]->mf[which_mf-1]->value;
				else if (which_mf == 0) /* Don't care */
					mf_value = 0;
				else		/* Linguistic hedge NOT */
					mf_value = 1 - fis->input[j]->mf[-which_mf-1]->value;
				fis->mfs_of_rule[j] = mf_value;
			}
			if (!fis->userDefinedOr)
				out = fisArrayOperation(
					fis->mfs_of_rule, fis->in_n, fis->orFcn);
			else {
#ifdef MATLAB_MEX_FILE
				out = fisCallMatlabFcn(
					fis->mfs_of_rule, fis->in_n, fis->orMethod);
#else
				PRINTF("Given OR method %s is unknown.\n", fis->orMethod);
				fisError("Exiting ...");
#endif
			}
		}
		fis->firing_strength[i] = out;
	}

	/* Scale the original firing strength by rule_weight */
	for (i = 0; i < fis->rule_n; i++)
		fis->firing_strength[i] = 
			fis->rule_weight[i]*fis->firing_strength[i];
}

#ifdef MATLAB_MEX_FILE
/* Returns the n-th value of combined m-th output MF. */
/* (n is the index into the MF value arrays of the m-th output.) */
/* Both m and n are zero-offset */
/* (for Mamdani's model only */
/* This is used in mexFunction() of evalfis.c only */
static DOUBLE fisFinalOutputMf(FIS *fis, int m, int n)
{
	int i, which_mf;
	DOUBLE mf_value, out;

	/* The following should not be based on t-conorm */
	for (i = 0; i < fis->rule_n; i++) {
		/* rule_list is 1-offset */
		which_mf = fis->rule_list[i][fis->in_n+m];
		if (which_mf > 0)
			mf_value = fis->output[m]->mf[which_mf-1]->value_array[n];
		else if (which_mf == 0)	/* Don't care */
			mf_value = 0;
		else
			mf_value = 1-fis->output[m]->mf[-which_mf-1]->value_array[n];
		if (!fis->userDefinedImp)
			fis->rule_output[i] = (*fis->impFcn)(mf_value,
				fis->firing_strength[i]);
		else {
			DOUBLE tmp[2];
			tmp[0] = mf_value;
			tmp[1] = fis->firing_strength[i];
			fis->rule_output[i] = fisCallMatlabFcn(tmp, 2, fis->impMethod);
		}
	}
	if (!fis->userDefinedAgg)
		out = fisArrayOperation(fis->rule_output, fis->rule_n, fis->aggFcn);
	else
		out = fisCallMatlabFcn(fis->rule_output, fis->rule_n, fis->aggMethod);
	return(out);
}
#endif


/* Returns the aggregated MF aggMF of the m-th output variable . */
/* (for Mamdani's model only */
static void fisFinalOutputMf2(FIS *fis, int m, DOUBLE *aggMF, int numofpoints)
{
	int i, j, which_mf;

	/* fill in BigOutMfMatrix */
	/* The following should not be based on t-conorm */
	for (i = 0; i < fis->rule_n; i++) {
		which_mf = fis->rule_list[i][fis->in_n+m];
		if (which_mf > 0)
			for (j = 0; j < numofpoints; j++)
				/*
				fis->BigOutMfMatrix[i][j] = 
					fis->output[m]->mf[which_mf-1]->value_array[j];
				*/
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 
					fis->output[m]->mf[which_mf-1]->value_array[j];
		else if (which_mf < 0)
			for (j = 0; j < numofpoints; j++)
				/*
				fis->BigOutMfMatrix[i][j] = 
					1-fis->output[m]->mf[-which_mf-1]->value_array[j];
				*/
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 
					1 - fis->output[m]->mf[-which_mf-1]->value_array[j];
		else	/* which_mf == 0 */
			for (j = 0; j < numofpoints; j++)
				fis->BigOutMfMatrix[j*fis->rule_n+i] = 0; 
	}

	/* fill in BigWeightMatrix */
	for (i = 0; i < fis->rule_n; i++)
		for (j = 0; j < numofpoints; j++)
				fis->BigWeightMatrix[j*fis->rule_n+i] = 
					fis->firing_strength[i];

	/* apply implication operator */
	if (!fis->userDefinedImp)
		for (i = 0; i < (fis->rule_n)*numofpoints; i++)
			fis->BigOutMfMatrix[i] = (*fis->impFcn)(
				fis->BigWeightMatrix[i], fis->BigOutMfMatrix[i]);
	else {
#ifdef MATLAB_MEX_FILE
		fisCallMatlabFcn2(fis->BigWeightMatrix, fis->BigOutMfMatrix,
			fis->rule_n, numofpoints, fis->impMethod, fis->BigOutMfMatrix);
#else
				PRINTF("Given IMP method %s is unknown.\n", fis->impMethod);
				fisError("Exiting ...");
#endif
	}
	
	/* apply MATLAB aggregate operator */
	if (!fis->userDefinedAgg)
		for (i = 0; i < numofpoints; i++)
			aggMF[i] = fisArrayOperation(
			fis->BigOutMfMatrix+i*fis->rule_n,
			fis->rule_n, fis->aggFcn);
	else {
#ifdef MATLAB_MEX_FILE
		fisCallMatlabFcn1(fis->BigOutMfMatrix, fis->rule_n,
			numofpoints, fis->aggMethod, aggMF);
#else
		PRINTF("Given AGG method %s is unknown.\n", fis->aggMethod);
		fisError("Exiting ...");
#endif
	}
}

/***********************************************************************
 Evaluate the constructed FIS based on given input vector 
 **********************************************************************/

/* compute outputs and put them into output nodes */
void fisEvaluate(FIS *fis, int numofpoints)
{
	DOUBLE out = 0;
	DOUBLE total_w, total_wf;
	int i, j, k, which_mf;

	if (fis == NULL) {
		PRINTF("FIS data structure has not been built yet.\n");
		fisError("Exiting ...");
	}
	
	fisComputeInputMfValue(fis);
	fisComputeFiringStrength(fis);
	total_w = fisArrayOperation(fis->firing_strength, fis->rule_n, fisSum);
	if (total_w == 0) {
#ifdef SS_SFCN /* Do not generate warning for S-function */
		PRINTF("Warning: no rule is fired for input [");
		for (i = 0; i < fis->in_n; i++)
			PRINTF("%f ", fis->input[i]->value);
		PRINTF("]\n");
		PRINTF("Average of the range for each output variable is used as default output.\n\n");
#endif
		for (i = 0; i < fis->out_n; i++)
			fis->output[i]->value = (fis->output[i]->bound[0] +
				fis->output[i]->bound[1])/2;
		return;
	}

	if (strcmp(fis->type, "sugeno") == 0) {
	fisComputeTskRuleOutput(fis);
	/* Find each rule's output */
	for (i = 0; i < fis->out_n; i++) {
		for (j = 0; j < fis->rule_n; j++) {
			which_mf = fis->rule_list[j][fis->in_n + i] - 1;
			if (which_mf == -1)	/* don't_care consequent */
				fis->rule_output[j] = 0;
			else
				fis->rule_output[j] = fis->output[i]->mf[which_mf]->value;
		}
		/* Weighted average to find the overall output*/
		total_wf = 0;
		for (k = 0; k < fis->rule_n; k++)
			total_wf += (fis->firing_strength[k]*
				fis->rule_output[k]);

		if (strcmp(fis->defuzzMethod, "wtaver") == 0)
			fis->output[i]->value = total_wf/total_w;
		else if (strcmp(fis->defuzzMethod, "wtsum") == 0)
			fis->output[i]->value = total_wf;
		else {
			PRINTF("Unknown method (%s) for Sugeno model!", fis->defuzzMethod);
			fisError("Legal methods: wtaver, wtsum");
		}
	}
	}
	else if (strcmp(fis->type, "mamdani") == 0)
	for (i = 0; i < fis->out_n; i++) {
	/*	double aggMF[MF_POINT_N];
		double X[MF_POINT_N];*/
		DOUBLE *aggMF;
		DOUBLE *X;

		DOUBLE min = fis->output[i]->bound[0];
		DOUBLE max = fis->output[i]->bound[1];
		DOUBLE step = (max - min)/(numofpoints - 1);

                X = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));
                aggMF = (DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE));      
                
		for (j = 0; j < numofpoints; j++)
			X[j] = min + step*j;
		/* fill in aggMF */
		fisFinalOutputMf2(fis, i, aggMF, numofpoints);
		/* defuzzification */
		if (!fis->userDefinedDefuzz)
			out = (*fis->defuzzFcn)(fis, i, aggMF, numofpoints);
		else {	/* user defined defuzzification */
#ifdef MATLAB_MEX_FILE
			out = fisCallMatlabDefuzz(X, aggMF, numofpoints, fis->defuzzMethod);
#else
			PRINTF("Given defuzzification method %s is unknown.\n", fis->defuzzMethod);
			fisError("Exiting ...");
#endif
		}
		fis->output[i]->value = out;
                FREE(X);
                FREE(aggMF);
	}
	else {
	PRINTF("Given FIS %s is unknown.\n", fis->name);
	fisError("Exiting ...");
	}
}

/* given input vector and FIS data structure, return output */
/* this is a wrap-up on fisEvaluate () */  
/* used in fismain() only */
static void getFisOutput(DOUBLE *input, FIS *fis, DOUBLE *output)
{
	int i;

	/* dispatch input */
	for (i = 0; i < fis->in_n; i++)
		fis->input[i]->value = input[i];

	/* evaluate FIS */
	fisEvaluate(fis, 101);

	/* dispatch output */
	for (i = 0; i < fis->out_n; i++)
		output[i] = fis->output[i]->value;
}
/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.10 $ */

#ifdef MATLAB_MEX_FILE

FIS *matlab2cStr(const mxArray *matlabmat, int numofpoints)
{
	int i, j, k, param_size, data_size, status, buflen=100;
    mxArray *fispointer, *inputpointer, *mfpointer;
	FIS *fis;
    DOUBLE *real_data_ptr;
	int *in_mf_n, *out_mf_n;
	IO *io_list;

	/*----------- Create FIS node -------------------*/
	/* allocate space for FIS structure */
	fis = (FIS *)fisCalloc(1, sizeof(FIS));
    if (fis == NULL)  return(NULL); 
    /* get fis name, type, ....*/
    fispointer=mxGetField(matlabmat, 0,"name");
    status=mxGetString(fispointer, fis->name, buflen);
    /* fis->type */
    fispointer=mxGetField(matlabmat, 0,"type");
    status=mxGetString(fispointer, fis->type, buflen);
    if (status!=0) fisError("Can not get fis type");
    /* fis->andMethod */
    fispointer=mxGetField(matlabmat, 0,"andMethod");
    status=mxGetString(fispointer, fis->andMethod, buflen);
    if (status!=0) fisError("Can not get fis andMethod");
    /* fis->orMethod */
    fispointer=mxGetField(matlabmat, 0,"orMethod");
    status=mxGetString(fispointer, fis->orMethod, buflen);
    if (status!=0) fisError("Can not get fis orMethod");
    /* fis->defuzzMethod */
    fispointer=mxGetField(matlabmat, 0,"defuzzMethod");
    status=mxGetString(fispointer, fis->defuzzMethod, buflen);
    if (status!=0) fisError("Can not get fis defuzzMethod");
    /* fis->impMethod */
    fispointer=mxGetField(matlabmat, 0,"impMethod");
    status=mxGetString(fispointer, fis->impMethod, buflen);
    if (status!=0) fisError("Can not get fis impMethod");
    /* fis->aggMethod */
    fispointer=mxGetField(matlabmat, 0,"aggMethod");
    status=mxGetString(fispointer, fis->aggMethod, buflen);
    if (status!=0) fisError("Can not get fis aggMethod");

	/* inputs */
    fispointer = mxGetField(matlabmat, 0,"input");
	fis->in_n = mxGetN(fispointer);
       
	/* create input node list, each in_mf_n's element containts the number of mf */
	in_mf_n = (int *)fisCalloc(fis->in_n, sizeof(int));
	for (i = 0; i < fis->in_n; i++){
        inputpointer = mxGetField(fispointer, i, "mf"); 
        if (inputpointer!=NULL)
            in_mf_n[i] = mxGetN(inputpointer);
        else
            in_mf_n[i] = 0;
        }
	io_list = fisBuildIoList(fis->in_n, in_mf_n);
    FREE(in_mf_n);

	/* allocate memory for input list */
	/* REVISIT: why using a **IO for fis->input as opposed to a *IO ?? */
	fis->input = (IO **)fisCalloc(fis->in_n, sizeof(IO *));
	for (i = 0; i < fis->in_n; i++)
		fis->input[i] = io_list+i;
    /*finished input memory allocation */

	for(i=0; i<fis->in_n; i++){
		inputpointer=mxGetField(fispointer, i, "name");
		status=mxGetString(inputpointer, fis->input[i]->name, buflen);

		inputpointer = mxGetField(fispointer, i, "range");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
		fis->input[i]->bound[0] = real_data_ptr[0];
		fis->input[i]->bound[1] = real_data_ptr[1];

		inputpointer=mxGetField(fispointer, i, "mf");
		if (inputpointer!=NULL)
			fis->input[i]->mf_n = mxGetN(inputpointer);
		else
			fis->input[i]->mf_n = 0;

		for(j=0; j<fis->input[i]->mf_n; j++){
            mfpointer = mxGetField(inputpointer, j, "name");
            status = mxGetString(mfpointer, fis->input[i]->mf[j]->label, buflen);
            mfpointer = mxGetField(inputpointer, j, "type");
            status = mxGetString(mfpointer, fis->input[i]->mf[j]->type, buflen);
            mfpointer = mxGetField(inputpointer, j, "params");
            param_size = mxGetN(mfpointer);
			fis->input[i]->mf[j]->nparams = param_size;	
			fis->input[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
            real_data_ptr = (DOUBLE *)mxGetPr(mfpointer);
            for(k=0; k<param_size; k++) 
				fis->input[i]->mf[j]->params[k] = (*real_data_ptr++);
		}
	}

	/* outputs */
    fispointer=mxGetField(matlabmat, 0,"output");
	fis->out_n = mxGetN(fispointer);

	/* create output node list, each in_mf_n's element containts the number of mf */
	out_mf_n = (int *)fisCalloc(fis->out_n, sizeof(int));
	for (i = 0; i < fis->out_n; i++){
        inputpointer=mxGetField(fispointer, i, "mf"); 
        if (inputpointer!=NULL)
			out_mf_n[i] = mxGetN(inputpointer);
		else
			out_mf_n[i] = 0;
        }
	io_list = fisBuildIoList(fis->out_n, out_mf_n);
	FREE(out_mf_n); 

	/* allocate memory for input list */
	fis->output = (IO **)fisCalloc(fis->out_n, sizeof(IO *));
	for (i = 0; i < fis->out_n; i++)
		fis->output[i] = io_list+i;
    /*finished output memory allocation */
	
	for(i=0; i<fis->out_n; i++){
		inputpointer=mxGetField(fispointer, i, "name");
		status=mxGetString(inputpointer, fis->output[i]->name, buflen);

		inputpointer=mxGetField(fispointer, i, "range");
		real_data_ptr=(DOUBLE *)mxGetPr(inputpointer);
		fis->output[i]->bound[0] = real_data_ptr[0];
		fis->output[i]->bound[1] = real_data_ptr[1];

		inputpointer=mxGetField(fispointer, i, "mf");
		if (inputpointer!=NULL)
           fis->output[i]->mf_n=mxGetN(inputpointer);
		else
           fis->output[i]->mf_n=0;

        for(j=0; j<fis->output[i]->mf_n; j++){
			mfpointer=mxGetField(inputpointer, j, "name");
            status=mxGetString(mfpointer, fis->output[i]->mf[j]->label, buflen);
            mfpointer=mxGetField(inputpointer, j, "type");
            status=mxGetString(mfpointer, fis->output[i]->mf[j]->type, buflen);
            mfpointer=mxGetField(inputpointer, j, "params");
			real_data_ptr = (DOUBLE *)mxGetPr(mfpointer);

			if (strcmp(fis->type, "sugeno") == 0) {
				/* For Sugeno: in the MATLAB structure, length(mf.params) is
				     * 1      for mf.type = 'constant'
					 * in_n+1 for mf.type = 'linear'
				   In the C structure, this is converted to a vector of length in_n+1 with the 
				   constant part of the MF function as last entry,
				*/
				param_size = fis->in_n+1;
				data_size = mxGetM(mfpointer)*mxGetN(mfpointer);
				fis->output[i]->mf[j]->nparams = param_size;
				fis->output[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
				if (data_size > 0) {
					/* Protect about [] data for backward compatibility */
					if (strcmp(fis->output[i]->mf[j]->type, "constant") == 0) {
						/* Constant output MF for Sugeno system */
						if (data_size != 1)
							fisError("Invalid FIS. PARAMS field of constant output MF must contain a scalar.");
						for(k=0; k<fis->in_n; k++)
							fis->output[i]->mf[j]->params[k] = 0.0;
						fis->output[i]->mf[j]->params[fis->in_n] = real_data_ptr[0];
					}
					else {
						/* Linear output MF for Sugeno system */
						if (data_size != param_size)
							fisError("Invalid FIS. PARAMS field of linear output MF has incorrect length.");
						for(k=0; k<param_size; k++)
							fis->output[i]->mf[j]->params[k] = *(real_data_ptr++);
					}
				}
			}
			else if (strcmp(fis->type, "mamdani") == 0) {
				/* Mamdani system */
				param_size = mxGetM(mfpointer)*mxGetN(mfpointer);
				fis->output[i]->mf[j]->nparams = param_size;	
				fis->output[i]->mf[j]->params = (DOUBLE *)fisCalloc(param_size,sizeof(DOUBLE));
				for(k=0; k<param_size; k++)
					fis->output[i]->mf[j]->params[k] = *(real_data_ptr++);
				/* Allocate MF value array */
				fis->output[i]->mf[j]->value_array =(DOUBLE *)fisCalloc(numofpoints, sizeof(DOUBLE)); 
			}
		}
	}

           
	/* rules */
    fispointer=mxGetField(matlabmat, 0,"rule");
    if (fispointer==NULL)
        fis->rule_n=0;
    else
		fis->rule_n = mxGetN(fispointer);

	fis->rule_list = (int **)fisCreateMatrix(fis->rule_n, fis->in_n + fis->out_n, sizeof(int));
	fis->rule_weight = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->and_or = (int *)fisCalloc(fis->rule_n, sizeof(int));
	
	for (i = 0; i < fis->rule_n; i++) {
        inputpointer=mxGetField(fispointer, i, "antecedent");
        real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    for (j = 0; j < fis->in_n ; j++)
			fis->rule_list[i][j] = (int)(*real_data_ptr++);

		inputpointer=mxGetField(fispointer, i, "consequent");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    for (j = 0; j < fis->out_n ; j++)
			fis->rule_list[i][j+fis->in_n] = (int)(*real_data_ptr++);
           
		inputpointer=mxGetField(fispointer, i, "weight");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    fis->rule_weight[i] = *real_data_ptr;

		inputpointer=mxGetField(fispointer, i, "connection");
		real_data_ptr = (DOUBLE *)mxGetPr(inputpointer);
	    fis->and_or[i] = (int)(*real_data_ptr); 
	}
		
	fisAssignMfPointer(fis);
	fisAssignFunctionPointer(fis); 
	fis->firing_strength = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));
	fis->rule_output = (DOUBLE *)fisCalloc(fis->rule_n, sizeof(DOUBLE));

	if (strcmp(fis->type, "mamdani") == 0) {
		fis->BigOutMfMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
		fis->BigWeightMatrix = (DOUBLE *)
			fisCalloc(fis->rule_n*numofpoints, sizeof(DOUBLE));
	}

	fis->mfs_of_rule = (DOUBLE *)fisCalloc(fis->in_n, sizeof(DOUBLE));
	if (strcmp(fis->type, "mamdani") == 0) {
		for (i = 0; i < fis->out_n; i++)
         	fisComputeOutputMfValueArray(fis, numofpoints);
	} 
	fisCheckDataStructure(fis);

	/*----------finished setting fis structure-------------------*/
	fis->next = NULL;
	return(fis);
}

#else
# define matlab2cStr(matlabmat, numofpoints)  NULL
#endif



/* transform matlab matrix to C matrix */
static DOUBLE **matlab2c(const mxArray *matlabmat)
{
	int m = mxGetM(matlabmat);
	int n = mxGetN(matlabmat);
	const DOUBLE *mat = mxGetPr(matlabmat);
	DOUBLE **out = (DOUBLE **)fisCreateMatrix(m, n, sizeof(DOUBLE));
	int i, j;

	for (i = 0; i < m; i++)
		for(j = 0; j < n; j++)
			out[i][j] = mat[j*m + i];
	return(out);
}
