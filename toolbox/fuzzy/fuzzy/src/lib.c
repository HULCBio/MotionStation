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
