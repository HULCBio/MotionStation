function [lowerbounds,upperbounds] = checkconstraints(x,A,LB,UB,ToL)
%CHECKCONSTRINTS determines the active lower and upper consraints with
% 	respect to A, LB and UB with a a specified tolerance 'tol'
% 	
% 	LOWERBOUNDS, UPPERBOUNDS are indices of active constraints w.r.t. lower
% 	and upper bounds (LB and UB)

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2004/01/16 16:50:10 $
%   Rakesh Kumar

%setup the costraint status A*x; we already have LB and UB.
Ax = A*x;
%Check the tolerance with respect to each constraints;
lowerbounds = (abs(LB-Ax)<=ToL);
upperbounds = (abs(Ax-UB)<=ToL);

