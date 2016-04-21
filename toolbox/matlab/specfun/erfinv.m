function x = erfinv(y)
%ERFINV Inverse error function.
%   X = ERFINV(Y) is the inverse error function for each element of Y.
%   The inverse error function satisfies y = erf(x), for -1 <= y <= 1
%   and -inf <= x <= inf.
%
%   See also ERF, ERFC, ERFCX, ERFCINV.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.15.4.1 $  $Date: 2003/05/01 20:43:40 $

if ~isreal(y), error('MATLAB:erfinv:ComplexInput', 'Y must be real.'); end
x = zeros(size(y));

% Coefficients in rational approximations.

a = [ 0.886226899 -1.645349621  0.914624893 -0.140543331];
b = [-2.118377725  1.442710462 -0.329097515  0.012229801];
c = [-1.970840454 -1.624906493  3.429567803  1.641345311];
d = [ 3.543889200  1.637067800];

% Central range

y0 = .7;
k = find(abs(y) <= y0);
if ~isempty(k)
    z = y(k).*y(k);
    x(k) = y(k) .* (((a(4)*z+a(3)).*z+a(2)).*z+a(1)) ./ ...
         ((((b(4)*z+b(3)).*z+b(2)).*z+b(1)).*z+1);
end;

% Near end points of range

k = find(( y0 < y ) & (y <  1));
if ~isempty(k)
    z = sqrt(-log((1-y(k))/2));
    x(k) = (((c(4)*z+c(3)).*z+c(2)).*z+c(1)) ./ ((d(2)*z+d(1)).*z+1);
end

k = find((-y0 > y ) & (y > -1));
if ~isempty(k)
    z = sqrt(-log((1+y(k))/2));
    x(k) = -(((c(4)*z+c(3)).*z+c(2)).*z+c(1)) ./ ((d(2)*z+d(1)).*z+1);
end

% The relative error of the approximation has absolute value less
% than 8.9e-7.  One iteration of Halley's rational method (third
% order) gives full machine precision.

% Newton's method: new x = x - f/f'
% Halley's method: new x = x - 1/(f'/f - (f"/f')/2)
% This function: f = erf(x) - y, f' = 2/sqrt(pi)*exp(-x^2), f" = -2*x*f'

% Newton's correction
u = (erf(x) - y) ./ (2/sqrt(pi) * exp(-x.^2));

% Halley's step
x = x - u./(1+x.*u);

% Exceptional cases

x(y == -1) = -Inf;
x(y == 1) = Inf;
x(abs(y) > 1) = NaN;
x(isnan(y)) = NaN;
