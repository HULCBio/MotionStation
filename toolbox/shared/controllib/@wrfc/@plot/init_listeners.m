function init_listeners(this)
%INIT_LISTENERS  Installs generic listeners for @plot class.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:24 $

AxGrid = this.AxesGrid;
fig    = AxGrid.Parent;
StyleMgr = this.StyleManager;

L = [handle.listener(AxGrid, 'ObjectBeingDestroyed', @LocalDelete); ...
      handle.listener(AxGrid, 'PostLimitChanged',     @LocalAdjustView); ...
      handle.listener(this,   'ObjectBeingDestroyed', @LocalCleanUp); ...
      handle.listener(AxGrid, 'DataChanged', @LocalRedraw); ...
      handle.listener(this, this.findprop('Visible'), ...
      'PropertyPostSet', @LocalRefreshPlot); ...
      handle.listener(fig, fig.findprop('Visible'), ...
      'PropertyPostSet', @LocalRefreshPlot);...
      handle.listener(this, this.findprop('Preferences'), ...
      'PropertyPostSet', @LocalPreferences);...
      handle.listener(StyleMgr, StyleMgr.findprop('Styles'), ...
      'PropertyPostSet', @updatestyle) ];
set(L, 'CallbackTarget', this);

% Listener for figure pre/postsave event
presavelistener = handle.listener(fig,'SerializeEvent',{@LocalPrePostSave this});

% REVISIT: should listen to ClearAxes event (hg.axes) and remove 
% ResponsePlotHandle field from axes appdata.
this.Listeners = [L;presavelistener];

% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Purpose: Pre and Postsave function for creating static plot
% ----------------------------------------------------------------------------%
function LocalPrePostSave(src,eventdata, this)

if strcmp(get(eventdata,'Preserialize'),'on')
    % clear buttondown functions, etc.
    this.SaveData.data = uiclearmode(src,'docontext');
else
    % restore buttondown functions, etc.
    uirestore(this.SaveData.data);
end


% ----------------------------------------------------------------------------%
% Purpose: Adjust view in response to axes limit update
% ----------------------------------------------------------------------------%
function LocalAdjustView(this, eventdata)
if strcmp(this.Visible,'on')
   allwf = allwaves(this);
   if ~isempty(allwf)
      for wf = find(allwf,'Visible','on')'
         adjustview(wf,'postlim')
      end
   end
end


% ----------------------------------------------------------------------------%
% Purpose: Updates visibility of HG objects (axes, curves) when 
%          AxesGrid visibility changes
% ----------------------------------------------------------------------------%
function LocalRefreshPlot(this,eventdata)
% Update component visibility
AxGrid = this.AxesGrid;
if strcmp(this.Visible,'off')
   % on -> off
   % Rely on ContentsVisible property of hg.axes to hide everything
   AxGrid.Visible = 'off';
else
   % off -> on
   % Refresh visibility of HG components (see plot/refresh for rationale)
   refresh(this)
   % Make axes grid visible
   % RE: Turn off limit manager to block ViewChanged callback
   AxGrid.LimitManager = 'off';
   AxGrid.Visible = 'on';
   AxGrid.LimitManager = 'on';
   % Redraw since curves stop tracking data when plot not visible
   % RE: Issues ViewChanged event that triggers limit update
   draw(this)
end


% ----------------------------------------------------------------------------%
% Purpose: Clean up @plot object when @axesgrid object is deleted.
% ----------------------------------------------------------------------------%
function LocalDelete(this, eventdata)
delete(this(ishandle(this)))


% ---------------------------------------------------------------------------% 
% Purpose: Clean up when @plot object is destroyed. 
% ---------------------------------------------------------------------------% 
function LocalCleanUp(this, eventdata) 
delete(this.AxesGrid(ishandle(this.AxesGrid)))  
wfs = allwaves(this);
delete(wfs(ishandle(wfs))) 


% ---------------------------------------------------------------------------% 
% Purpose: Redraw plot when receiving DataChanged event 
%          (e.g., when changing units, toggling Y normalization)
% ---------------------------------------------------------------------------% 
function LocalRedraw(this,eventdata)
% Update labels (e.g., to track new units or transforms)
setlabels(this.AxesGrid)
% Redraw (updates axes contents & limits)
draw(this)


% ---------------------------------------------------------------------------% 
% Purpose: Apply changes to Preferences.
% ---------------------------------------------------------------------------% 
function LocalPreferences(this, eventdata)
Prefs = this.Preferences;

for wf = allwaves(this)'  % @waveform
   syncprefs(wf, Prefs)
end
draw(this);