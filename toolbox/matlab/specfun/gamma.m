function res = gamma(x,a)
%GAMMA  Gamma function.
%   Y = GAMMA(X) evaluates the gamma function for each element of X.
%   X must be real.  The gamma function is defined as:
%
%      gamma(x) = integral from 0 to inf of t^(x-1) exp(-t) dt.
%
%   The gamma function interpolates the factorial function.  For
%   integer n, gamma(n+1) = n! (n factorial) = prod(1:n).
%
%   See also GAMMALN, GAMMAINC, PSI.

%   C. B. Moler, 5-7-91, 11-4-92.
%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 6.1.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.19.4.1 $  $Date: 2003/05/01 20:43:43 $

%   This is based on a FORTRAN program by W. J. Cody,
%   Argonne National Laboratory, NETLIB/SPECFUN, October 12, 1989.
%
% References: "An Overview of Software Development for Special
%              Functions", W. J. Cody, Lecture Notes in Mathematics,
%              506, Numerical Analysis Dundee, 1975, G. A. Watson
%              (ed.), Springer Verlag, Berlin, 1976.
%
%              Computer Approximations, Hart, Et. Al., Wiley and
%              sons, New York, 1968.

%   Note: This M-file is intended to document the algorithm.
%   If a .DLL file or .MEX file for a particular architecture exists,
%   it will be executed instead, but its functionality is the same.
%#mex

if nargin == 2
    % For backward compatibility with MATLAB 3.5
    warning('MATLAB:gamma:ObsoleteUsage',[ ...
     'This usage of GAMMA(A,X) is obsolete and will be eliminated\n' ...
     '         in future versions.  Please use GAMMAINC(A,X) instead.'])
    res = gammainc(a,x);
    return
end

p = [-1.71618513886549492533811e+0; 2.47656508055759199108314e+1;
     -3.79804256470945635097577e+2; 6.29331155312818442661052e+2;
      8.66966202790413211295064e+2; -3.14512729688483675254357e+4;
     -3.61444134186911729807069e+4; 6.64561438202405440627855e+4];
q = [-3.08402300119738975254353e+1; 3.15350626979604161529144e+2;
     -1.01515636749021914166146e+3; -3.10777167157231109440444e+3;
      2.25381184209801510330112e+4; 4.75584627752788110767815e+3;
     -1.34659959864969306392456e+5; -1.15132259675553483497211e+5];
c = [-1.910444077728e-03; 8.4171387781295e-04;
     -5.952379913043012e-04; 7.93650793500350248e-04;
     -2.777777777777681622553e-03; 8.333333333333333331554247e-02;
      5.7083835261e-03];

   if ~isreal(x)
      error('MATLAB:gamma:ComplexInput', 'Input argument must be real.')
   end
   res = zeros(size(x));
   xn = zeros(size(x));
%
%  Catch negative x.
%
   kneg = find(x <= 0);
   if ~isempty(kneg)
      y = -x(kneg);
      y1 = fix(y);
      res(kneg) = y - y1;
      fact = -pi ./ sin(pi*res(kneg)) .* (1 - 2*rem(y1,2));
      x(kneg) = y + 1;
   end
%
%  x is now positive.
%  Map x in interval [0,1] to [1,2]
%
   k1 = find(x < 1);
   x1 = x(k1);
   x(k1) = x1 + 1;
%
%  Map x in interval [1,12] to [1,2]
%
   k = find(x < 12);
   xn(k) = fix(x(k)) - 1;
   x(k) = x(k) - xn(k);
%
%  Evaluate approximation for 1 < x < 2
%
   if ~isempty(k)
      z = x(k) - 1;
      xnum = 0*z;
      xden = xnum + 1;
      for i = 1:8
         xnum = (xnum + p(i)) .* z;
         xden = xden .* z + q(i);
      end
      res(k) = xnum ./ xden + 1;
   end
%
%  Adjust result for case  0.0 < x < 1.0
%
   res(k1) = res(k1) ./ x1;
%
%  Adjust result for case  2.0 < x < 12.0
%
   for j = 1:max(xn(:))
      k = find(xn);
      res(k) = res(k) .* x(k);
      x(k) = x(k) + 1;
      xn(k) = xn(k) - 1;
   end
%
%  Evaluate approximation for x >= 12
%
   k = find(x >= 12);
   if ~isempty(k)
      y = x(k);
      ysq = y .* y;
      sum = c(7);
      for i = 1:6
         sum = sum ./ ysq + c(i);
      end
      spi = 0.9189385332046727417803297;
      sum = sum ./ y - y + spi;
      sum = sum + (y-0.5).*log(y);
      res(k) = exp(sum);
   end
%
%  Final adjustments.
%
   if any(~isfinite(x))
      k = find(isinf(x)); res(k) = Inf;
      k = find(isnan(x)); res(k) = NaN;
   end
   if ~isempty(kneg)
      res(kneg) = fact ./ res(kneg);
   end
