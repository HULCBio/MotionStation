function [pl,ql,pr,qr] = pdex1bc(xl,ul,xr,ur,t)
%PDEX1BC  Evaluate the boundary conditions for the problem coded in PDEX1.
%
%   See also PDEPE, PDEX1.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 03:37:45 $

pl = ul;
ql = 0;
pr = pi * exp(-t);
qr = 1;