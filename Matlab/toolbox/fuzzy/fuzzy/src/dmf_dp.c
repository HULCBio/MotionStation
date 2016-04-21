/* Copyright 1994-2002 The MathWorks, Inc.  */
/* $Revision: 1.12 $  $Date: 2002/06/17 12:47:01 $  $Author: eyarrow $ */

/* return the derivative of MF w.r.t. index-th parameters */
static DOUBLE fisMfDerivative(DOUBLE (*mfFcn)(), DOUBLE x, DOUBLE *para, int index)
{
	if (mfFcn == fisTriangleMf) {
		DOUBLE a = para[0], b = para[1], c = para[2];
		switch(index) {
		case 0:
			if (a <= x && x <= b)
				return(-(b-x)/((b-a)*(b-a)));
			return(0);
		case 1:
			if (a <= x && x <= b)
				return(-(x-a)/((b-a)*(b-a)));
			if (b <= x && x <= c)
				return((c-x)/((c-b)*(c-b)));
			return(0);
		case 2:
			if (b <= x && x <= c)
				return((x-b)/((c-b)*(c-b)));
			return(0);
		default:
			fisError("Error in fisMfDerivative: fisTriangleMf!");
		}
	}
	if (mfFcn == fisTrapezoidMf) {
		DOUBLE a = para[0], b = para[1], c = para[2], d = para[3];
		DOUBLE y, y1, y2;

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

		y = MIN(y1, y2);

		if (y == y1) {
		if (index == 0)
			if (a <= x && x <= b)
				return(-(b-x)/((b-a)*(b-a)));
		if (index == 1)
			if (a <= x && x <= b)
				return(-(x-a)/((b-a)*(b-a)));
		} else {	/* y == y2 */
		if (index == 2)
			if (c <= x && x <= d)
				return((d-x)/((d-c)*(d-c)));
		if (index == 3)
			if (c <= x && x <= d)
				return((x-c)/((d-c)*(d-c)));
		}
		return(0);
	}
	if (mfFcn == fisGaussianMf) {
		DOUBLE sigma = para[0], c = para[1];
		DOUBLE y = exp(-pow((x-c)/sigma, 2.0)/2);
		if (index == 0)
			return(y*pow(x-c, 2.0)/pow(sigma, 3.0));
		if (index == 1)
			return(y*(x-c)/pow(sigma, 2.0));
		fisError("Error in fisMfDerivative: fisGaussianMf!");
	}
	if (mfFcn == fisGaussian2Mf) {
		DOUBLE sigma1 = para[0], c1 = para[1];
		DOUBLE sigma2 = para[2], c2 = para[3];

		DOUBLE y1 = x >= c1? 1:exp(-pow((x-c1)/sigma1, 2.0)/2);
		DOUBLE dy1_ds = x >= c1? 0:y1*pow(x-c1, 2.0)/pow(sigma1, 3.0);
		DOUBLE dy1_dc = x >= c1? 0:y1*(x-c1)/pow(sigma1, 2.0);

		DOUBLE y2 = x <= c2? 1:exp(-pow((x-c2)/sigma2, 2.0)/2);
		DOUBLE dy2_ds = x <= c2? 0:y2*pow(x-c2, 2.0)/pow(sigma2, 3.0);
		DOUBLE dy2_dc = x <= c2? 0:y2*(x-c2)/pow(sigma2, 2.0);

		if (index == 0)
			return(dy1_ds*y2);
		if (index == 1)
			return(dy1_dc*y2);
		if (index == 2)
			return(y1*dy2_ds);
		if (index == 3)
			return(y1*dy2_dc);
		fisError("Error in fisMfDerivative: fisGaussian2Mf!");
	}
	if (mfFcn == fisSigmoidMf) {
		DOUBLE a = para[0], c = para[1];
		DOUBLE y = 1/(1+exp(-a*(x-c)));
		if (index == 0)
			return(y*(1-y)*(x-c));
		if (index == 1)
			return(-y*(1-y)*a);
		fisError("Error in fisMfDerivative: fisSigmoidMf!");
	}
	if (mfFcn == fisProductSigmoidMf) {
		DOUBLE a1 = para[0], c1 = para[1], a2 = para[2], c2 = para[3];
		DOUBLE y1 = 1/(1+exp(-a1*(x-c1)));
		DOUBLE y2 = 1/(1+exp(-a2*(x-c2)));
		if (index == 0)
			return(y1*(1-y1)*(x-c1)*y2);
		if (index == 1)
			return(-y1*(1-y1)*a1*y2);
		if (index == 2)
			return(y1*y2*(1-y2)*(x-c2));
		if (index == 3)
			return(-y1*y2*(1-y2)*a2);
		fisError("Error in fisMfDerivative: fisProductSigmoidMf!");
	}
	if (mfFcn == fisDifferenceSigmoidMf) {
		DOUBLE a1 = para[0], c1 = para[1], a2 = para[2], c2 = para[3];
		DOUBLE y1 = 1/(1+exp(-a1*(x-c1)));
		DOUBLE y2 = 1/(1+exp(-a2*(x-c2)));
		int sign = y1 >= y2 ? 1:-1;
		if (index == 0)
			return(y1*(1-y1)*(x-c1)*sign);
		if (index == 1)
			return(-y1*(1-y1)*a1*sign);
		if (index == 2)
			return(-y2*(1-y2)*(x-c2)*sign);
		if (index == 3)
			return(y2*(1-y2)*a2*sign);
		fisError("Error in fisMfDerivative: fisDifferenceSigmoidMf!");
	}
	if (mfFcn == fisGeneralizedBellMf) {
		DOUBLE a = para[0], b = para[1], c = para[2];
		DOUBLE tmp1 = (x - c)/a;
		/* the following line causes domain error on PC */
		/* 
		double tmp2 = tmp1 == 0 ? 0 : pow(pow(tmp1, 2.0), b);
		*/
		DOUBLE tmp2 = tmp1 == 0 ? 0 : pow(tmp1*tmp1, b);
		DOUBLE denom = (1 + tmp2)*(1 + tmp2);
		if (index == 0)
			return(2*b*tmp2/(a*denom));
		if (index == 1)
			if (x == c || x == c+a)
				return(0.0);
			else
				return(-log(tmp1*tmp1)*tmp2/denom);
		if (index == 2)
			if (x == c)
				return(0.0);
			else
				return(2*b*tmp2/((x - c)*(denom)));
		fisError("Error in fisMfDerivative: fisGeneralizedBellMf!");
	}
	if (mfFcn == fisSMf) {
		DOUBLE a = para[0], b = para[1];
		if (a <= x && x <= (a+b)/2) {
			if (index == 0)
				return(-4*(x-a)*(b-x)/pow(b-a, 3.0));
			if (index == 1)
				return(-4*pow(x-a, 2.0)/pow(b-a, 3.0));
			fisError("Error in fisMfDerivative: fisSMf!");
		}
		if ((a+b)/2 <= x && x <= b) {
			if (index == 0)
				return(-4*pow(b-x, 2.0)/pow(b-a, 3.0));
			if (index == 1)
				return(-4*(x-a)*(b-x)/pow(b-a, 3.0));
			fisError("Error in fisMfDerivative: fisSMf!");
		}
		return(0.0);
	}
	if (mfFcn == fisZMf) {
		DOUBLE a = para[0], b = para[1];
		if (a <= x && x <= (a+b)/2) {
			if (index == 0)
				return(4*(x-a)*(b-x)/pow(b-a, 3.0));
			if (index == 1)
				return(4*pow(x-a, 2.0)/pow(b-a, 3.0));
			fisError("Error in fisMfDerivative: fisZMf!");
		}
		if ((a+b)/2 <= x && x <= b) {
			if (index == 0)
				return(4*pow(b-x, 2.0)/pow(b-a, 3.0));
			if (index == 1)
				return(4*(x-a)*(b-x)/pow(b-a, 3.0));
			fisError("Error in fisMfDerivative: fisZMf!");
		}
		return(0.0);
	}
	if (mfFcn == fisPiMf) {
		if (index == 0)
			return(fisMfDerivative(fisSMf, x, para, 0)*
				fisZMf(x, para+2));
		if (index == 1)
			return(fisMfDerivative(fisSMf, x, para, 1)*
				fisZMf(x, para+2));
		if (index == 2)
			return(fisMfDerivative(fisZMf, x, para+2, 0)*
				fisSMf(x, para));
		if (index == 3)
			return(fisMfDerivative(fisZMf, x, para+2, 1)*
				fisSMf(x, para));
		fisError("Error in fisMfDerivative: fisPiMf!");
	}
	fisError("Error in fisMfDerivative: unknown MF!");
	return(0);      /* for suppressing compiler's warning only */
}
