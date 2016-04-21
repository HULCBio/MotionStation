function i = issame(x,y)
%ISSAME Test similarity of two variables.
%
% I = ISSAME(X,Y) tests whether the values of the variables X and Y are the
%     same.  For arbitrary matrices X and Y, ISSAME(X,Y) returns I=1 if
%     double(X)==double(Y).  It returns I=2 if, additionally,
%     ISSTR(X)==ISSTR(Y).  Otherwise, it returns I=0.
%

% R. Y. Chiang & M. G. Safonov 10/25/90
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------

i=0;
if isequal(double(x),double(y)),
   if ~abs(max(isnan(x(:))-isnan(y(:)))),
       i=1;
       if isstr(x)==isstr(y),
          i=2;
       end
   end
end

% ------------- End of ISSAME.M ------------------RYC/MGS 10/25/90 %