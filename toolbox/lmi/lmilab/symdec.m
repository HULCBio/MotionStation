% X = symdec(m,n)
%
% Forms the MxM  symmetric matrix
%
%           [    n+1    n+2    n+4    ...   ]
%           [    n+2    n+3    n+5    ...   ]
%      X =  [    n+4    n+5    n+6          ]
%           [     :                  .      ]
%           [     :                     .   ]
%
% This function is useful to define symmetric matrix
% variables.
%
% See also  DECINFO.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function X = symdec(m,n)

X=zeros(m); b=n+1;
for i=1:m,
   bn=b+i-1; X(i,1:i)=b:bn; b=bn+1;
end

X=X+X'-diag(diag(X));
