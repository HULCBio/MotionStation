function generic_listeners(this)
%GENERIC_LISTENERS  Installs generic listeners for @respplot class.

%  Author(s): Bora Eryilmaz, P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:32 $

% Base class listeners
% REVISIT: ::addlisteners(this)
init_listeners(this);

% Channel properties
L = [handle.listener(this, this.findprop('ChannelName'),...
      'PropertyPostSet', @rclabel);...
      handle.listener(this, this.findprop('ChannelGrouping'),...
      'PropertyPostSet', @LocalAxesGrouping);...
      handle.listener(this, this.findprop('ChannelVisible'), ...
      'PropertyPostSet', @LocalRefreshPlot)];
set(L, 'CallbackTarget', this);

this.Listeners = [this.Listeners ; L];


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Updates visibility of HG objects (axes, curves) when visible grid changes
% ----------------------------------------------------------------------------%
function LocalRefreshPlot(this,eventdata)
% Updates g-object visibility when axes visibility changes.
if strcmp(this.ChannelGrouping,'all')
   % Visibility of HG objects must be manually adjusted for grouped
   % axes (visibility of parent axes does not change in that case)
   refresh(this)
end

% Pass new settings down to @axesgrid object (issues ViewChanged event)
% RE: Must be done last so that the response curve visibility is properly set 
%     when the limits are updated
this.AxesGrid.RowVisible = eventdata.NewValue;


% ----------------------------------------------------------------------------%
% Purpose: Re-parent the line handles to conform with current AxesGrouping mode.
% ----------------------------------------------------------------------------%
function LocalAxesGrouping(this, eventdata)
% Reparent views and characteristics
Axes = getaxes(this); 
for r=allwaves(this)'
   reparent(r,Axes);
end

% Reparent background lines
nax = length(Axes);
nobj = prod(size(this.BackgroundLines))/nax;
BackLines = reshape(this.BackgroundLines,[nax nobj]);
for ct=1:nax*(nobj>0)
   set(BackLines(ct,:),'Parent',Axes(ct))
end

% Adjust visibility (manual vis. management for grouped axes)
refresh(this)

% Set actual axes grouping.
this.AxesGrid.AxesGrouping = this.ChannelGrouping;
% RE: this last statement triggers call to REFRESH and ViewChanged event
