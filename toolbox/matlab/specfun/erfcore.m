function result = erfcore(x,jint)
%ERFCORE Core algorithm for error functions.
%   erf(x) = erfcore(x,0)
%   erfc(x) = erfcore(x,1)
%   erfcx(x) = exp(x^2)*erfc(x) = erfcore(x,2)

%   C. Moler, 2-1-91.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.15.4.1 $  $Date: 2003/05/01 20:43:38 $

%   This is a translation of a FORTRAN program by W. J. Cody,
%   Argonne National Laboratory, NETLIB/SPECFUN, March 19, 1990.
%   The main computation evaluates near-minimax approximations
%   from "Rational Chebyshev approximations for the error function"
%   by W. J. Cody, Math. Comp., 1969, PP. 631-638.

%   Note: This M-file is intended to document the algorithm.
%   If a .DLL file or .MEX file for a particular architecture exists,
%   it will be executed instead, but its functionality is the same.
%#mex

    if ~isreal(x),
       error('MATLAB:erfcore:ComplexInput', 'Input argument must be real.')
    end
    result = repmat(NaN,size(x));
%
%   evaluate  erf  for  |x| <= 0.46875
%
    xbreak = 0.46875;
    k = find(abs(x) <= xbreak);
    if ~isempty(k)
        a = [3.16112374387056560e00; 1.13864154151050156e02;
             3.77485237685302021e02; 3.20937758913846947e03;
             1.85777706184603153e-1];
        b = [2.36012909523441209e01; 2.44024637934444173e02;
             1.28261652607737228e03; 2.84423683343917062e03];

            y = abs(x(k));
            z = y .* y;
            xnum = a(5)*z;
            xden = z;
            for i = 1:3
               xnum = (xnum + a(i)) .* z;
               xden = (xden + b(i)) .* z;
            end
            result(k) = x(k) .* (xnum + a(4)) ./ (xden + b(4));
            if jint ~= 0, result(k) = 1 - result(k); end
            if jint == 2, result(k) = exp(z) .* result(k); end
    end
%
%   evaluate  erfc  for 0.46875 <= |x| <= 4.0
%
    k = find((abs(x) > xbreak) &  (abs(x) <= 4.));
    if ~isempty(k)
        c = [5.64188496988670089e-1; 8.88314979438837594e00;
             6.61191906371416295e01; 2.98635138197400131e02;
             8.81952221241769090e02; 1.71204761263407058e03;
             2.05107837782607147e03; 1.23033935479799725e03;
             2.15311535474403846e-8];
        d = [1.57449261107098347e01; 1.17693950891312499e02;
             5.37181101862009858e02; 1.62138957456669019e03;
             3.29079923573345963e03; 4.36261909014324716e03;
             3.43936767414372164e03; 1.23033935480374942e03];

            y = abs(x(k));
            xnum = c(9)*y;
            xden = y;
            for i = 1:7
               xnum = (xnum + c(i)) .* y;
               xden = (xden + d(i)) .* y;
            end
            result(k) = (xnum + c(8)) ./ (xden + d(8));
            if jint ~= 2
               z = fix(y*16)/16;
               del = (y-z).*(y+z);
               result(k) = exp(-z.*z) .* exp(-del) .* result(k);
            end
    end
%
%   evaluate  erfc  for |x| > 4.0
%
    k = find(abs(x) > 4.0);
    if ~isempty(k)
        p = [3.05326634961232344e-1; 3.60344899949804439e-1;
             1.25781726111229246e-1; 1.60837851487422766e-2;
             6.58749161529837803e-4; 1.63153871373020978e-2];
        q = [2.56852019228982242e00; 1.87295284992346047e00;
             5.27905102951428412e-1; 6.05183413124413191e-2;
             2.33520497626869185e-3];

            y = abs(x(k));
            z = 1 ./ (y .* y);
            xnum = p(6).*z;
            xden = z;
            for i = 1:4
               xnum = (xnum + p(i)) .* z;
               xden = (xden + q(i)) .* z;
            end
            result(k) = z .* (xnum + p(5)) ./ (xden + q(5));
            result(k) = (1/sqrt(pi) -  result(k)) ./ y;
            if jint ~= 2
               z = fix(y*16)/16;
               del = (y-z).*(y+z);
               result(k) = exp(-z.*z) .* exp(-del) .* result(k);
               k = find(~isfinite(result));
               result(k) = 0*k;
            end
    end
%
%   fix up for negative argument, erf, etc.
%
    if jint == 0
            k = find(x > xbreak);
            result(k) = (0.5 - result(k)) + 0.5;
            k = find(x < -xbreak);
            result(k) = (-0.5 + result(k)) - 0.5;
    elseif jint == 1
            k = find(x < -xbreak);
            result(k) = 2. - result(k);
    else  % jint must = 2 
            k = find(x < -xbreak);
            z = fix(x(k)*16)/16;
            del = (x(k)-z).*(x(k)+z);
            y = exp(z.*z) .* exp(del);
            result(k) = (y+y) - result(k);
    end
