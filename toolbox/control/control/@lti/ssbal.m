function [sys,t] = ssbal(sys,condt)
%SSBAL  Balancing of state-space model using diagonal similarity.
%
%   [SYS,T] = SSBAL(SYS) uses BALANCE to compute a diagonal similarity 
%   transformation T such that [T*A/T , T*B ; C/T 0] has approximately 
%   equal row and column norms.  
%
%   [SYS,T] = SSBAL(SYS,CONDT) specifies an upper bound CONDT on the 
%   condition number of T.  By default, T is unconstrained (CONDT=Inf).
%
%   For arrays of state-space models with uniform number of states, 
%   SSBAL computes a single transformation T that equalizes the 
%   maximum row and column norms across the entire array.
%
%   See also BALREAL, SS.

%   Authors: P. Gahinet and C. Moler, 4-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.7 $  $Date: 2002/04/10 05:48:00 $

error('Only meaningful for State-Space models.')
