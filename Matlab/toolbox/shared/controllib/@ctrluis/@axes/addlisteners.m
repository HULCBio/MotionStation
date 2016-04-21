function addlisteners(h,listeners)
%ADDLISTENERS  Installs generic listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:24 $

if nargin==1
   % Initialization. First install generic listeners
   h.generic_listeners;
   
   % Add @axesgrid-specific listeners
   p_label = [h.findprop('Title');h.findprop('XLabel');h.findprop('YLabel')];
   L1 = handle.listener(h,p_label,'PropertyPostSet',@LocalSetLabelText);
   
   % Visibility
   L2 = [handle.listener(h,h.findprop('Visible'),'PropertyPostSet',@LocalRefresh)];
   set(L2,'CallbackTarget',h);
   
   h.Listeners = [h.Listeners ; L1 ; L2];
else
   % Append new listeners
   h.Listeners = [h.Listeners ; listeners(:)];
end


%------------------------ Local Functions ---------------------------


function LocalSetLabelText(eventsrc,eventdata)
% Sets title, xlabel, or ylabel style
hlabel = get(eventdata.AffectedObject.getaxes,eventsrc.Name);
set(hlabel,'String',eventdata.NewValue);


function LocalRefresh(h,eventdata)
% Adjusts HG axes visibility when Visible prop change
set(h.getaxes,'Visible',h.Visible,'ContentsVisible',h.Visible)
% Adjust labels
setlabels(h)
% Update limits (auto limits may change when visible grid changes)
if strcmp(h.Visible,'on')
   h.send('ViewChanged');
end
