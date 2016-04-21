function [a,e,s,p] = aebalance(a,e,varargin)
%AEBALANCE  Balances (A,E) pair.
%
%   [A,E,S,P] = AEBALANCE(A,E) returns the balanced
%   (T\A*T,T\E*T) together with the scaling S and
%   permutation P such that T(:,P) = diag(S).
%  
%   [A,E,S,P] = AEBALANCE(A,E,'noperm') performs 
%   scaling only (may lead to small 1-norm).
%
%   LOW-LEVEL UTILITY.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2002/11/11 22:23:07 $

n = size(a,1);
if isempty(e)
   [s,p,a] = balance(a,varargin{:});
else
   na = norm(a-diag(diag(a)),1);
   ne = norm(e-diag(diag(e)),1);
   if na>0 && ne>0
      [s,p,junk] = balance(ne*abs(a)+na*abs(e),varargin{:});
   else
      [s,p,junk] = balance(abs(a)+abs(e),varargin{:});
   end
   a(p,p) = lrscale(a,1./s,s);   % T\A*T
   e(p,p) = lrscale(e,1./s,s);   % T\E*T
end