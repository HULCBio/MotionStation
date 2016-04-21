function h = addioselector(this)

% Copyright 2004 The MathWorks, Inc.

nr = length(this.OutputName);
if nr==0
   RowLabels = {''};
else
   if strcmp(this.Type,'inputs') 
       lbl = 'in(%d)';
   elseif strcmp(this.Type,'outputs') 
       lbl = 'out(%d)';
   else
       lbl = 'Ch(%d)';
   end
   for ct=nr:-1:1
      RowLabels(ct,1) = {sprintf(lbl,ct)};
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
this.OutputVisible = OnOff(1+eventdata.NewValue);

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
