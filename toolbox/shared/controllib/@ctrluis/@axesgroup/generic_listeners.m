function generic_listeners(h)
%GENERIC_LISTENERS  Installs generic listeners.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/19 01:31:11 $

hgaxes = h.Axes2d(:);

% Install all listeners except the rendering listeners
% Virtual properties implemented by hg.axes
p_scale = [h.findprop('XScale');h.findprop('YScale')];   
p_units = [h.findprop('XUnits');h.findprop('YUnits')];
p_grid = [h.findprop('Grid');h.findprop('GridFcn')];
L1 = [handle.listener(h,p_scale,'PropertyPostSet',@LocalSetScale);...
      handle.listener(h,p_units,'PropertyPreSet',@LocalPreUnitTranform);...
      handle.listener(h,p_units,'PropertyPostSet',@LocalPostUnitTranform);...
      handle.listener(h,p_grid,'PropertyPostSet',{@LocalSetGrid h})];

% Targeted listeners
p_nextplot = [h.findprop('NextPlot');hgaxes(1).findprop('NextPlot')];
fig = h.Parent;
L2 = [handle.listener(h,h.findprop('UIContextMenu'),'PropertyPostSet',@LocalSetUIC);...
      handle.listener(h,h.findprop('LimitManager'),'PropertyPostSet',@setlimitmgr);...
      handle.listener(h,h.findprop('Position'),'PropertyPostSet',@setposition);...
      handle.listener([h;hgaxes],p_nextplot,'PropertyPostSet',@LocalSyncNextPlot);...     
      handle.listener(fig,'ResizeEvent',@LocalResize);...
      handle.listener(h,'ObjectBeingDestroyed',@LocalCleanUp);...
      handle.listener(h,'PostLimitChanged',@updategrid);...
      handle.listener(allaxes(h),'ObjectBeingDestroyed',@LocalDeleteAll);...
      handle.listener(h,h.findprop('EventManager'),'PropertyPreGet',@LocalDefaultManager)];
set(L2,'CallbackTarget',h);

% Support for CLA (REVISIT)
L3 = LocalCLASupport(h);

% Store listener handles
h.Listeners = [h.Listeners ; L1 ; L2; L3];

% Define UpdateFcn for style properties
h.AxesStyle.UpdateFcn = {@LocalSetAxesStyle h hgaxes};
h.TitleStyle.UpdateFcn = {@LocalSetLabelStyle h};
h.XLabelStyle.UpdateFcn = {@LocalSetLabelStyle h};
h.YLabelStyle.UpdateFcn = {@LocalSetLabelStyle h};


%-------------- Local functions -----------------------


function LocalSetAxesStyle(eventsrc,eventdata,h,hax)
% Updates axis style
set(hax,eventsrc.Name,eventdata.NewValue);
if strcmp(eventsrc.Name,'XColor')
   setgridstyle(h,'Color',eventdata.NewValue);
end
% Reapply label style due to HG coupling between XYColor and XYlabel color
setlabels(h)


function LocalSetLabelStyle(eventsrc,eventdata,h)
% Updates title, xlabel, or ylabel style
if ~strcmp(eventsrc.Name,'Location')
   setlabels(h)  % full update because LabelFcn may redirect labels (cf. bodeplot)
end


function LocalSetScale(eventsrc,eventdata)
% Get X or Y scale
h = eventdata.AffectedObject;
axgrid = getaxes(h,'2d');
switch eventsrc.Name
case 'XScale'
   for ct=1:size(axgrid,2)
      set(axgrid(:,ct),'XScale',h.XScale{ct});
   end
case 'YScale'
   for ct=1:size(axgrid,1)
      set(axgrid(ct,:),'YScale',h.YScale{ct});
   end
end    
% Recompute limits (change w/ scale)
h.send('ViewChanged')


function LocalSetGrid(eventsrc,eventdata,this)
% PostSet for Grid and GridFcn
% Clear existing grid
cleargrid(this);
% Update built-in grid state
axgrid = getaxes(this);
if isempty(this.GridFcn)
   set(axgrid(:),'XGrid',this.Grid,'YGrid',this.Grid)
else
   set(axgrid(:),'XGrid','off','YGrid','off')
end
% Trigger limit picker (ensuing PostLimitChanged event will trigger custom grid update)
if (~isempty(this.GridFcn) | strcmp(eventsrc.Name,'GridFcn'))
   this.send('ViewChanged')
