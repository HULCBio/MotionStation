function [p,S,mu] = polyfit(x,y,n)
%POLYFIT Fit polynomial to data.
%   POLYFIT(X,Y,N) finds the coefficients of a polynomial P(X) of
%   degree N that fits the data, P(X(I))~=Y(I), in a least-squares sense.
%
%   [P,S] = POLYFIT(X,Y,N) returns the polynomial coefficients P and a
%   structure S for use with POLYVAL to obtain error estimates on predictions.
%   P is a row vector of length N+1 containing the polynomial coefficients
%   in descending powers, P(1)*X^N + P(2)*X^(N-1) +...+ P(N)*X + P(N+1).
%   If the errors in the data, Y, are independent normal with constant 
%   variance, POLYVAL will produce error bounds which contain at least 50% of 
%   the predictions.
%
%   The structure S contains the Cholesky factor of the Vandermonde
%   matrix (R), the degrees of freedom (df), and the norm of the
%   residuals (normr) as fields.   
%
%   [P,S,MU] = POLYFIT(X,Y,N) finds the coefficients of a polynomial
%   in XHAT = (X-MU(1))/MU(2) where MU(1) = mean(X) and MU(2) = std(X).
%   This centering and scaling transformation improves the numerical
%   properties of both the polynomial and the fitting algorithm.
%
%   Warning messages result if N is >= length(X), if X has repeated, or
%   nearly repeated, points, or if X might need centering and scaling.
%
%   Class support for inputs x,y:
%      float: double, single
%
%   See also POLY, POLYVAL, ROOTS.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.17.4.4 $  $Date: 2004/03/02 21:47:57 $

% The regression problem is formulated in matrix format as:
%
%    y = V*p    or
%
%          3  2
%    y = [x  x  x  1] [p3
%                      p2
%                      p1
%                      p0]
%
% where the vector p contains the coefficients to be found.  For a
% 7th order polynomial, matrix V would be:
%
% V = [x.^7 x.^6 x.^5 x.^4 x.^3 x.^2 x ones(size(x))];

if ~isequal(size(x),size(y))
    error('MATLAB:polyfit:XYSizeMismatch',...
          'X and Y vectors must be the same size.')
end

x = x(:);
y = y(:);

if nargout > 2
   mu = [mean(x); std(x)];
   x = (x - mu(1))/mu(2);
end

% Construct Vandermonde matrix.
V(:,n+1) = ones(length(x),1,class(x));
for j = n:-1:1
   V(:,j) = x.*V(:,j+1);
end

% Solve least squares problem, and save the Cholesky factor.
[Q,R] = qr(V,0);
ws = warning('off','all'); 
p = R\(Q'*y);    % Same as p = V\y;
warning(ws);
if size(R,2) > size(R,1)
   warning('MATLAB:polyfit:PolyNotUnique', ...
       'Polynomial is not unique; degree >= number of data points.')
elseif condest(R) > 1.0e10
    if nargout > 2
        warning('MATLAB:polyfit:RepeatedPoints', ...
            'Polynomial is badly conditioned. Remove repeated data points.')
    else
        warning('MATLAB:polyfit:RepeatedPointsOrRescale', ...
            ['Polynomial is badly conditioned. Remove repeated data points\n' ...
            '         or try centering and scaling as described in HELP POLYFIT.'])
    end
end
r = y - V*p;
p = p.';          % Polynomial coefficients are row vectors by convention.

% S is a structure containing three elements: the Cholesky factor of the
% Vandermonde matrix, the degrees of freedom and the norm of the residuals.

S.R = R;
S.df = length(y) - (n+1);
S.normr = norm(r);
