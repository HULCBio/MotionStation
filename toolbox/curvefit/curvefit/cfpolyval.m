function [y, delta] = cfpolyval(p,x,S,mu)
%CFPOLYVAL Evaluate polynomial.
%   Copy of R12.1 version of MATLAB's POLYVAL function.

%   Copyright 2001-2004 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $  $Date: 2004/02/01 21:41:59 $

[m,n] = size(x);
nc = length(p);
if nargin == 4
   x = (x - mu(1))/mu(2);
end

if numel(x) == 1 && (nargin < 3) && nc>0 && isfinite(x)
    % Make it scream for scalar x.  Polynomial evaluation can be
    % implemented as a recursive digital filter.
    y = filter(1,[1 -x],p);
    y = y(nc);
    return
end

% Use Horner's method for general case where X is an array.
y = zeros(m,n);
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
          error('curvefit:cfpolyval:badMatrixSize', ...
                'S matrix must be n+2-by-n where n = length(p).');
      end
      R = S(1:nc,1:nc);
      df = S(nc+1,1);
      normr = S(nc+2,1);
    end

    % Construct Vandermonde matrix.
    V(:,nc) = ones(length(x),1);
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
        warning('curvefit:cfpolyval:zeroDegreesOfFreedom', ...
                'Zero degrees of freedom implies infinite error bounds.');
        delta = repmat(Inf,size(e));
    else
        delta = normr/sqrt(df)*e;
    end
    delta = reshape(delta,m,n);
end

