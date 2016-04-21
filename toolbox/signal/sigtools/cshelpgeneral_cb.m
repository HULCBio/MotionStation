function cshelpgeneral_cb(hco, eventStruct, toolname)
%CSHELPGENERAL_CB Callback of the "What's This?" toolbar button and help menu item.
%   CSHELPGENERAL_CB(HCO, EVENTSTRUCT, TOOLNAME) when called from a callback
%   mimics the context-menu help selection, but allows cursor-selection of 
%   the help topic. TOOLNAME defines which TOOLNAME_help.m file could be used in
%   determining the documentation mapping.
%
%   See also CSHELPCONTEXTMENU, CSHELPENGINE, RENDER_CSHELPBTN

%   Author(s): V.Pellissier
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:52:49 $


hFig = gcbf;
cshelp(hFig);
set(handle(hFig),'cshelpmode','on');
set(hFig,'HelpFcn',{@figHelpFcn, toolname});

% --------------------------------------------------------------
function figHelpFcn(hco,eventStruct, toolname)
% figHelpFcn Figure Help function called from either
%   the menu-based "What's This?" function, or the toolbar icon.

hFig  = gcbf;
hOver = gco;  % handle to object under pointer

% Dispatch to context help:
hc = get(hOver,'uicontextmenu');
hm = get(hc,'children');  % menu(s) pointed to by context menu

% Multiple entries (children) of context-menu may be present
% Tag is a string, but we may get a cell-array of strings if
% multiple context menus are present:
% Find 'What's This?' help entry
tag = get(hm,'tag');
helpIdx = find(strncmp(tag,'WT?',3));
if ~isempty(helpIdx),
    % in case there were accidentally multiple 'WT?' entries,
    % take the first (and hopefully, the only) index:
    if iscell(tag),
	    tag = tag{helpIdx(1)};
    end
	cshelpengine([],[],toolname,tag);
end
set(handle(hFig),'cshelpmode','off');

% [EOF]