end


function LocalSetUIC(h,eventdata)
% Add UI context menu
set(getaxes(h,'2d'),'UIContextMenu',eventdata.NewValue)


function LocalDefaultManager(h,eventdata)
% Installs default event manager
if isempty(h.EventManager)
    h.EventManager = ctrluis.eventmgr(h);
end
    

function LocalDeleteAll(h,eventdata)
% Callback when data axes deleted: delete @axesgroup object
if ~h.isBeingDestroyed
   delete(h(ishandle(h)))
end


function LocalCleanUp(h,eventdata)
% Clean up when object destroyed
% Delete all HG axes
delete(h.UIContextMenu(ishandle(h.UIContextMenu)))
hgaxes = allaxes(h);
delete(hgaxes(ishandle(hgaxes)))
   

function LocalSyncNextPlot(h,eventdata)
% Aligns NextPlot mode
h.NextPlot = eventdata.NewValue;
hgaxes = h.getaxes('2d');
set(hgaxes(:),'NextPlot',eventdata.NewValue)


function LocalResize(h,eventdata)
% Resize function (layout manager)
if strcmp(h.LayoutManager,'on')
   setposition(h)
end

%---------------- CLA ------------------------------

function L = LocalCLASupport(h)
% Create invisible lines that trigger callback when deleted by CLA
ax = h.Axes2d(:);
for ct=length(ax):-1:1
   hlines(ct,1) = handle(line(NaN,NaN,'Parent',ax(ct),'Visible','off','UserData',h));
end
L = handle.listener(hlines,'ObjectBeingDestroyed',@LocalCLA);


function LocalCLA(DeletedLine,eventdata)
% Callback when line deleted
ax = handle(DeletedLine.Parent);
if ~ax.isBeingDestroyed,  % don't do anything for destroyed axes
   cla(DeletedLine.UserData,ax)
end

%--------------- Units -------------------------

function LocalPreUnitTranform(eventprop,eventdata)
% Converts manual limits when changing units (preset callback)
Axes = eventdata.AffectedObject;
NewUnits = eventdata.NewValue;
PlotAxes = getaxes(Axes,'2d');
% Turn off backdoor listeners
Axes.LimitManager = 'off';
% Update manual limits
switch eventprop.Name
case 'XUnits'
   % REVISIT: set filter should take care of properly formatting XUnits
   XManual = strcmp(Axes.XLimMode,'manual');
   if ischar(Axes.XUnits)
      % No subgrid
      for ct=find(XManual)'
         Xlim = unitconv(get(PlotAxes(1,ct),'Xlim'),Axes.XUnits,NewUnits);
         set(PlotAxes(:,ct),'Xlim',Xlim)
      end
   else
      for ct=find(XManual)'
         ctu = rem(ct-1,length(Axes.XUnits))+1;
         Xlim = unitconv(get(PlotAxes(1,ct),'Xlim'),Axes.XUnits{ctu},NewUnits{ctu});
         set(PlotAxes(:,ct),'Xlim',Xlim)
      end
   end
case 'YUnits'
   % REVISIT: set filter should take care of this
   YManual = strcmp(Axes.YLimMode,'manual');
   if ischar(Axes.YUnits)
      % No subgrid
      for ct=find(YManual)'
         Ylim = unitconv(get(PlotAxes(ct,1),'Ylim'),Axes.YUnits,NewUnits);
         set(PlotAxes(ct,:),'Ylim',Ylim)
      end
   else
      for ct=find(YManual)'
         ctu = rem(ct-1,length(Axes.YUnits))+1;
         Ylim = unitconv(get(PlotAxes(ct,1),'Ylim'),Axes.YUnits{ctu},NewUnits{ctu});
         set(PlotAxes(ct,:),'Ylim',Ylim)
      end
   end
end
Axes.LimitManager = 'on';


function LocalPostUnitTranform(eventprop,eventdata)
% PostSet callback for data tranforms (XUnits,...)
% Issue DataChanged event to 
%  1) Force redraw (new units are incorporated when mapping data to the
%     lines' Xdata and Ydata in @view/draw methods)
%  2) Update auto limits (side effect of ensuing ViewChanged event)
% RE: ViewChanged event is not enough here because the lines' XData and YData
%     first needs to be transformed to the new units before updating the limits
%     (otherwise can end up with negative data on log scale)
eventdata.AffectedObject.send('DataChanged')