function found = LocalFindStr(h, s1,s2)
% Abstract:
%	Make findstr more robust by requiring that s1 >= s2 in length.
%       This is because findstr find the smaller of the two. If s1 is
%       a space ' ', findstr will return true, but this routine won't.
%   Note: It's not recommended to be overloaded in subclass.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2002/09/23 16:27:17 $

found = (length(s1) >= length(s2) & ~isempty(findstr(s1,s2)));
%endfunction LocalFindStr
