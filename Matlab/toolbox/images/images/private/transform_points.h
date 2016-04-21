/* Copyright 1993-2003 The MathWorks, Inc. */

/* $Revision: 1.4.4.2 $ */
/*
 * This is the template function for handling the U = inv_fcn(X,t)
 * syntax.  Its inputs and outputs are the standard mexFunction ones.
 *
 */
(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    TYPE *data;
    const mxArray *X, *T;
    mxArray *tdata;
    mxArray *U;
    double *u_ptr;
    double *v_ptr;
    double *X_ptr = NULL;
    double *x_ptr;
    double *y_ptr;
    int M;
    int k;


    X = prhs[0];
    if (X != NULL) 
    {

        /*
         * X must be a real nPoints-by-2 double-precision matrix.  
         */

        M = mxGetM(X);

        if (!mxIsDouble(X) ||
            (mxGetNumberOfDimensions(X) > 2) ||
            (M < 0) ||
            (mxGetN(X) != 2) ||
            mxIsComplex(X))
        {
            mexErrMsgIdAndTxt("Images:transform_points_h:inputXMustBeReal2D",
                              "%s",ERR_X_BAD);
        }
        
        X_ptr = (double *) mxGetData(X);
        
        /*
         * X must not contain Inf's or NaN's.
         */ 
        for (k = 0; k < M*2; k++)
        {
            if (! mxIsFinite(X_ptr[k]))
            {
                mexErrMsgIdAndTxt("Images:transform_points_h:"
                                  "inputXMustBeFinite",
                                  "%s",ERR_X_NANINF);
            }
        }
    }
    else
    {
        mexErrMsgIdAndTxt("Images:transform_points_h:inputXMustBeReal2D",
                          "%s",ERR_X_BAD);
    }


    T = prhs[1];
    if ((T != NULL) && !mxIsEmpty(T))
    {

        if (!mxIsStruct(T) ||
            mxGetField(T,0,"ndims_in")==NULL ||
            mxGetField(T,0,"ndims_out")==NULL ||
            mxGetField(T,0,"forward_fcn")==NULL ||
            mxGetField(T,0,"inverse_fcn")==NULL ||
            mxGetField(T,0,"tdata")==NULL)
        {
            mexErrMsgIdAndTxt("Images:transform_points_h:"
                              "inputTMustBeTFORMStruct",
                              "%s",ERR_T_BAD);
        }

        tdata = mxGetField(prhs[1],0,"tdata");
        if (!mxIsStruct(tdata))
        {
            mexErrMsgIdAndTxt("Images:transform_points_h:"
                              "secondInputMustBeTFORMStruct",
                              "%s",ERR_INPUT_NOT_A_STRUCT);
        }
        else
        {
            data = (TYPE *) mxCalloc(1, sizeof(*data));
            INIT_DATA(tdata,data); 
        }
    }    
    else
    {
        mexErrMsgIdAndTxt("Images:transform_points_h:inputTMustBeTFORMStruct",
                          "%s",ERR_T_BAD);
    }

    /*
     * Initialize output coordinate matrix.
     */
    U = mxCreateDoubleMatrix(M,2,mxREAL);

    /*
     * For each location in output space, compute the corresponding
     * location in input space and store the results in the output
     * matrices.  
     */
    u_ptr = (double *) mxGetData(U);
    v_ptr = (double *) u_ptr + M;
    x_ptr = X_ptr;
    y_ptr = (double *) x_ptr + M;
    
    for (k = 0; k < M; k++) /* loop over points */
    {
        REVERSE_MAPPING(data,*x_ptr,*y_ptr,u_ptr,v_ptr);

        x_ptr++;
        y_ptr++;
        u_ptr++;
        v_ptr++;
    }
    
    plhs[0] = U;
    DESTROY_DATA(data);
}

#undef TYPE
#undef INIT_DATA
#undef REVERSE_MAPPING
#undef DESTROY_DATA







