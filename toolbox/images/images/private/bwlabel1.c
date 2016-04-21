/* Copyright 1993-2003 The MathWorks, Inc. */

/*
 * First helper MEX-file for BWLABEL
 * 1. Computes run-length encoding for input binary image
 * 2. Assigns initial labels to runs while recording equivalences
 *
 * Syntax:
 *        [SR,ER,C,LABELS,I,J] = BWLABEL1(BW,MODE)
 *
 * BW is a 2-D uint8 array.  MODE is a scalar, either 8 or 4, indicating
 * the connectedness of the foreground of BW.
 *
 * SR, ER, C, and LABELS are column vectors whose length is the number
 * of runs.  SR contains the starting row for each run.  ER contains the
 * ending row for each run.  C contains the column for each run.  LABELS
 * contains the initial labels determined for each run.  I and J contain
 * labels equivalence information.  For example, if I(4) = 10 and J(4) = 20,
 * that means that labels 10 and 20 are equivalent.
 * 
 */

#include "mex.h"

static char rcsid[] = "$Revision: 1.16.4.3 $";

/*
 * Make sure input and output arguments are correct.
 */
void ValidateInputs(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    if (nrhs != 2)
    {
        mexErrMsgIdAndTxt("Images:bwlabel1:wrongNumInputs",
                          "BWLABEL1 requires two input arguments.");
    }    
    if ((mxGetScalar(prhs[1]) != 4.0) && (mxGetScalar(prhs[1]) != 8.0))
    {
        mexErrMsgIdAndTxt("Images:bwlabel1:badConn",
                          "%s",
                          "Function bwlabel1 expected its second input argument, CONN, to be either 4 or 8.");
    }
}

/*
 * Scan the input array, counting the number of runs present.
 */
int NumberOfRuns(mxLogical *in, int M, int N)
{
    int result = 0;
    int col;
    mxLogical *pr;
    int k;
    int offset;

    if ( (M != 0) && (N != 0) )
    {
        for (col = 0; col < N; col++)
        {
            offset = col*M;
            pr = in + offset;
            
            if (pr[0] != 0)
            {
                result++;
            }
            
            for (k = 1; k < M; k++)
            {
                if ((pr[k] != 0) && (pr[k-1] == 0))
                {
                    result++;
                }
            }
        }
    }
    
    return(result);
}

/*
 * Scan the array, recording start row, end row, and column information
 * about each run.  The calling function must allocate sufficient space 
 * for sr, er, and c.
 */
void FillRunVectors(mxLogical *in, int M, int N, double *sr, double *er, double *c)
{
    int col;
    int offset;
    mxLogical *pr;
    int runCounter = 0;
    int k;
        
    for (col = 0; col < N; col++)
    {
        offset = col*M;
        pr = in + offset;
        
        k = 0;
        while (k < M)
        {
            /* Look for the next run. */
            while ((k < M) && (pr[k] == 0))
            {
                k++;
            }
            
            if ((k < M) && (pr[k] != 0))
            {
                c[runCounter] = col + 1;
                sr[runCounter] = k + 1;
                while ((k < M) && (pr[k] != 0))
                {
                    k++;
                }
                er[runCounter] = k;
                runCounter++;
            }
        }
    }
}

typedef struct equivnode 
{
    int rowIndex;
    int colIndex;
    struct equivnode *next;
}
EquivNode;

typedef struct equivlist
{
    EquivNode *head;
    int length;
}
EquivList;

/*
 * Initialize equivalence linked list
 */
void InitEquivalenceList(EquivList *list)
{
    list->head = NULL;
    list->length = 0;
}

/*
 * Allocate and add new node to head of equivalence list
 */
void PrependEquivalenceToList(EquivList *list, double rowIndex, double colIndex)
{
    EquivNode *newNode = NULL;
    
    newNode = mxCalloc(1, sizeof(*newNode));
    newNode->next = list->head;
    newNode->rowIndex = (int) rowIndex;
    newNode->colIndex = (int) colIndex;
    list->head = newNode;
    list->length++;
}

/*
 * Remove and free the first node in the equivalence list
 */
void DeleteHeadNode(EquivList *list)
{
    EquivNode *killNode;
    
    if (list->head != NULL)
    {
        killNode = list->head;
        list->head = killNode->next;
        mxFree((void *) killNode);
        list->length--;
    }
}

/*
 * Free the equivalence list
 */
void DestroyList(EquivList *list)
{
    while (list->head != NULL)
    {
        DeleteHeadNode(list);
    }
}

/*
 * Scan the runs, assigning labels and remembering equivalences.
 * This function allocates space for the row and column equivalence index
 * vectors rowEquivalences and colEquivalences.
 */
