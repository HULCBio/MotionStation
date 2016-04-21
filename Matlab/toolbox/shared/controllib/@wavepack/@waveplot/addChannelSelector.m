function h = addChannelSelector(this)
%ADDCHANNELSELECTOR  Builds I/O selector for response plot.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:26 $

nr = length(this.ChannelName);
if nr==0
   RowLabels = {''};
else
   for ct=nr:-1:1
      RowLabels(ct,1) = {sprintf('Ch(%d)',ct)};
   end
end

% Build selector
h = ctrluis.axesselector([max(1,nr),1],...
   'Name','Channel Selector',...
   'RowName',RowLabels,...
   'ColumnName',{''});

% Center dialog
centerfig(h.Handles.Figure,this.AxesGrid.Parent);

% Install listeners that keep selector and response plot in sync
L1 = [handle.listener(h,h.findprop('RowSelection'),'PropertyPostSet',{@LocalSetRCVisible this});...
      handle.listener(this,this.findprop('ChannelVisible'),'PropertyPostSet',{@LocalSetSelection h})];
L2 = [handle.listener(this,'ObjectBeingDestroyed',@LocalDelete);...
      handle.listener(this,this.findprop('Visible'),'PropertyPostSet',@LocalSetVisible)];
set(L2,'CallbackTarget',h);
h.addlisteners([L1;L2])

%------------------ Local Functions -------------------------------

function LocalSetRCVisible(eventsrc,eventdata,this)
OnOff = {'off','on'};
this.ChannelVisible = OnOff(1+eventdata.NewValue);

function LocalSetSelection(eventsrc,eventdata,h)
h.RowSelection = strcmp(eventdata.NewValue,'on');

function LocalDelete(h,eventdata)
if ishandle(h.Handles.Figure)
   delete(h.Handles.Figure)
end
delete(h)

function LocalSetVisible(h,eventdata)
% REVISIT: push/pop would be better
if strcmp(eventdata.NewValue,'off')
   h.Visible = 'off';
end
