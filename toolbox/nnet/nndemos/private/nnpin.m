function y = nnpin(x,a,b,q)
%NNPIN Neural Network Design utility function.

%  NNPIN(X,A,B,Q)
%    X - Number or matrix.
%    A - Lower bound.
%    B - Upper bound.
%    Q - Quantization constant (optional).
%  Returns values in X pinned into the interval defined
%  by A and B and rounded to the nearest multiple of Q.

% Copyright 1994-2002 PWS Publishing Company and The MathWorks, Inc.
% $Revision: 1.7 $
% First Version, 8-31-95.

%==================================================================

y = max(a,min(b,x));
y = round(y/q)*q;
