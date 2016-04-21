function uirestore(uistate,kidsOnly)
%UIRESTORE Restores the interactive functionality figure window.
%  UIRESTORE(UISTATE) restores the state of a figure window to
%  what it was before it was suspended by a call to UISUSPEND.
%  The input UISTATE is the structure returned by UISUSPEND which
%  contains information about the window properties and the button
%  down functions for all of the objects in the figure.
%
%  UIRESTORE(UISTATE, 'children') updates ONLY the children of
%  the figure.
%
%  UIRESTORE(UISTATE, 'nochildren') updates ONLY the figure.
%
%  UIRESTORE(UISTATE, 'uicontrols') updates ONLY the uicontrol children
%  of the figure
%
%  UIRESTORE(UISTATE, 'nouicontrols') updates the figure and all non-uicontrol
%  children of the figure
%
%  See also UISUSPEND.

%   Chris Griffin, 6-19-97
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.16 $ $Date: 2002/04/15 03:26:25 $

if ~isempty(uistate.ploteditEnable)
   plotedit(uistate.figureHandle,...
           'setenabletools',uistate.ploteditEnable);
end

updateFigure   = 1;    
updateChildren = 1;
updateUICtrl = 1;

if nargin == 2
    if strcmpi(kidsOnly, 'children');
        updateFigure   = 0;
    elseif strcmpi(kidsOnly, 'nochildren');
        updateChildren = 0;
        updateUICtrl = 0;
    elseif strcmpi(kidsOnly,'uicontrols')
        updateChildren = 0;
    elseif strcmpi(kidsOnly,'nouicontrols')
        updateUICtrl = 0;
    end        
end

% No need to restore anything if the figure isn't there
if ~ishandle(uistate.figureHandle)
    return
% Also no need to restore if the figure is being deleted
elseif strcmp('on',get(uistate.figureHandle,'beingdeleted'))
    return
end

if updateFigure
    set(uistate.figureHandle, 'pointer',uistate.Pointer, ...
        'PointerShapeCData', uistate.PointerCdata, ...
        'PointerShapeHotSpot', uistate.PointerHotSpot, ...
        'KeyPressFcn', uistate.KeyPressFcn, ...
        'WindowButtonMotionFcn', uistate.WindowButtonMotionFcn ,...
        'WindowButtonDownFcn', uistate.WindowButtonDownFcn, ...
        'WindowButtonUpFcn', uistate.WindowButtonUpFcn);
    if isfield(uistate,'docontext')
        if uistate.docontext
            set(uistate.figureHandle,...
                'UIContextMenu', uistate.WindowUIContextMenu);
        end
    end
end

% updating children including uicontrols
if updateChildren & updateUICtrl
    stillAround = ishandle(uistate.children);
    for i=1:length(uistate.children)
        if stillAround(i)
            set(uistate.children(i), ...
                {'buttondownfcn'},uistate.ButtonDownFcns(i), ...
                {'Interruptible'}, uistate.Interruptible(i), ...
                {'BusyAction'}, uistate.BusyAction(i));
            if isfield(uistate,'docontext')
                if uistate.docontext
                    set(uistate.children(i), ...
                        {'UIContextMenu'}, uistate.UIContextMenu(i));
                end
            end
        end
    end


% updating non-uicontol children only
elseif updateChildren
    stillAround = ishandle(uistate.children);
    for i=1:length(uistate.children)
        if stillAround(i)
            if ~strcmp(get(uistate.children(i),'type'),'uicontrol')
                set(uistate.children(i), ...
                    {'buttondownfcn'},uistate.ButtonDownFcns(i), ...
                    {'BusyAction'}, uistate.BusyAction(i), ...
                    {'Interruptible'}, uistate.Interruptible(i));
                if isfield(uistate,'docontext')
                    if uistate.docontext
                        set(uistate.children(i), ...
                            {'UIContextMenu'}, uistate.UIContextMenu(i));
                    end
                end
                    
            end
        end
    end
    
% updating only uicontrol children    
elseif updateUICtrl
    stillAround = ishandle(uistate.children);
    for i=1:length(uistate.children)
        if stillAround(i)
            if strcmp(get(uistate.children(i),'type'),'uicontrol')
                set(uistate.children(i), ...
                    {'buttondownfcn'},uistate.ButtonDownFcns(i), ...
                    {'BusyAction'}, uistate.BusyAction(i), ...
                    {'Interruptible'}, uistate.Interruptible(i));
                if isfield(uistate,'docontext')
                    if uistate.docontext
                        set(uistate.children(i), ...
                            {'UIContextMenu'}, uistate.UIContextMenu(i));
                    end
                end
            end
        end
    end
end
