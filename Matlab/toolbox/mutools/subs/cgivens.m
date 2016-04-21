% function [c,s] = cgivens(x,y)
%
%  produces a Givens rotation such that
%			| c        s |   | x |     | z |
%			|            | * |   |  =  |   |
%			|-conj(s)  c |   | y |     | 0 |
%
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [c,s] = cgivens(x,y)
if abs(x) == 0.0
  c = 0;
  s = 1;
  return
end
if abs(y) == 0.0
  c=1.0;
  s=0.0;
  return
end
nrm = norm([x y]);
k1 = x/abs(x);
c = abs(x)/nrm;
s = k1*y'/nrm;
%
%