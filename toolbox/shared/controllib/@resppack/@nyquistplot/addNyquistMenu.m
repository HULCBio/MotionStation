function mRoot = addNyquistMenu(this,menuType)
%ADDNYQUISTMENU  Install Nyquist-specific response plot menus.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:39 $

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
   return
end

switch menuType
   
case 'zoomcritical'
   % Zoom around critical point
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
      'Label',xlate('Zoom on (-1,0)'),'Tag','zoomcritical',...
      'Callback',{@LocalZoomCP this});
   
case 'show'
   % Show menu
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
      'Label',xlate('Show'),'Tag','show');
   mSub = uimenu('Parent',mRoot,'Label',xlate('Negative Frequencies'),...
      'Checked',this.ShowFullContour,...
      'Callback',{@LocalToggleContourVis this});
   L = handle.listener(this,findprop(this,'ShowFullContour'),...
      'PropertyPostSet',{@LocalSyncContourVis mSub});
   set(mSub,'UserData',L)
   
end


%-------------------- Local Functions ---------------------------

function LocalZoomCP(eventSrc,eventData,this)
% Zoom on critical point
AxGrid = this.AxesGrid;
AxGrid.LimitManager = 'off';  %  disable listeners to HG axes limits
% Frame scene
updatelims(this,'critical')
% Notify of limit change
AxGrid.send('PostLimitChanged')
AxGrid.LimitManager = 'on';


function LocalToggleContourVis(eventSrc,eventData,this)
% Toggles visibility of negative freqs
if strcmp(this.ShowFullContour,'on')
   this.ShowFullContour = 'off';
else
   this.ShowFullContour = 'on';
end
% Redraw
draw(this)


function LocalSyncContourVis(eventSrc,eventData,hMenu)
set(hMenu,'Checked',eventData.NewValue)