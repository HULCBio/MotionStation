function s1 = deblankall(s)
%DEBLANKALL Remove leading and trailing blanks from a string.
%   Remove trailing and leading blanks from a string and return the result.
%
%   See also DEBLANK.

%   Jun Wu, 12/21/2000
%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.3 $

%
% remove blanks at either end of the string
%
s = char(s);
if isempty(s)
   s1 = s([]);
else
   % Remove trailing blanks
   s1 = strtrim(s);
end

% [EOF]
