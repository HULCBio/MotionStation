function sys = gseries(sys1,sys2)
%GSERIES  Series connection with a gain.
%
%   Used in SISO Tool, optimized for speed, single model only.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.2 $  $Date: 2002/04/04 15:18:22 $

if isnumeric(sys1) && isequal(size(sys2.k),size(sys1),[1 1])
   % SISO 
   sys = sys2;
   sys.k = sys1 * sys.k;
elseif isnumeric(sys2) && isequal(size(sys1.k),size(sys2),[1 1])
   % SISO 
   sys = sys1;
   sys.k = sys.k * sys2;
else
   sys = sys1 * sys2;
end
