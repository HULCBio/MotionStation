function show(h,varargin)
%SHOW  Brings up and points dialog to a particular container/constraint.

%   Authors: Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:06:37 $

% Initialize when first used
if isempty(h.Handles)
    % Build GUI frame
    h.Handles = h.build;
    % Listeners
    Containers = h.ContainerList;
    h.Listeners = [...
            handle.listener(h, h.findprop('Container'), ...
            'PropertyPostSet', @LocalContainer) ; ...
            handle.listener(h, h.findprop('Constraint'), ...
            'PropertyPostSet', @LocalConstraint); ...
            handle.listener(Containers, Containers(1).findprop('Visible'), ...
            'PropertyPostSet', @LocalVisible); ...
            handle.listener(h, 'ObjectBeingDestroyed', @LocalDestroy)];
    set(h.Listeners, 'CallbackTarget', h);
end

% Target editor
h.target(varargin{:});

% Make frame visible
Frame = h.Handles.Frame;
Frame.repaint;
if Frame.isVisible
  % Raise window
  Frame.toFront;
else
  % Bring it up
  centerfig(h.Handles.Frame, h.Constraint.Parent.Parent);
  Frame.setVisible(1);
end


% --------------------------------------------------------------------------- %
% Callback Functions
% --------------------------------------------------------------------------- %

% --------------------------------------------------------------------------- %
% Function: LocalContainer
% Purpose:  Logic to update container choice list. Triggered when container changes
% --------------------------------------------------------------------------- %
function LocalContainer(h, eventData)
if ~isempty(eventData.NewValue)
    % Update container list
    h.refresh('Containers');
end


% --------------------------------------------------------------------------- %
% Function: LocalConstraint
% Purpose:  Logic to update constraint parameter box.
% --------------------------------------------------------------------------- %
function LocalConstraint(h, eventData)
if ~isempty(eventData.NewValue) 
    % Update constraint popup list
    h.refresh('Constraints');

    % Update parameter box
    LocalConstraintBox(h);
    
    % Turn markers on for edited constraint
    h.Constraint.Selected = 'on';
    
    % Listener to Constraint move/resize using mouse.
    h.TempListeners = ...
        handle.listener(h.Constraint, 'DataChanged', {@LocalConstraintsText h});
else
    % Detargeting: remove listeners
    if ~isempty(h.ParamEditor)
        delete(h.ParamEditor.Listeners);
    end
    delete(h.TempListeners);
    h.TempListeners = [];
end


% --------------------------------------------------------------------------- %
% Function: LocalVisible
% Purpose:  Logic to update container list when any containter's visibility
%           changes.
% --------------------------------------------------------------------------- %
function LocalVisible(h, eventData)
% Current container list
if h.isVisible
    if isequal(h.Container,eventData.AffectedObject)
        % Targeted container is going invisible: retarget to first valid container
        h.target;
    else
        % Just update container list
        h.refresh('Containers');
    end
end


% --------------------------------------------------------------------------- %
% Function: LocalConstraintsText
% Purpose:  Updates text for selected item in constraint popup.
% --------------------------------------------------------------------------- %
function LocalConstraintsText(eventSrc, eventData, h)
% Get the choice list handle
PopUp = h.Handles.ConstrSelect;
index = find(h.ConstraintList==h.Constraint);
PopUp.setItem(sprintf(h.ConstraintList(index).describe('detail')), index-1);
PopUp.repaint;


% --------------------------------------------------------------------------- %
% Function: LocalConstraintBox
% Purpose:  Updates constraint editor parameter box.
% --------------------------------------------------------------------------- %
function LocalConstraintBox(h)
% Clean-up the parameter box
ParamBox = h.Handles.ParamBox;
ParamBox.removeAll;
% Update parameters box content
h.ParamEditor = h.Constraint.edit(ParamBox);
h.Handles.Frame.pack;


% --------------------------------------------------------------------------- %
% Purpose:  Deletes the editor dialog.
% --------------------------------------------------------------------------- %
function LocalDestroy(h, eventData)
% Hide and destroy dialog
h.Handles.Frame.hide;
h.Handles.Frame.dispose;
