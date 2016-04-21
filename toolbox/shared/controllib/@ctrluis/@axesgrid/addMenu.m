function m=addMenu(this, menuType, varargin)
%ADDMENU  Install generic axes grid menus

%  Author(s): James Owen
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:37 $

%Create a group of context menu items appropriate for the plotType.
%Note hplot is a @respplot object. Return a structure with fields set 
%to the appropriate meu handles for each item
m = this.findMenu(menuType);  % search for specified menu (HOLD support)
if ~isempty(m)
   return
end

switch menuType
case 'grid'
   % Check if the menu already exists
   m = uimenu('Parent',this.UIcontextMenu,'Label',xlate('Grid'),...
      'Checked',this.Grid,'Tag','grid',...
      'Callback',{@localSetGrid this});
   L = handle.listener(this,this.findprop('Grid'),...
      'PropertyPostSet',{@localToggleCheck m});
   set(m,'userdata',L);
end

% Apply menu settings
if length(varargin)
   set(m,varargin{:})
end


%--------------- Local functions -------------------


function localSetGrid(eventSrc, eventData,this)
% Toggles grid state
if strcmp(this.Grid,'off')
   this.Grid = 'on';
else
   this.Grid = 'off';
end;


function localToggleCheck(eventSrc,eventData,menu)
% Updates menu check to track grid state
set(menu,'Checked',eventData.newvalue);