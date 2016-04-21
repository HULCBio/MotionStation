function u0 = pdex1ic(x)
%PDEX1IC  Evaluate the initial conditions for the problem coded in PDEX1.
%
%   See also PDEPE, PDEX1.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 03:37:41 $

u0 = sin(pi*x);