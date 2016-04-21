function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:15:53 $

cName='Comment';

if ~isempty(c.att.CommentText)
   strout=sprintf('%s - %s',...
      xlate(cName),...
      xlate(c.att.CommentText{1}));
else
   strout=xlate(cName);
end
