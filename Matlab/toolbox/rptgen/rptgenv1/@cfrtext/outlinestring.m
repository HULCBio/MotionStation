function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:13:58 $

dispText=c.att.Content;
if isempty(dispText)
   dispText='<No Text>';
elseif iscell(dispText)
   dispText=dispText{1};
elseif size(dispText,1)>1
   dispText=dispText(1,:);
end
if length(dispText)>32
   dispText=[dispText(1:32) '...'];
end


strout=sprintf('Text - %s', dispText);
   
