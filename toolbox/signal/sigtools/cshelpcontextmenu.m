function varargout = cshelpcontextmenu(hFig, hItem, tagStr, toolname)
%CSHELPCONTEXTMENU   Add a "What's This?" context menu.
%   HC = CSHELPCONTEXTMENU(HITEM,TAGSTR,TOOLNAME) adds a context menu to
%   the uicontrol HITEM.  TAGSTR is assigned as the tag to the UIMENU.
%   TOOLNAME defines which TOOLNAME_help.m file could be used in
%   determining the documentation mapping. The handle to  the contextmenu
%   is returned.
%
%   See also CSHELPENGINE, CSHELPGENERAL_CB, RENDER_CSHELPBTN

%   Author(s): D.Orofino, V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:31:32 $ 

if ischar(hItem),
    error(nargchk(3,4,nargin));
    toolname = tagStr;
    tagStr   = hItem;
    hItem    = hFig;
    hFig     = get(hItem(1), 'Parent');
else
    error(nargchk(4,5,nargin));
end

hc = uicontextmenu('parent', hFig);
tag = ['WT?' tagStr];
uimenu('Label', 'What''s This?',...
	'Callback', {@cshelpengine,toolname,tag}, ...
	'Parent', hc,...
	'Tag', tag);

set(hItem,'uicontextmenu',hc);

if nargout >= 1
    varargout{1} = hc;
end

% [EOF]
