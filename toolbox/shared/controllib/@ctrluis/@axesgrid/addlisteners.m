function addlisteners(h,listeners)
%ADDLISTENERS  Installs generic listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:38 $

if nargin==1
   % Initialization. First install generic listeners
   h.generic_listeners;
   
   % Limit sharing
   p_share = [h.findprop('XLimSharing');h.findprop('YLimSharing')];
   L1 = [handle.listener(h,p_share,'PropertyPostSet',@LocalShareLims)];
      
   % Targeted listeners
   p_label = [h.findprop('Title');...
         h.findprop('XLabel');...
         h.findprop('YLabel');...
         h.findprop('RowLabel');...
         h.findprop('ColumnLabel')];
   p_vis = [h.findprop('Visible');...
         h.findprop('RowVisible');...
         h.findprop('ColumnVisible');...
         h.findprop('AxesGrouping')];
   L2 = [handle.listener(h,p_label,'PropertyPostSet',@setlabels);...
         handle.listener(h,p_vis,'PropertyPostSet',@LocalRefresh);...
         handle.listener(h,h.findprop('Geometry'),'PropertyPostSet',@setgeometry);...
         handle.listener(h, h.findprop('YNormalization'),'PropertyPostSet', @LocalNormalizeY);...
         handle.listener(h,'PostLimitChanged',@LocalAdjustLabelPosition);...
         handle.listener(h,'ObjectBeingDestroyed',@LocalCleanUp);...
         handle.listener(h,h.findprop('Size'),'PropertyPostSet',@resize)];
   set(L2,'CallbackTarget',h);
   
   % Add to list
   h.Listeners = [h.Listeners ; L1 ; L2];
   
   % Style update functions 
   h.RowLabelStyle.UpDateFcn = {@LocalUpdateRCLabel h};
   h.ColumnLabelStyle.UpDateFcn = {@LocalUpdateRCLabel h};
   
else
   % Append new listeners
   h.Listeners = [h.Listeners ; listeners(:)];
end


%------------------------ Local Functions ---------------------------


function LocalRefresh(h,eventdata)
% Adjusts HG axes and label visibility when Visible, RowVisible, or ColumnVisible change
refresh(h);  % always execute to hide axes when h.Visible->off
% Update limits (auto limits may change when visible grid changes)
h.send('ViewChanged');


function LocalUpdateRCLabel(eventsrc,eventdata,h) 
% Update function for row and column label style 
if isvisible(h)
   setlabels(h)  % update style 
end 


function LocalAdjustLabelPosition(h,eventdata)
% Adjusts row and column label position when limits change (PostLimitChanged event).
% A change in limits affects the tick label width, which in turn shifts the row labels
% and changes the gap with row labels and Y label.
% REVISIT: Make sure this does not interfer with fast update (RefreshMode = quick)
labelpos(h)


function LocalShareLims(eventsrc,eventdata)
% PostSet for X and Y limit sharing properties
h = eventdata.AffectedObject;
if isvisible(h) & any(strcmp(eventdata.NewValue,{'all','peer'}))
   % Enforce uniform X or Y limit modes
   h.sharemode(eventsrc.Name(1));
   % Update limits
   h.send('ViewChanged')
end


function LocalCleanUp(h,eventdata)
% Clean up when object destroyed (@axesgrid-specific tasks)
% Selector
delete(h.AxesSelector(ishandle(h.AxesSelector)))


function LocalNormalizeY(h,eventdata)
% Toggle Y normalization
ax = getaxes(h);
% Reset YLimMode to auto (could also convert Y limits...)
h.LimitManager = 'off';
h.YlimMode = 'auto';
h.LimitManager = 'on';
% Issue data changed event (notifies clients to redraw - includes tick adjustment)
h.send('DataChanged')
