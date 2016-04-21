function uu=pdeuxpd(p,u,dim)
% PDEUXPD Expand solution u to node points
%
%       U=PDEUXPD(P,U) expands a scalar valued U to node points defined by
%       point matrix P.
%       U can be a scalar or a string describing U as a function of x and y.
%
%       U=PDEUXPD(P,U,N) expands U to node points for a system with
%       dimension N (default is 1).
%
%       PDEUXPD returns the expanded U as a column vector of length
%       N * size(P,2).

%       M. Ringh 3-01-95. MR, AN 9-11-95.
%       Copyright 1994-2003 The MathWorks, Inc.
%       $Revision: 1.8.4.1 $  $Date: 2003/11/18 03:12:10 $

if nargin<3,
  dim=1;
end
np=size(p,2);
if ischar(u),
  x=p(1,:)'; y=p(2,:)';
  u=eval(u,'error(''PDE:pdeuxpd:CannotEvalU'', ''unable to evaluate u'')');
end
[n,m]=size(u);
if m==np,
  u=u';
end
u=u(:);
n=length(u);
if n==1,
  n=dim*np;
  uu=u*ones(n,1);
else
  uu=u;
end

if rem(n,np)~=0,
  error('PDE:pdeuxpd:SizeU', 'u must be a scalar or a vector of N*size(p,2).')
end

