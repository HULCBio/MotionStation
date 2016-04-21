function s = strip_trailing_new_lines(s)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.5.2.1.6.1 $  $Date: 2004/04/13 03:12:39 $

if isempty(s)
	return;
else
   while ~isempty(s) && ((s(end)==10) || (s(end) == 0) || (s(end) == 13))
	   s(end) = [];
	end
end
