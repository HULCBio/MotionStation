function z = sinint(x)
%SININT Sine integral function.
%  SININT(x) = int(sin(t)/t,t,0,x).
%
%  See also COSINT.

%   Copyright 1993-2002 The MathWorks, Inc. 
%  $Revision: 1.11 $  $Date: 2002/04/15 03:13:35 $

z = double(sinint(sym(x)));
