function H = imtext(x,y,T,justify)
%IMTEXT Place possibly multi-line text as xlabel.
%   IMTEXT(x,y,T) writes T, center justified, with the lower left
%   corner at axis normalized coordinates (x,y).
%   IMTEXT(x,y,T,'center') and IMTEXT(x,y,T,'right) are also possible.
%   H = IMTEXT(...) returns a vector of handles to the lines of text.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.7 $  $Date: 2002/04/15 03:30:14 $

if nargin < 4, justify = 'center'; end
ax = gca;
dely = .04;
[m,n] = size(T);
for k = 1:m
   h(k) = text(x,y,T(k,:),'units','norm','horiz',justify);
   y = y + dely;
end
if nargout > 0
   H = h';
end
