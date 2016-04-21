function h = leverage(data,model)
%LEVERAGE Regression diagnostic.
%   H=LEVERAGE(DATA,MODEL) finds the leverage for each row (point) in
%   a regression.  DATA is a matrix of predictor variables for the
%   regression.  The argument MODEL, controls the order of the
%   regression model.  If you omit MODEL, LEVERAGE assumes a linear
%   additive model with a constant term. MODEL can be following strings:
%   'interaction' - includes constant, linear, and cross product terms.
%   'quadratic' - interactions plus squared terms.
%   'purequadratic' - includes constant, linear and squared terms.
%
%   The output H is a vector of leverage values.  Elements of H are
%   the diagonal values of the "hat" matrix X*inv(X'*X)*X', where
%   X is the matrix of term values.
%
%   See also REGSTATS.

%   Reference Goodall, C. R. (1993). Computation using the QR decomposition. 
%   Handbook in Statistics, Volume 9.  Statistical Computing
%   (C. R. Rao, ed.).   Amsterdam, NL: Elsevier/North-Holland.


%   B.A. Jones 1-6-94
%   Copyright 1993-2004 The MathWorks, Inc. 
%   $Revision: 2.12.2.1 $  $Date: 2004/01/24 09:34:17 $

if nargin == 1
  model = 'linear';
end

wasnan = any(isnan(data),2);
if (any(wasnan)), data(wasnan,:) = []; end

X = x2fx(data,model);
[Q, R] = qr(X,0);
E = X/R;
h = sum((E.*E)')';

if (any(wasnan))
   hh = ones(size(wasnan));
   hh(:) = NaN;
   hh(~wasnan) = h;
   h = hh;
end