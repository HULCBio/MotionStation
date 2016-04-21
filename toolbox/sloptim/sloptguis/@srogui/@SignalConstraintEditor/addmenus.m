function addmenus(this)
% Adds context menus

%   Author: Kamesh Subbarao 
%   $Revision: 1.1.6.4 $  $Date: 2004/04/11 00:44:40 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Create Right Click Menus
uic = uicontextmenu('Parent',this.Parent);

% Plots
uimenu(uic,'Label',xlate('Plot Current Response'), ...
   'CallBack',@(x,y) feval(this.RespFcn{:}))
m = uimenu(uic,'Label',xlate('Show')); 
addShowMenus(this,m)
uimenu(uic,'Label',xlate('Clear Plots'), 'CallBack',@(x,y) clearplot(this))

% Editing and Specs
uimenu(uic,'Label',xlate('Scale Constraint...'),...
   'Separator','on','CallBack',@(x,y) scaledlg(this))
uimenu(uic,'Label',xlate('Reset Constraint'),...
   'CallBack','')
uimenu(uic,'Label',xlate('Desired Response...'),...
   'CallBack',@(x,y) specdlg(this))

% Axes properties
uimenu(uic,'Label',xlate('Grid'),'Check','off','Separator','on',...
    'CallBack',{@LocalSetGrid this})
uimenu(uic,'Label',xlate('Axes Limits...'),'CallBack',{@LocalEditProp this 'limit'})
uimenu(uic,'Label',xlate('Labels...'),'CallBack',{@LocalEditProp this 'label'})
 
set(getaxes(this.Axes),'UIContextMenu',uic)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           LOCALFUNCTIONS                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function LocalSimCurrent(eventsrc,eventdata,this)
% Simulate and notify all editors to update
feval(this.RespFcn{:})


function LocalEditProp(eventSrc,eventData,this,Tab) 
% Open property editor 
PropEdit = PropEditor(this);
if strcmp(Tab,'label')
   PropEdit.Java.TabPanel.selectPanel(0)
else
   PropEdit.Java.TabPanel.selectPanel(1)
end


function LocalSetGrid(eventsrc,eventdata,this)
% Toggles grid
Axes = this.Axes;
if strcmp(Axes.Grid,'on')
   Axes.Grid = 'off';
   set(eventsrc,'Checked','off')
else
   Axes.Grid = 'on';
   set(eventsrc,'Checked','on')
end   
   

