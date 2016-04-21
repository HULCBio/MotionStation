function active = activecstr(x,A,LB,UB,ToL)
%ACTIVECSTR determines the active consraints with
% 	respect to A, LB and UB with a a specified tolerance 'tol'

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2004/01/16 16:51:04 $


%setup the costraint status A*x; we already have LB and UB.
Ax = A*x;
%Check the tolerance with respect to each constraints;
lowerbounds = (abs(LB-Ax)<=ToL);
upperbounds = (abs(Ax-UB)<=ToL);

active = any(lowerbounds) || any(upperbounds);