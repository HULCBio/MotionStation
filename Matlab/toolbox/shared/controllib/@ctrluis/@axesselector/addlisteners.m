function addlisteners(h,L)
%ADDLISTENERS  Installs listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:37 $

if nargin==1
   % Targeted listeners
   prc = [h.findprop('RowName');h.findprop('ColumnName');...
         h.findprop('RowSelection');h.findprop('ColumnSelection')];
   L = [handle.listener(h,prc,'PropertyPostSet',@update);...
         handle.listener(h,h.findprop('Name'),'PropertyPostSet',@LocalUpdateName);...
         handle.listener(h,h.findprop('Visible'),'PropertyPostSet',@LocalSetVisible);...
         handle.listener(h,'ObjectBeingDestroyed',@LocalCleanUp)];
   set(L,'CallbackTarget',h);
end
% Add to list
h.Listeners = [h.Listeners ; L];

%------------------------ Local Functions ---------------------------

function LocalSetVisible(this,eventdata)
% Makes selector visible
if strcmp(eventdata.NewValue,'on')
   % Sync GUI with selector state
   update(this);
end  
set(this.Handles.Figure,'Visible',eventdata.NewValue)

function LocalUpdateName(this,eventdata)
% Updates row, column, and figure name
set(this.Handles.Figure,'Name',this.Name)

function LocalCleanUp(this,eventdata)
% Delete figure
if ishandle(this.Handles.Figure)
   delete(this.Handles.Figure)
end

