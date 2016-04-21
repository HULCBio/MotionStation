% tests whether B = t.A or A=t.B (bool=1)

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function [bool,t]=isslfcjg(A,B)

bool=0; t=0;
[rA,cA]=size(A); [rB,cB]=size(B);
if rA==rB & cA==cB,
  maxa=max(max(abs(A)));
  if maxa==0,
     bool=1;
  else
     [i,j]=find(A);
     t=B(i(1),j(1))/A(i(1),j(1));
     bool=(max(max(abs(B-t*A))) <= 100*mach_eps*abs(t)*maxa);
  end
end
