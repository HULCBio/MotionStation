function show(h,Constr)
%SHOW  Brings up and points edit dialog to a particular constraint.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:09:04 $

% RE: h = @editdlg handle

% Initialize dialog when first used
if isempty(h.Handles)
    % Create dialog
    h.Handles = h.build;
    % Listener to targeted constraint
    h.Listeners = handle.listener(h, h.findprop('Constraint'), ...
        'PropertyPostSet',@LocalUpdateDialog);
end

% Set target (edited constraint)
h.target(Constr);

% Make frame visible
Frame = h.Handles.Frame;
if Frame.isVisible
  % Raise window
  Frame.toFront;
else
  % Bring it up centered
  centerfig(Frame, Constr.Parent.Parent);
  Frame.setVisible(1);
end

%--------------------- Local functions -----------------------

%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDialog %
%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDialog(hSrc,eventData)
% Updates edit dialog when constraint handle changes
h = eventData.AffectedObject;
NewConstr = eventData.NewValue;
if ~isempty(NewConstr)
   % Update parameter box
   s = h.ParamEditor;
   p = h.Handles.ParamBox;
   if ~isempty(s)
      for ct=1:length(s.Panels)
         p.remove(s.Panels{ct}); % trash panels
      end
   end
   h.ParamEditor = NewConstr.edit(h.Handles.ParamBox);
   % Update constraint type display
   set(h.Handles.TypeDescription,'Text',sprintf('%s',NewConstr.describe))
   % Redraw
   h.Handles.Frame.pack;
   
   % Listener to constraint (axes) visibility.
   Axes = h.Constraint.Parent;
   h.TempListeners = ...
      handle.listener(Axes,Axes.findprop('Visible'),'PropertyPostSet',@LocalHide);
   h.TempListeners.CallbackTarget = h;
else
   % Detargeting: remove listeners
   if ~isempty(h.ParamEditor)
      delete(h.ParamEditor.Listeners);
   end
   delete(h.TempListeners);
   h.TempListeners = [];
end


function LocalHide(h,eventdata)
% Hide dialog when axes visibility goes off
if strcmp(eventdata.NewValue,'off')
   h.detarget(h.Constraint)
end