function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @view object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:38 $
boo = strcmp(get(this,'Visible'),'on');
if ~isempty(this(1).Parent)
   boo = boo & isvisible(this(1).Parent);
end