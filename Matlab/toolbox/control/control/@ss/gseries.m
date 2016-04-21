function sys = gseries(sys1,sys2)
%GSERIES  Series connection with a gain.
%
%   Used in SISO Tool, optimized for speed, single model only.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/04 15:17:41 $

if isnumeric(sys1)
   sys = sys2;
   sys.c{1} = sys1 * sys.c{1};
   sys.d = sys1 * sys.d;
else
   sys = sys1;
   sys.b{1} = sys.b{1} * sys2;
   sys.d = sys.d * sys2;
end
