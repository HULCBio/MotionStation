function mRoot = addMenu(this,menuType,varargin)
%ADDMENU  Adds response plot menu.
%
%   hMENU = ADDMENU(rPlot,MenuType) adds or finds a menu hMENU of
%   type MENUTYPE.  Built-in menu types for response plots include:
%      'arrayselector'      launch array selector GUI
%      'characteristics'    plot characteristics
%      'fullview'           zoom out
%      'grid'               toggle grid on/off
%      'iogrouping'         group axes
%      'ioselector'         launch I/O selector GUI
%      'normalize'          normalize plot data (time plots only)
%      'responses'          toggle response visibility
%      'properties'         launch property editor
%
%   HMENU = ADDMENU(rPlot,MenuType,'Property1',Value1,...)
%   further specifies settings for the menu HMENU.
   
%  Author(s): James Owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:26 $

% Create or identify (if one already exists) a context menu for a @respplot object
% of type menuType. Return an array of handles m, where m(1) identifies the parent
% context menu of type menuType, and m(2:end) are handles to the children of m(1).
AxGrid = this.AxesGrid;
mRoot = AxGrid.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(mRoot)
   return
end

% Create menu if it does not already exist
switch menuType
   
case 'iogrouping'
   % I/O grouping menu
   mRoot = uimenu('Parent',AxGrid.UIcontextMenu,...
      'Label',xlate('I/O Grouping'),'Tag','iogrouping');
   mSub = [...
         uimenu('Parent',mRoot,'Label',xlate('None'),'Tag','none',...
         'Callback',{@localGroupIOs this 'none'});...
         uimenu('Parent',mRoot,'Label',xlate('All'),'Tag','all',...
         'Callback',{@localGroupIOs this 'all'});...
         uimenu('Parent',mRoot,'Label',xlate('Outputs'),'Tag','outputs',...
         'Callback',{@localGroupIOs this 'outputs'});...
         uimenu('Parent',mRoot,'Label',xlate('Inputs'),'Tag','inputs',...
         'Callback',{@localGroupIOs this 'inputs'})];
   % Initialize submenus
   set(mSub(strcmpi(this.IOGrouping,get(mSub,{'Tag'}))),'checked','on');
   
   % Listen to changes in the axesgroup property of the AxesGrid
   L = handle.listener(this,this.findprop('IOGrouping'),...
      'PropertyPostSet',{@localSyncIOGrouping mSub});
   set(mRoot,'Userdata',L);
   
case 'ioselector' 
   %if there is no system menu then create it
   mRoot = uimenu('Parent', AxGrid.UIcontextMenu,'Label',xlate('I/O Selector...'),...
      'Callback',{@localCreateIOSelector this},'Tag','ioselector');
   
case 'arrayselector' 
   mRoot = uimenu('parent',AxGrid.UIcontextMenu,'callback',{@localOpenArraySelector this},...
      'Label',xlate('Array Selector...'),'Tag','arrayselector','Visible','off'); 
   L1 = handle.listener(this, this.findprop('Responses'), 'PropertyPostSet',{@localArrayselMenuTog this mRoot});
   localArrayselMenuTog([], [], this, mRoot); %fire the listener to update the menu initially
   arraySelect = struct('Listener',{L1},'Figure',{[]});
   set(mRoot,'Userdata',arraySelect); 
   % 'userData' prop is a 2 element call array: {1} listener to resplot.responses, {2} arraySel figure
   
case 'responses'
   mRoot = this.addContextMenu('waveforms',this.findprop('Responses'));
   
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

function localCreateIOSelector(eventSrc,eventData,this)
% Build I/O selector if does not exist
if isempty(this.AxesGrid.AxesSelector) 
   this.AxesGrid.AxesSelector = this.addioselector;
end
set(this.AxesGrid.AxesSelector,'visible','on');


function localGroupIOs(eventSrc, eventData,this,newval)
% Set I/O grouping state
this.IOGrouping = newval;


function localSyncIOGrouping(eventSrc,eventData,menuVec)
% Updates I/O Grouping menu check
newGrouping = eventData.Newvalue;
set(menuVec,'checked','off');
set(menuVec(strcmpi(newGrouping,get(menuVec,{'Tag'}))),'checked','on');


function localOpenArraySelector(eventsrc, eventdata, h)
% Array selector management
arraySelect = get(eventsrc,'UserData'); 
f = arraySelect.Figure;  %get arrayselector figure handle if there is one

if ~isempty(arraySelect.Figure) & ishandle(arraySelect.Figure) 
   h.paramsel(arraySelect.Figure);
else
   arraySelect.Figure = h.paramsel;
   set(eventsrc, 'UserData', arraySelect);
   set(arraySelect.Figure, 'Visible', 'on');
end
% above: If an array selector dialog exists then update it, else create it


function localArrayselMenuTog(eventSrc, eventData, this, arraySelmenu)

menuVis = 'off';
for resp=this.Responses'
   if length(resp.Data) > 1
      menuVis = 'on';
      break
   end
end
set(arraySelmenu, 'Visible', menuVis);


