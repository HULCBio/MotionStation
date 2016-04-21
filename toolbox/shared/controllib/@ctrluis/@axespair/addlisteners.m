function addlisteners(h,listeners)
%ADDLISTENERS  Installs generic listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:27 $

if nargin==1
   % Initialization. First install generic listeners
   h.generic_listeners;
   
   % Targeted listeners
   p_label = [h.findprop('Title');h.findprop('XLabel');h.findprop('YLabel')];
   p_vis = [h.findprop('Visible');h.findprop('RowVisible');h.findprop('AxesGrouping')];
   L = [handle.listener(h,p_label,'PropertyPostSet',@setlabels);...
         handle.listener(h,p_vis,'PropertyPostSet',@LocalRefresh) ; ...
         handle.listener(h,h.findprop('Geometry'),'PropertyPostSet',@setgeometry)];
   set(L,'CallbackTarget',h);
   
   % Add to list
   h.Listeners = [h.Listeners ; L];
   
else
   % Append new listeners
   h.Listeners = [h.Listeners ; listeners(:)];
end


%------------------------ Local Functions ---------------------------


function LocalRefresh(h,eventdata)
% Adjusts HG axes and label visibility when Visible, RowVisible, or ColumnVisible change
refresh(h);  % always execute to hide axes when h.Visible->off
% Update limits (auto limits may change when visible grid changes)
if strcmp(h.Visible,'on')
   h.send('ViewChanged');
end