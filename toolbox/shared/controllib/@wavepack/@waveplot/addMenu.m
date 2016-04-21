function mRoot = addMenu(this,menuType,varargin)
%ADDMENU  Install generic wave plot menus.

%  Author(s): James Owen and P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:27 $

AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
   return
end

% Create menu if it does not already exist
switch menuType
   
case 'channelgrouping'
   % I/O grouping menu
   Size = AxGrid.Size;
   %Assign callbacks and labels
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
      'Label',xlate('Channel Grouping'),'Tag','channelgrouping');
   mSub = [...
         uimenu('Parent',mRoot,'Label',xlate('None'),'Tag','none',...
         'Callback',{@localGroupChannels this 'none'});...
         uimenu('Parent',mRoot,'Label',xlate('All'),'Tag','all',...
         'Callback',{@localGroupChannels this 'all'})];
   %initialize submenus
   set(mSub(strcmpi(this.ChannelGrouping,get(mSub,{'Tag'}))),'checked','on');
   
   %listen to changes in the axesgroup property of the AxesGrid
   L = handle.listener(this,this.findprop('ChannelGrouping'),...
      'PropertyPostSet',{@localSyncGrouping mSub});
   set(mRoot,'Userdata',L);
   
   
case 'channelselector' 
   %if there is no system menu then create it
   mRoot=uimenu('Parent', AxGrid.UIcontextMenu,'Label',xlate('Channel Selector...'),...
      'Callback',{@localCreateSelector this},'Tag','channelselector');
   
case 'waves'
   mRoot = this.addContextMenu('waveforms',this.findprop('Waves'));
   
otherwise
   % Generic @wrfc/@plot menus
   % REVISIT: ::addMenu
   mRoot = this.addContextMenu(menuType);
   
end

% Apply menu settings
if length(varargin)
   set(mRoot,varargin{:})
end

%-------------------- Local Functions ---------------------------

function localCreateSelector(eventSrc,eventData,this)
% Build I/O selector if does not exist
if isempty(this.AxesGrid.AxesSelector)
   this.AxesGrid.AxesSelector = addChannelSelector(this);
end
set(this.AxesGrid.AxesSelector,'visible','on');


function localGroupChannels(eventSrc, eventData,this,newval)
% Set I/O grouping state
this.ChannelGrouping = newval;


function localSyncGrouping(eventSrc,eventData,menuVec)
% Updates I/O Grouping menu check
newGrouping = eventData.Newvalue;
set(menuVec,'checked','off');
set(menuVec(strcmpi(newGrouping,get(menuVec,{'Tag'}))),'checked','on');