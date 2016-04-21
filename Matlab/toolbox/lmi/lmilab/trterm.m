% Called by PARSLMI
% searches for the transpose of a given term in blck

% Authors: P. Gahinet and A. Nemirovski 3/95
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function tt=trterm(A,X,B,sgn)

tt=[];
lb=length(B);
if lb>0, if B(lb)=='''', tt=[B(1:lb-1) '*']; else tt=[B '''*']; end,end

tt=[tt strrep(X,'''''','''')];

la=length(A);
if la>0, if A(la)=='''', tt=[tt '*' A(1:la-1)];
         else            tt=[tt '*' A '''']; end
end
if sgn=='-', tt=['-' tt]; end

