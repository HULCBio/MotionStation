function mRoot = addBodeMenu(this,menuType)
%ADDMENU  Install Bode-specific response plot menus.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:12 $

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
   return
end

switch menuType
   
case 'show'
   % Show mag/phase
      mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
         'Label',xlate('Show'),'Tag','show');
      % Submenus
      mSub = [...
            uimenu('Parent',mRoot,'Label',xlate('Magnitude'),...
            'Callback',{@localToggleMag this},'Checked',this.MagVisible);...
            uimenu('Parent',mRoot,'Label',xlate('Phase'),...
            'Callback',{@localTogglePhase this},'Checked',this.PhaseVisible)];
      
      %listen to changes in the axesgroup property of the AxesGrid
      mp = [this.findprop('MagVisible');this.findprop('PhaseVisible')];
      L = handle.listener(this,mp,...
         'PropertyPostSet',{@localSyncMagPhaseVis mSub});
      set(mRoot,'Userdata',L);
   
end


%-------------------- Local Functions ---------------------------

function localToggleMag(eventSrc,eventData,rplot)
% Toggles visibility of particular response
if strcmp(rplot.MagVisible,'off')
   rplot.MagVisible = 'on';
elseif strcmp(rplot.PhaseVisible,'on')  
   % RE: Don't turn both off (no way to get back to right-click menu)
   rplot.MagVisible = 'off';
end

function localTogglePhase(eventSrc,eventData,rplot)
% Toggles visibility of particular response
if strcmp(rplot.PhaseVisible,'off')
   rplot.PhaseVisible = 'on';
elseif strcmp(rplot.MagVisible,'on')
   rplot.PhaseVisible = 'off';
end


function localSyncMagPhaseVis(eventSrc,eventData,m)
% Updates Systems menu check
rplot = eventData.AffectedObject;
set(m(1),'Checked',rplot.MagVisible)
set(m(2),'Checked',rplot.PhaseVisible)