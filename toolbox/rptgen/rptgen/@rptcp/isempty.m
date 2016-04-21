function tf=isempty(p)
%ISEMPTY true for empty component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:44 $

if length(p.h)<1
   tf=logical(1);
elseif ishandle(p.h)
   allComps=get(p.h,'UserData');
   if ~iscell(allComps)
      tf=~isa(allComps,'rptcomponent');
   else
      tf=cellfun('isclass',...
         allComps,'rptcomponent');
   end
else
   tf=logical(1);
end
