function initconstr(Editor, Constr)
%INITCONSTR  Generic initialization of plot constraints.
%
%   Called by editor-specific addconstr.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:02:21 $

% Initialize
Constr.EventManager = Editor.EventManager;
Constr.Zlevel = Editor.zlevel('constraint');
Constr.ButtonDownFcn = {@LocalButtonDownFcn, Constr, Editor};
Constr.TextEditor = plotconstr.tooleditor(Editor.ConstraintEditor,Editor);

% Install generic listeners
% RE: Do after prop. init. for trouble-free undo, and before activation to 
%     enable pre-set listener on Activated
addlisteners(Constr)

% Add listeners connecting the constraint to the Editor environment
L1 = [handle.listener(Constr,'DataChanged',@LocalUpdateLims);...
   handle.listener(Constr.EventManager,'MouseEdit',@LocalReframe)];
set(L1,'CallbackTarget',Editor);
L2 = [handle.listener(Editor.Axes,'PostLimitChanged',@LocalRefresh)];
set(L2,'CallbackTarget',Constr);
Constr.addlisteners([L1;L2]);

% Link constraint to Editor hierarchy 
% RE: Before activating so that editor sees it
Editor.connect(Constr, 'down');


% --------------------------- Local Functions ----------------------------------%

function LocalUpdateLims(Editor,eventData)
% Side effect of constraint's DataChanged event
if strcmp(Editor.EventManager.MouseEditMode,'off')
   % Normal mode: update limits
   updateview(Editor)
end


function LocalReframe(Editor,eventData)
% Callback during dynamic mouse edit
% Reframe axes if edited objects are out of scope and limits are auto range
Axes = Editor.Axes;
WorkingAxes = Axes.EventManager.SelectedContainer;
Data = eventData.Data;
iy = (WorkingAxes==getaxes(Axes));
if any(iy) & (strcmp(Axes.XlimMode,'auto') | strcmp(Axes.YlimMode{iy},'auto'))
   Editor.reframe(WorkingAxes,Data.XExtent,Data.YExtent,Data.X,Data.Y) 
end


function LocalRefresh(Constr,eventData)
% Refreshes constraint display when axes limits change
render(Constr)


function h = LocalButtonDownFcn(hSrc, event, Constr, Editor);
% Sets the ButtonDown callback for constraint objects.
if ~strcmp(Editor.EditMode,'idle')
    % Redirect buttondown event to Editor
    Editor.mouseevent('bd',get(hSrc,'parent'));
else
    % Process locally
    Constr.mouseevent('bd',hSrc);
end