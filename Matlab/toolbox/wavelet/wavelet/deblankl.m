function s = deblankl(x)
%DEBLANKL Convert string to lowercase without blanks.
%   S = DEBLANKL(X) is the string X converted to lowercase 
%   without blanks.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-May-96.
%   Last Revision: 25-May-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
% $Revision: 1.10.4.2 $

if ~isempty(x)
    s = lower(x);
    s = s(s~=' ');
else
    s = [];
end
