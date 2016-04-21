function [c,f,s] = pdex1pde(x,t,u,DuDx)
%PDEX1PDE  Evaluate the differential equations components for the PDEX1 problem.
%
%   See also PDEPE, PDEX1.

%   Lawrence F. Shampine and Jacek Kierzenka
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/15 03:37:37 $

c = pi^2;
f = DuDx;
s = 0;