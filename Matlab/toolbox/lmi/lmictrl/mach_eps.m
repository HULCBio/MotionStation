function [val]=mach_eps()
%  val = mach_eps
%
%  Computes the relative machine epsilon. That is, the smallest
%  number VAL such that 1+VAL > 1 at the machine precision.
%  This is equal to the MATLAB constant EPS.


%  Author: P. Gahinet  6/94
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

val=1;
while 1+val > 1, val=val/2.0; end
val=2*val;
