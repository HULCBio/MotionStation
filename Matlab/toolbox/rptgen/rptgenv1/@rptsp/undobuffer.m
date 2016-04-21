function h=undobuffer(p)
%UNDOBUFFER returns a handle to the report generator undo buffer

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:17:35 $

undotag='RPTGEN_UNDO_BUFFER';

h=findobj(allchild(p.h),'flat',...
   'type','uimenu',...
   'tag',undotag);
if ~isempty(h)
   h=h(1);
else
   h=uimenu('tag',undotag,...
      'UserData',5,...
      'Label','UndoBuffer',...
      'Parent',p.h);
end