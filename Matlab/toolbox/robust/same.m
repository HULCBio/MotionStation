function i = same(x,y)
%SAME Test similarity of two variable.
%
% I = SAME(X,Y) tests whether the values of the variables X and Y are the
%     same.  For arbitrary matrices X and Y, SAME(X,Y) returns 1 if X and Y
%     are equal or it returns 2 if, additionally, ISSTR(X)==ISSTR(Y);
%     otherwise it returns 0.
%

% R. Y. Chiang & M. G. Safonov 10/25/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

i=0;
if min(size(x)==size(y)),
   if x==y,
       i=1;
       if isstr(x)==isstr(y),
          i=2;
       end
   end
end

% ------------- End of SAME.M ------------------RYC/MGS 10/25/90 %