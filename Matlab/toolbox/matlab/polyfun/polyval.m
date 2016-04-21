function [y, delta] = polyval(p,x,S,mu)
%POLYVAL Evaluate polynomial.
%   Y = POLYVAL(P,X), when P is a vector of length N+1 whose elements
%   are the coefficients of a polynomial, is the value of the
%   polynomial evaluated at X.
%
%       Y = P(1)*X^N + P(2)*X^(N-1) + ... + P(N)*X + P(N+1)
%
%   If X is a matrix or vector, the polynomial is evaluated at all
%   points in X.  See also POLYVALM for evaluation in a matrix sense.
%
%   Y = POLYVAL(P,X,[],MU) uses XHAT = (X-MU(1))/MU(2) in place of X.
%   The centering and scaling parameters MU are optional output
%   computed by POLYFIT.
%
%   [Y,DELTA] = POLYVAL(P,X,S) or [Y,DELTA] = POLYVAL(P,X,S,MU) uses
%   the optional output structure S provided by POLYFIT to generate
%   error estimates, Y +/- delta.  If the errors in the data input to
%   POLYFIT are independent normal with constant variance, Y +/- DELTA
%   contains at least 50% of the predictions.
%
%   Class support for inputs P,X,S,MU:
%      float: double, single
%
%   See also POLYFIT, POLYVALM.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.16.4.3 $  $Date: 2004/03/02 21:47:59 $

siz_x = size(x);
m = siz_x(1); n = prod(siz_x(2:end));
nc = length(p);
if nargin == 4
   x = (x - mu(1))/mu(2);
end

if ((m+n) == 2) && (nargin < 3) && nc>0 && isfinite(x)
    % Make it scream for scalar x.  Polynomial evaluation can be
    % implemented as a recursive digital filter.
    y = filter(1,[1 -x],p);
    y = y(nc);
    return
end

% Use Horner's method for general case where X is an array.
y = zeros(siz_x, superiorfloat(x,p));
if length(p)>0, y(:) = p(1); end
for i=2:nc
    y = x .* y + p(i);
end

if nargin > 2 && nargout > 1 && ~isempty(S)
    x = x(:);

    % Extract parameters from S
    if isstruct(S),  % Use output structure from polyfit.
      R = S.R;
      df = S.df;
      normr = S.normr;
    else             % Use output matrix from previous versions of polyfit.
      [ms,ns] = size(S);
      if (ms ~= ns+2) || (nc ~= ns)
          error('MATLAB:polyval:SizeS',...
                'S matrix must be n+2-by-n where n = length(p).')
      end
      R = S(1:nc,1:nc);
      df = S(nc+1,1);
      normr = S(nc+2,1);
    end

    % Construct Vandermonde matrix.
    V(:,nc) = ones(length(x),1,class(x));
    for j = nc-1:-1:1
        V(:,j) = x.*V(:,j+1);
    end

    % S is a structure containing three elements: the Cholesky factor of the
    % Vandermonde matrix, the degrees of freedom and the norm of the residuals.
    E = V/R;
    if nc == 1
        e = sqrt(1+(E.*E));
    else
        e = sqrt(1+sum((E.*E)')');
    end
    if df == 0
        warning('MATLAB:polyval:ZeroDOF',['Zero degrees of freedom implies ' ...
                'infinite error bounds.'])
        delta = repmat(Inf,size(e));
    else
        delta = normr/sqrt(df)*e;
    end
    delta = reshape(delta,siz_x);
end

