function g = givens(x,y)
%GIVENS Givens rotation matrix.
%   G = GIVENS(x,y) returns the complex Givens rotation matrix
%
%       | c       s |                  | x |     | r |
%   G = |           |   such that  G * |   |  =  |   |
%       |-conj(s) c |                  | y |     | 0 |
%
%   where c is real, s is complex, and c^2 + |s|^2 = 1. 
 
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10 $  $Date: 2002/04/10 06:33:23 $

absx = abs(x);
if absx == 0.0
    c = 0.0; s = 1.0;
else
    nrm = norm([x y]);
    c = absx/nrm;
    s = x/absx*(conj(y)/nrm);
end
g = [c s;-conj(s) c];
