%  M=ve2ma(V,type,struct)
%
%  Transforms a vector V obtained with MA2VE back into a
%  matrix.
%
%  Input:
%    V           vector form of the matrix M as obtained with MA2VE
%    TYPE        specifies the structure of M
%                   1 -> symmetric block diagonal
%                   2 -> full rectangular
%    STRUCT      Only for TYPE = 2:
%                   set  STRUCT = [P, Q]  to make M a PxQ matrix

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [M]=ve2ma(V,type,struct)

if nargin < 2 | (nargin < 3 & type==2),
   error('usage: M = ve2ma(V,type,struct)');
end

M=[];

if isempty(V),
elseif type==1,

  n=floor(sqrt(2*length(V)));   % row size of M
  if length(V)~=n*(n+1)/2,
    error('The length of V is incompatible with the prescribed structure');
  end

  M=zeros(n); ind=0;
  for i=1:n, for j=1:i,
    ind=ind+1; val=V(ind);
    M(i,j)=val; M(j,i)=val;
  end, end

else

  r=struct(1); c=struct(2);
  if length(V)~=r*c,
     error('The length of V is incompatible with the dimensions of M');
  end

  M=zeros(c,r);
  M(:)=V;
  M=M';

end
