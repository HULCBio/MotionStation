function varargout = fdaddcontextmenu(hFig,hItem,tagStr)
% FDADDCONTEXTMENU   Add a "What's This?" context menu.
%   FDADDCONTEXTMENU(HFIG,HITEM,TAGSTR) adds a context menu to the
%   uicontrol HITEM, whose parent is HFIG.  TAGSTR is assigned as
%   the tag to the UIMENU

%   Author(s): D. Orofino 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/14 23:51:44 $ 

varargout{1} = cshelpcontextmenu(hFig,hItem,tagStr, 'FDATool');

% [EOF]
