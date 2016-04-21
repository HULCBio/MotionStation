function uistate = uisuspend(fig)
%UISUSPEND suspends all interactive properties of the figure.
%
%   UISTATE=UISUSPEND(FIG) suspends the interactive properties of a 
%   figure window and returns the previous state in the structure
%   UISTATE.  This structure contains information about the figure's
%   WindowButton* functions and the pointer.  It also contains the 
%   ButtonDownFcn's for all children of the figure.
%
%   See also UIRESTORE.

%   Chris Griffin, 6-19-97
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $ $Date: 2004/04/10 23:34:39 $

% disable plot editing and annotation buttons


uistate = struct(...
        'ploteditEnable', plotedit(fig,'getenabletools'), ...        
        'figureHandle', fig, ...
        'children', findobj(fig), ...
        'WindowButtonMotionFcn', Lwrap(get(fig, 'WindowButtonMotionFcn')), ...
        'WindowButtonDownFcn', Lwrap(get(fig, 'WindowButtonDownFcn')), ...
        'WindowButtonUpFcn', Lwrap(get(fig, 'WindowButtonUpFcn')), ...
        'KeyPressFcn', Lwrap(get(fig, 'KeyPressFcn')), ...
        'Pointer', get(fig, 'Pointer'), ...
        'PointerCdata', get(fig, 'PointerShapeCData'), ...
        'PointerHotSpot', get(fig, 'PointerShapeHotSpot'));

plotedit(fig,'setenabletools','off');
set(fig, 'pointer', get(0, 'DefaultFigurePointer'),...
   'WindowButtonMotionFcn', get(0, 'DefaultFigureWindowButtonMotionFcn'),...
   'WindowButtonDownFcn', get(0, 'DefaultFigureWindowButtonDownFcn'),...
   'WindowButtonUpFcn', get(0, 'DefaultFigureWindowButtonUpFcn'));

uistate.ButtonDownFcns = get(uistate.children, {'buttondownfcn'});
uistate.Interruptible = get(uistate.children, {'Interruptible'});
uistate.BusyAction = get(uistate.children, {'BusyAction'});
set(uistate.children, 'buttondownfcn', '', 'BusyAction', 'Queue', ...
   'Interruptible', 'on');

% wrap cell arrays in another cell array for passing to the struct command
function x = Lwrap(x)
if iscell(x), 
  x = {x}; 
end