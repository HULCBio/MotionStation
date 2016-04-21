function y = betainc(x,a,b)
%BETAINC Incomplete beta function.
%   Y = BETAINC(X,Z,W) computes the incomplete beta function for
%   corresponding elements of X, Z, and W.  The elements of X must be in
%   the closed interval [0,1], and those of Z and W must be nonnegative.
%   X, Z, and W must all be real and the same size (or any of them can be
%   scalar).
%
%   The incomplete beta function is defined as
%
%     I_x(z,b) = 1./BETA(z,w) .*
%                 integral from 0 to x of t.^(z-1) .* (1-t).^(w-1) dt
%
%   To compute the upper tail of the incomplete beta function, use
%
%     1 - BETAINC(X,Z,W) = BETAINC(1-X,W,Z).
%
%   See also BETA, BETALN.

%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions, sec. 26.5,
%   especially 26.5.8, 26.5.20 and 26.5.21.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.16.4.6 $  $Date: 2004/03/02 21:48:35 $

if nargin < 3
    error('MATLAB:betainc:NotEnoughInputs','Requires three input arguments.')
elseif any(x(:) < 0 | x(:) > 1 | isnan(x(:))) || ~isreal(x)
    error('MATLAB:betainc:XoutOfRange','X must be in the interval [0,1].')
elseif any(a(:) < 0 | isnan(a(:))) || ~isreal(a)
    error('MATLAB:betainc:PositiveZ','Z must be real and nonnegative.')
elseif any(b(:) < 0 | isnan(b(:))) || ~isreal(b)
    error('MATLAB:betainc:PositiveW','W must be real and nonnegative.')
end

try
    % Preallocate y (using the size rules for plus)
    y = x + a + b;
catch
    error('MATLAB:betainc:XZWsizeMismatch', ...
          'X, Z and W must all the same size (or any of them can be scalar).')
end
% Initialize y(x==0) to 0, y(x==1) to 1. Everything else will be filled in.
y(:) = (x==1);

if ~isempty(y)
    k = find(0 < x & x < (a+1) ./ (a+b+2));
    if ~isempty(k)
        if isscalar(x), xk = x; else xk = x(k); end
        if isscalar(a), ak = a; else ak = a(k); end
        if isscalar(b), bk = b; else bk = b(k); end
        btk = exp(gammaln(ak+bk)-gammaln(ak+1)-gammaln(bk) + ...
                                 ak.*log(xk) + bk.*log1p(-xk));
        y(k) = btk .* betacore(xk,ak,bk);
    end

    k = find((a+1) ./ (a+b+2) <= x & x < 1);
    if ~isempty(k)
        if isscalar(x), xk = x; else xk = x(k); end
        if isscalar(a), ak = a; else ak = a(k); end
        if isscalar(b), bk = b; else bk = b(k); end
        btk = exp(gammaln(ak+bk)-gammaln(ak)-gammaln(bk+1) + ...
                                 ak.*log(xk) + bk.*log1p(-xk));
        y(k) = 1 - btk .* betacore(1-xk,bk,ak);
    end

    % NaNs may have come from a=b=0, leave those alone.  Otherwise the
    % continued fraction in betacore failed, use approximations.
    k = find(isnan(y) & (a+b>0));
    if ~isempty(k)
        if isscalar(x), xk = x; else xk = x(k); end
        if isscalar(a), ak = a; else ak = a(k); end
        if isscalar(b), bk = b; else bk = b(k); end
        w1 = (bk.*xk).^(1/3);
        w2 = (ak.*(1-xk)).^(1/3);
        y(k) = 0.5*erfc(-3/sqrt(2)*((1-1./(9*bk)).*w1-(1-1./(9*ak)).*w2)./ ...
               sqrt(w1.^2./bk+w2.^2./ak));
        
        k1 = find((ak+bk-1).*(1-xk) <= 0.8);
        if ~isempty(k1)
            if isscalar(x), xk = x; else xk = xk(k1); end
            if isscalar(a), ak = a; else ak = ak(k1); end
            if isscalar(b), bk = b; else bk = bk(k1); end
            s = 0.5*((ak+bk-1).*(3-xk)-(bk-1)).*(1-xk);
            y(k(k1)) = gammainc(s,bk,'upper');
        end
    end
end
