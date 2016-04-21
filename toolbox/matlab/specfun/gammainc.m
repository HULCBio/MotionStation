function b = gammainc(x,a,tail)
%GAMMAINC Incomplete gamma function.
%   Y = GAMMAINC(X,A) evaluates the incomplete gamma function for
%   corresponding elements of X and A.  X and A must be real and the same
%   size (or either can be a scalar).  A must also be non-negative.
%
%   The incomplete gamma function is defined as:
%
%    gammainc(x,a) = 1 ./ gamma(a) .*
%       integral from 0 to x of t^(a-1) exp(-t) dt
%
%   For any a>=0, as x approaches infinity, gammainc(x,a) approaches 1.
%   For small x and a, gammainc(x,a) ~= x^a, so gammainc(0,0) = 1.
%
%   Y = GAMMAINC(X,A,TAIL) specifies the tail of the incomplete gamma
%   function when X is non-negative.  Choices are 'lower' (the default)
%   and 'upper'.  The upper incomplete gamma function is defined as
%   1 - gammainc(x,a).
%
%   Warning: When X is negative, Y can be inaccurate for abs(X) > A+1.
%
%   See also GAMMA, GAMMALN, PSI.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.17.4.2 $  $Date: 2003/12/26 18:09:18 $

if nargin < 3
    lower = true;
else
    switch tail
    case 'lower', lower = true;
    case 'upper', lower = false;
    otherwise, error('MATLAB:gammainc:InvalidTailArg', ...
                     'TAIL must be ''lower'' or ''upper''.');
    end
end

% x and a must be compatible for addition.
try
   b = x + a;
   b(:) = NaN;
catch
   error('MATLAB:gammainc:InputSizeMismatch', ...
         'X and A must be the same size, or scalars.')
end
if any(a(:) < 0)
   error('MATLAB:gammainc:NegativeArg', 'A must be non-negative.')
end

% If a is a vector, make sure x is too.

ascalar = isscalar(a);
if ~ascalar && isscalar(x)
   x = repmat(x,size(a));
end

% Upper limit for series and continued fraction.
amax = 2^20;

% Approximation for a > amax.  Accurate to about 5.e-5.
k = find(a > amax);
if ~isempty(k)
   if ascalar
      x = max(amax-1/3 + sqrt(amax/a).*(x-(a-1/3)),0);
      a = amax;
   else
      x(k) = max(amax-1/3 + sqrt(amax./a(k)).*(x(k)-(a(k)-1/3)),0);
      a(k) = amax;
   end
end

% Series expansion for x < a+1

k = find(a ~= 0 & x ~= 0 & x < a+1);
if ~isempty(k)
    xk = x(k);
    if ascalar, ak = a; else ak = a(k); end
    ap = ak;
    del = 1;
    sum = del;
    while norm(del,'inf') >= 100*eps(norm(sum,'inf'))
        ap = ap + 1;
        del = xk .* del ./ ap;
        sum = sum + del;
    end
    bk = sum .* exp(-xk + ak.*log(xk) - gammaln(ak+1));
    % For very small a, the series may overshoot very slightly.
    bk(xk > 0 & bk > 1) = 1;
    if lower, b(k) = bk; else b(k) = 1-bk; end
end

% Continued fraction for x >= a+1

k = find(a ~= 0 & x >= a+1); % & x ~= 0
if ~isempty(k)
    xk = x(k);
    a0 = 1;
    a1 = x(k);
    b0 = 0;
    b1 = a0;
    if ascalar, ak = a; else ak = a(k); end
    fac = 1 ./ a1;
    n = 1;
    g = b1 .* fac;
    gold = b0;
    while norm(g-gold,'inf') >= 100*eps(norm(g,'inf'));
        gold = g;
        ana = n - ak;
        a0 = (a1 + a0 .*ana) .* fac;
        b0 = (b1 + b0 .*ana) .* fac;
        anf = n*fac;
        a1 = xk .* a0 + anf .* a1;
        b1 = xk .* b0 + anf .* b1;
        fac = 1 ./ a1;
        g = b1 .* fac;
        n = n + 1;
    end
    bk = exp(-xk + ak.*log(xk) - gammaln(ak)) .* g;
    if lower, b(k) = 1-bk; else b(k) = bk; end
end

k = find(x == 0);
if ~isempty(k)
    if lower, b(k) = 0; else b(k) = 1; end
end
k = find(a == 0);
if ~isempty(k)
    if ascalar
        if lower, b(:) = 1; else b(:) = 0; end
    else
        if lower, b(k) = 1; else b(k) = 0; end
    end
end
