function y = quant(x,q)
%QUANT Discretize values as multiples of a quantity.
%
%  Syntax
%
%    quant(x,q)
%
%  Description
%
%    QUANT(X,Q) takes these inputs,
%      X - Matrix, vector or scalar.
%      Q - Minimum value.
%    and returns values in X rounded to nearest multiple of Q
%  
%  Examples
%
%    x = [1.333 4.756 -3.897];
%    y = quant(x,0.1)

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.10 $  $Date: 2002/04/14 21:33:02 $

y = round(x/q)*q;
