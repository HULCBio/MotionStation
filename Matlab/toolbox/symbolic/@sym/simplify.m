function r = simplify(s)
%SIMPLIFY Symbolic simplification.
%   SIMPLIFY(S) simplifies each element of the symbolic matrix S.
%
%   Examples: 
%      simplify(sin(x)^2 + cos(x)^2) is 1 .
%      simplify(exp(c*log(sqrt(alpha+beta))))
%
%   See also SIMPLE, FACTOR, EXPAND, COLLECT.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:11:42 $

r = maple('map','simplify',s);