void FirstPass(int numRuns, int mode, double *sr, double *er, double *c, 
               double *labels, double **rowEquivalences, double **colEquivalences,
               int *numEquivalences)
{
    int k;
    int p;
    int offset;
    double currentColumn = 0;
    int nextLabel = 1;
    int firstRunOnPreviousColumn = -1;
    int lastRunOnPreviousColumn = -1;
    int firstRunOnThisColumn = -1;
    EquivList equivList;
    EquivNode *node;

    InitEquivalenceList(&equivList);

    if (mode == 8)
    {
        /* This value is used in the overlap test below. */
        offset = 1;
    }
    else
    {
        offset = 0;
    }
    
    for (k = 0; k < numRuns; k++)
    {
        /* Process k-th run */
        
        if (c[k] == (currentColumn + 1))
        {
            /* We are starting a new column adjacent to previous column */
            firstRunOnPreviousColumn = firstRunOnThisColumn;
            firstRunOnThisColumn = k;
            lastRunOnPreviousColumn = k-1;
            currentColumn = c[k];
        }
        else if (c[k] > (currentColumn + 1))
        {
            /* We are starting a new column not adjacent to previous column */
            firstRunOnPreviousColumn = -1;
            lastRunOnPreviousColumn = -1;
            firstRunOnThisColumn = k;
            currentColumn = c[k];
        }
        else
        {
            /* Not changing columns; nothing to do here */
        }
        
        if (firstRunOnPreviousColumn >= 0)
        {
            /*
             * Look for overlaps on previous column
             */
            
            p = firstRunOnPreviousColumn;
            while ((p <= lastRunOnPreviousColumn) && (sr[p] <= (er[k] + offset)))
            {
                if ((er[k] >= (sr[p]-offset)) && (sr[k] <= (er[p]+offset)))
                {
                    /* 
                     * We've got an overlap; it's 4-connected or 8-connected
                     * depending on the value of offset.
                     */
                    if (labels[k] == 0)
                    {
                        /* 
                         * This run hasn't yet been labeled;
                         * copy over the overlapping run's label
                         */
                        labels[k] = labels[p];
                    }
                    else
                    {
                        if (labels[k] != labels[p])
                        {
                            /*
                             * This run and the overlapping run
                             * have been labeled with different
                             * labels.  Remember the equivalence.
                             */
                            PrependEquivalenceToList(&equivList, labels[k], 
                                                     labels[p]);
                        }
                        else
                        {
                            /*
                             * This run and the overlapping run
                             * have been labeled with the same label;
                             * nothing to do here.
                             */
                        }
                        
                    }
                }
                p++;
            }
        }
        
        if (labels[k] == 0)
        {
            /*
             * This run hasn't yet been labeled because we
             * didn't find any overlapping runs.  Label it
             * with a new label.
             */
            labels[k] = nextLabel;
            nextLabel++;
        }
    }
    
    *numEquivalences = equivList.length;
    if (*numEquivalences > 0)
    {
        *rowEquivalences = (double *) mxCalloc(equivList.length, sizeof(double));
        *colEquivalences = (double *) mxCalloc(equivList.length, sizeof(double));

        /* 
         * Traverse the equivalence list, recording indices in the
         * output arrays.
         */
        k = 0;
        node = equivList.head;
        while (node != NULL)
        {
            (*rowEquivalences)[k] = node->rowIndex;
            (*colEquivalences)[k] = node->colIndex;
            k++;
            node = node->next;
        }
    }
    else
    {
        *rowEquivalences = NULL;
        *colEquivalences = NULL;
    }
    
    DestroyList(&equivList);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *sr;
    double *er;
    double *c;
    double *labels;
    double *rowEquivalences;
    double *colEquivalences;
    double *pr;
    int numEquivalences;
    int numRuns;
    int mode;
    int k;
    const mxArray *BW;
    
    ValidateInputs(nlhs, plhs, nrhs, prhs);
    BW = prhs[0];
    mode = (int) mxGetScalar(prhs[1]);

    numRuns = NumberOfRuns((mxLogical *) mxGetData(BW), mxGetM(BW), mxGetN(BW));
    sr = mxCalloc(numRuns, sizeof(*sr));
    er = mxCalloc(numRuns, sizeof(*er));
    c = mxCalloc(numRuns, sizeof(*c));
    labels = mxCalloc(numRuns, sizeof(*labels));
        
    FillRunVectors((mxLogical *) mxGetData(BW), mxGetM(BW), mxGetN(BW),
                   sr, er, c);

    FirstPass(numRuns, (int) mode, sr, er, c, labels, &rowEquivalences, 
              &colEquivalences, &numEquivalences);

    /* First output argument */
    plhs[0] = mxCreateDoubleMatrix(numRuns, 1, mxREAL);
    pr = (double *) mxGetData(plhs[0]);
    for (k = 0; k < numRuns; k++)
    {
        pr[k] = sr[k];
    }
    
    /* Second output argument */
    if (nlhs > 1)
    {
        plhs[1] = mxCreateDoubleMatrix(numRuns, 1, mxREAL);
        pr = (double *) mxGetData(plhs[1]);
        for (k = 0; k < numRuns; k++)
        {
            pr[k] = er[k];
        }
    }

    /* Third output argument */
    if (nlhs > 2)
    {
        plhs[2] = mxCreateDoubleMatrix(numRuns, 1, mxREAL);
        pr = (double *) mxGetData(plhs[2]);
        for (k = 0; k < numRuns; k++)
        {
            pr[k] = c[k];
        }
    }

    /* Fourth output argument */
    if (nlhs > 3)
    {
        plhs[3] = mxCreateDoubleMatrix(numRuns, 1, mxREAL);
        pr = (double *) mxGetData(plhs[3]);
        for (k = 0; k < numRuns; k++)
        {
            pr[k] = labels[k];
        }
    }

    /* Fifth output argument */
    if (nlhs > 4)
    {
        plhs[4] = mxCreateDoubleMatrix(numEquivalences, 1, mxREAL);
        pr = (double *) mxGetData(plhs[4]);
        for (k = 0; k < numEquivalences; k++)
        {
            pr[k] = rowEquivalences[k];
        }
    }

    /* Sixth output argument */
    if (nlhs > 5)
    {
        plhs[5] = mxCreateDoubleMatrix(numEquivalences, 1, mxREAL);
        pr = (double *) mxGetData(plhs[5]);
        for (k = 0; k < numEquivalences; k++)
        {
            pr[k] = colEquivalences[k];
        }
    }

    mxFree(sr);
    mxFree(er);
    mxFree(c);
    mxFree(labels);
    mxFree(rowEquivalences);
    mxFree(colEquivalences);
}

    
