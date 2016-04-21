function hout = newdlg(Client,ParentFig)
%NEWDLG  Constructor for singleton instance of @newdlg
%        (dialog for creating a new constraint).

%   Authors: P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $ $Date: 2004/04/10 23:14:02 $

mlock  % prevents clearing at the command line
persistent h

if isempty(h)
    % Create class instance
    h = plotconstr.newdlg;
	% Build GUI frame
	h.Handles = h.build;
	% Listeners
	h.Listeners = ...
        handle.listener(h,h.findprop('Constraint'),'PropertyPostSet',@LocalUpdateDialog);
end

% Set client 
h.Client = Client;

% Listen to figure being destroyed
f = handle(ParentFig);
DestroyL = handle.listener(f,'ObjectBeingDestroyed',@close);
DestroyL.CallbackTarget = h;
h.Listeners = [h.Listeners(1) ; DestroyL];

% Get list of available constraints for CLIENT and update popup
List = Client.newconstr;
PopUp = h.Handles.TypeSelect;
PopUp.removeAll;
for ct=1:length(List)
    PopUp.add(sprintf(List{ct}));
end
set(PopUp,'UserData',List);
% Initialize dialog for first type in list
h.settype(List{1});

% Make frame visible
Frame = h.Handles.Frame;
Frame.pack;
if ~Frame.isVisible
  % Bring it up centered
  centerfig(Frame,ParentFig);
end
set(Frame,'Minimized','off','Visible','off','Visible','on');

hout = h;

%--------------------- Local functions -----------------------

%%%%%%%%%%%%%%%%%%%%%
% LocalUpdateDialog %
%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateDialog(hSrc,eventData)
% Updates "Contraint Parameters" groupbox when constraint handle changes
h = eventData.AffectedObject;
NewConstr = eventData.NewValue;
if ~isempty(NewConstr)
    s = h.ParamEditor;
    p = h.Handles.ParamBox;
    if ~isempty(s)
        for ct=1:length(s.Panels)
            p.remove(s.Panels{ct}); % trash panels
        end
    end
    p.repaint;
    h.ParamEditor = NewConstr.edit(h.Handles.ParamBox);
    % Redraw
    h.Handles.Frame.pack;
end
