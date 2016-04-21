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
