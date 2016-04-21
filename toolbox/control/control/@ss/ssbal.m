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
%	 $Revision: 1.19.4.1 $  $Date: 2002/11/11 22:22:04 $

ni = nargin;
error(nargchk(1,2,ni))
if ni==1, 
   condt = Inf;
else
   condt = max(1,condt);
end

% Not allowed for SS arrays with non uniform state 
% dimension, quick exit when no state
nx = size(sys,'order');
if length(nx)>1,
   error('SSBAL cannot be applied to state-space arrays with varying number of states.')
elseif nx==0,
   t = eye(nx);   
   return
end

% Dimensions
sd = size(sys.d);
ArraySizes = [sd(3:end) 1 1];

% Perform balancing
a = cell2nd(sys.a,0,0);
e = cell2nd(sys.e,0,0);
b = cell2nd(sys.b,0,size(sys.d,2));
c = cell2nd(sys.c,size(sys.d,1),0);
[a,b,c,e,t] = abcbalance(a,b,c,e,condt,'noperm','noscale');

% Update data when actual balancing was performed
if ~isequal(t,eye(nx)),
   sys.a = nd2cell(a,ArraySizes);
   sys.e = nd2cell(e,ArraySizes);
   sys.b = nd2cell(b,ArraySizes);
   sys.c = nd2cell(c,ArraySizes);
   % Delete state names
   sys.StateName(1:nx) = {''};
end


