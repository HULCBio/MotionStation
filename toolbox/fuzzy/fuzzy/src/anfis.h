/* ANFIS for MATLAB MEX file
 * J.-S. Roger Jang, 1994.
 * Copyright 1994-2001 The MathWorks, Inc. 
 */

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

#define ABS(x)   ( (x) > (0) ? (x): (-(x)) )
#define MAX(x,y) ( (x) > (y) ? (x) : (y) )
#define MIN(x,y) ( (x) < (y) ? (x) : (y) )
#define MF_PARA_N 4
#define STR_LEN 500
#define MF_POINT_N 101

/* debugging macros */

#define PRINT(expr) printf(#expr " = %g\n", (DOUBLE)expr)
#define PRINTMAT(mat,m,n) printf(#mat " = \n"); fisPrintMatrix(mat,m,n)
#define PRINTARRAY(mat,m) printf(#mat " = \n"); fisPrintArray(mat,m)


#if (defined(MATLAB_MEX_FILE) && !defined(__SIMSTRUC__))
# define FREE mxFree
#else
# define FREE free
#endif

/*
#define FREEMAT(mat,m) printf("Free " #mat " ...\n"); fisFreeMatrix(mat,m)
#define FREEARRAY(array) printf("Free " #array " ...\n"); free(array)
*/

#define FREEMAT(mat,m) fisFreeMatrix(mat,m)
#define FREEARRAY(array) FREE(array)

/***********************************************************************
 Data types
 **********************************************************************/

/* FIS node which contains global information */
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

	/* the following are for ANFIS only */
	int *in_mf_n;		/* number of input MF's */
	int total_in_mf_n;
	int *out_mf_n;		/* number of output MF's */
	int node_n;		/* number of nodes */
	int para_n;		/* number of parameters */
	DOUBLE *para;		/* array of current parameters */
	DOUBLE *trn_best_para;	/* best parameters for training */
	DOUBLE *chk_best_para;	/* best parameters for checking */
	DOUBLE *de_dp;		/* array of de_dp */
	DOUBLE *do_dp;		/* array of do_dp */
	struct an_node **node;	/* array of node pointers */
	struct an_node *layer[7];/* array of pointers to each layer */
	int layer_size[7];	/* no. of nodes in a layer */

	int epoch_n;
	int actual_epoch_n;	/* epoch number when error goal is reached */

	/* training data */
	DOUBLE **trn_data;
	int trn_data_n;
	DOUBLE *trn_error;	/* array of error for each epoch */
	DOUBLE min_trn_error;	/* min. error achieved by best parameters */
	DOUBLE trn_error_goal;	/* error goal */

	/* checking data */
	DOUBLE **chk_data;
	int chk_data_n;
	DOUBLE *chk_error;	/* array of error for each epoch */
	DOUBLE min_chk_error;	/* min. error achieved by best parameters */
	DOUBLE chk_error_goal;	/* error goal, not used */

	/* step size of gradient descent */
	DOUBLE *ss_array;	/* step size history */
	DOUBLE ss;		/* current step size */
	DOUBLE ss_dec_rate;	/* step size increase rate */
	DOUBLE ss_inc_rate;	/* step size increase rate */
	int last_dec_ss;	/* ss is decreased recently at this epoch */
	int last_inc_ss;	/* ss is increased recently at this epoch */

	/* display options */
	int display_anfis_info;
	int display_error;
	int display_ss;
	int display_final_result;

	/* matrices for kalman filter algorithm */
	DOUBLE lambda;		/* forgetting factor */
	DOUBLE **tmp_node_output;/* for storing tmp node output */
	DOUBLE *kalman_io_pair;	/* data pairs for kalman filter */
	DOUBLE **kalman_para;	/* matrix for kalman parameters */
	/* the following are for kalman filter algorithm */
	DOUBLE **S;
	DOUBLE **P;
	DOUBLE **a;
	DOUBLE **b;
	DOUBLE **a_t;
	DOUBLE **b_t;
	DOUBLE **tmp1;
	DOUBLE **tmp2;
	DOUBLE **tmp3;
	DOUBLE **tmp4;
	DOUBLE **tmp5;
	DOUBLE **tmp6;
	DOUBLE **tmp7;
	/* ===for output mf order: linear or constant======= */
	int order;
        /* ====for training method ========================= */
        int method;
	/* the following are for on-line ANFIS of SL */
	DOUBLE **in_fismat;
	int m;
	int n;
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


/* node for adaptive networks */
typedef struct an_node {
	char *name;		/* input names, MF labels, etc. */
	char *type;		/* MF type */
	int index;		/* index within ANFIS */
	int l_index;		/* local index within layer */
	int ll_index;		/* local index within group (MF only) */
	int layer;		/* which layer */
	int para_n;		/* number of parameters */
	int fanin_n;		/* number of fan-in */
	struct fan_node *fanin;	/* array of fan-in nodes */
	int fanout_n;		/* number of fan-out */
	struct fan_node *fanout;/* array of fan-out nodes */
	DOUBLE value;		/* node value */
	DOUBLE de_do;		/* deriv. of error wrt node output */
	DOUBLE tmp;		/* for holding temporary result */
	DOUBLE (*nodeFcn)();	/* node function */
	DOUBLE *input;		/* array of local input values */
	DOUBLE *para;		/* pointer into parameter array */
	DOUBLE *de_dp;		/* pointer into de_dp array */
	DOUBLE *do_dp;		/* pointer into do_dp array */
	DOUBLE bound[2];	/* bounds, for input/output nodes */
} NODE;

/* node for fan-in and fan-out list */
typedef struct fan_node {
	int index;		/* index of node */
	struct fan_node *next;	/* next FAN node */
} FAN;
