function initialize(this, ax, gridsize)
%INITIALIZE  Initializes the @nicholsplot objects.

%  Author(s): P. Gahinet, B. Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:21 $

% Axes geometry parameters
geometry = struct(...
   'HeightRatio',   [], 'HorizontalGap', 16, ...
   'VerticalGap',   16, 'LeftMargin',    12, ...
   'TopMargin',     20, 'PrintScale',     1);

% Grid options
GridOptions = gridopts('nichols');
GridOptions.Zlevel = -10;

% Create @axesgrid object
AxesGrid = ctrluis.axesgrid( ...
   gridsize,      ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'GridFcn',     {@LocalPlotGrid this}, ...
   'GridOptions', GridOptions,...
   'LimitFcn', {@updatelims this}, ...
   'XLimSharing', 'column', ...
   'YLimSharing', 'row', ...
   'Title',       'Nichols Chart', ...
   'XLabel',      'Open-Loop Phase',...
   'XUnits',      'deg',...
   'YLabel',      'Open-Loop Gain',...
   'YUnits',      'dB'  );
this.AxesGrid = AxesGrid;

% Create background lines
LocalCreateBackgroundLines([], [], this)

% Generic initialization
init_graphics(this)

% Add standard listeners
addlisteners(this)

% Other listeners
AxStyle = AxesGrid.AxesStyle;
p_color = findprop(AxStyle,'YColor');
L = [handle.listener(AxStyle, p_color, 'PropertyPostSet',{@LocalSetColor this});...
      handle.listener(AxesGrid,AxesGrid.findprop('Grid'),...
      'PropertyPostSet',{@LocalSetVisible this});...
      handle.listener(AxesGrid,'SizeChanged',{@LocalCreateBackgroundLines this});...
      handle.listener(AxesGrid,'PreLimitChanged',{@LocalAdjustView this})];
this.addlisteners(L);

% --------------------------------------------------------------------------- %
% Local Functions
% --------------------------------------------------------------------------- %
function LocalSetColor(eventsrc, eventdata, this)
% Adjust axis line color
set(this.BackgroundLines(:,:,1), 'Color', eventdata.AffectedObject.XColor)

% --------------------------------------------------------------------------- %
function LocalSetVisible(eventsrc, eventdata, this)
% Hide axis line when grid is on
if strcmp(eventdata.NewValue,'on') & prod(eventdata.AffectedObject.Size)==1
   set(this.BackgroundLines(:,:,1), 'Visible', 'off')
else
   set(this.BackgroundLines(:,:,1), 'Visible', 'on')
end 

% --------------------------------------------------------------------------- %
function GridHandles = LocalPlotGrid(this)
% Plot Nichols grid (M and N circles in SISO case)
GridHandles = this.AxesGrid.plotgrid('ngrid');

% --------------------------------------------------------------------------- %
function LocalAdjustView(eventsrc, eventdata, this)
% Prepares view for limit picker
% REVISIT: use FIND
for r = this.Responses(strcmp(get(this.Responses,'Visible'),'on'))'
   adjustview(r,'prelim')
end

% --------------------------------------------------------------------------- %
function LocalCreateBackgroundLines(eventsrc, eventdata, this)
% Creates and updates background lines (during axes grid resize)
% Delete existing lines
BL = this.BackgroundLines(:);
delete(BL(ishandle(BL)))
% Create new lines
AxGrid = this.AxesGrid;
ax = getaxes(AxGrid); % HG axes
AxStyle = AxGrid.AxesStyle;
gridsize = AxGrid.Size([1 2]);
x = 180*(-49:2:49) * unitconv(1, 'deg', AxGrid.XUnits);
y = 0; z = -9;
for ct = prod(gridsize):-1:1
   % 0 dB lines
   Xaxis(ct,1) = line([x(1) x(end)], [y y], [z-1 z-1], ...
      'Parent', ax(ct), 'LineStyle', ':', ...
      'Color', AxStyle.YColor, ...
      'HitTest', 'off', 'HandleVis', 'off', ...
      'XLimInclude', 'off', 'YLimInclude', 'off');
   % Critical points
   CritPoints(ct,1) = line(x,y(:,ones(1,length(x))),z(:,ones(1,length(x))), ...
      'Color', 'r', 'Parent', ax(ct), ...
      'Marker', '+', 'LineStyle', 'none', ...
      'HitTest', 'off', 'HandleVis', 'off', ...
      'XLimInclude', 'off', 'YLimInclude', 'off');
end
this.BackgroundLines = reshape([Xaxis CritPoints], [gridsize 2]);

