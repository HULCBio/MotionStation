function CMenu = addmenu(Constr, SISOfig)
%ADDMENU  Creates a common right-click context menu for the constraint objects.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/06/17 12:50:38 $


% Define a right click context menu for the constraint
CMenu = uicontextmenu('Parent', SISOfig);
uimenu(CMenu, 'Label', xlate('Edit...'), 'Callback', {@LocalEdit Constr});
uimenu(CMenu, 'Label', xlate('Delete'),  'Callback', {@LocalDelete Constr});


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalEdit
% Edit the constraint
% ----------------------------------------------------------------------------%
function LocalEdit(eventSrc, eventData, Constr)
Constr.TextEditor.show(Constr);

% ----------------------------------------------------------------------------%
% Function: LocalDelete
% Delete the constraint
% ----------------------------------------------------------------------------%
function LocalDelete(eventSrc, eventData, Constr)
% Delete constraint
EventMgr = Constr.EventManager;
% Start recording
T = ctrluis.transaction(Constr,'Name','Delete Constraint',...
    'OperationStore','on','InverseOperationStore','on');
% Delete constraint
delete(Constr)
% Commit and stack transaction
EventMgr.record(T);
