function x = erfcinv(y)
%ERFCINV Inverse complementary error function.
%   X = ERFCINV(Y) is the inverse of the complementary error function
%   for each element of Y.  It satisfies y = erfc(x) 
%   for 2 >= y >= 0 and -Inf <= x <= Inf.
%
%   See also ERF, ERFC, ERFCX, ERFINV.

%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2003/05/01 20:43:37 $

%   Original algorithm for norminv from Peter J. Acklam, jacklam@math.uio.no.

if ~isreal(y), error('MATLAB:erfcinv:ComplexInput', 'Y must be real.'); end
x = zeros(size(y));

% Coefficients in rational approximations.
a = [  1.370600482778535e-02 -3.051415712357203e-01 ...
       1.524304069216834e+00 -3.057303267970988e+00  ...
       2.710410832036097e+00 -8.862269264526915e-01 ];
b = [ -5.319931523264068e-02  6.311946752267222e-01 ...
      -2.432796560310728e+00  4.175081992982483e+00 ...
      -3.320170388221430e+00 ];
c = [  5.504751339936943e-03  2.279687217114118e-01 ...
       1.697592457770869e+00  1.802933168781950e+00 ...
      -3.093354679843504e+00 -2.077595676404383e+00 ];
d = [  7.784695709041462e-03  3.224671290700398e-01 ...
       2.445134137142996e+00  3.754408661907416e+00 ];

% Define break-points.
ylow  = 0.0485;
yhigh = 1.9515;

% Rational approximation for central region
k = ylow <= y & y <= yhigh;
if any(k(:))
   q = y(k)-1;
   r = q.*q;
   x(k) = (((((a(1)*r+a(2)).*r+a(3)).*r+a(4)).*r+a(5)).*r+a(6)).*q ./ ...
          (((((b(1)*r+b(2)).*r+b(3)).*r+b(4)).*r+b(5)).*r+1);
end

% Rational approximation for lower region
k = 0 < y & y < ylow;
if any(k(:))
   q  = sqrt(-2*log(y(k)/2));
   x(k) = (((((c(1)*q+c(2)).*q+c(3)).*q+c(4)).*q+c(5)).*q+c(6)) ./ ...
           ((((d(1)*q+d(2)).*q+d(3)).*q+d(4)).*q+1);
end

% Rational approximation for upper region
k = yhigh < y & y < 2;
if any(k(:))
   q  = sqrt(-2*log(1-y(k)/2));
   x(k) = -(((((c(1)*q+c(2)).*q+c(3)).*q+c(4)).*q+c(5)).*q+c(6)) ./ ...
            ((((d(1)*q+d(2)).*q+d(3)).*q+d(4)).*q+1);
end

% The relative error of the approximation has absolute value less
% than 1.13e-9.  One iteration of Halley's rational method (third
% order) gives full machine precision.

% Newton's method: new x = x - f/f'
% Halley's method: new x = x - 1/(f'/f - (f"/f')/2)
% This function: f = erfc(x) - y, f' = -2/sqrt(pi)*exp(-x^2), f" = -2*x*f'

% Newton's correction
u = (erfc(x) - y) ./ (-2/sqrt(pi) * exp(-x.^2));

% Halley's step
x = x - u./(1+x.*u);

% Exceptional cases

x(y == 0) = Inf;
x(y == 2) = -Inf;
x(y < 0) = NaN;
x(y > 2) = NaN;
x(isnan(y)) = NaN;
