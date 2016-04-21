function tf=isempty(p)
%ISEMPTY returns true for empty object

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:24 $

if length(p.h)<1
   tf=logical(1);
elseif ishandle(p.h)
   tf=~isa(get(p.h,'UserData'),'rptsetupfile');
else
   tf=logical(1);
end
