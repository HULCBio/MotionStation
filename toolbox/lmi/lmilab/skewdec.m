% X = skewdec(m,n)
%
% Forms the MxM skew-symmetric matrix
%
%           [     0    -(n+1)   -(n+2)    ...   ]
%           [    n+1      0     -(n+3)    ...   ]
%      X =  [    n+2     n+3        0           ]
%           [     :                     .       ]
%           [     :                         .   ]
%
% This function is useful to define skew-symmetric
% matrix variables (in this case, set N to the
% number of decision variables already used)
%
% See also  DECINFO, LMIVAR.

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $


function X = skewdec(m,n)

X=zeros(m); b=n+1;
for i=2:m,
   bn=b+i-2; X(i,1:i-1)=b:bn; b=bn+1;
end

X=X-X';
