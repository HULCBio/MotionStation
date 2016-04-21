function initialize(this, ax, gridsize)
%INITIALIZE  Initializes the @nyquistplot objects.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:21:44 $

% Axes geometry parameters
geometry = struct(...
   'HeightRatio',[],...
   'HorizontalGap',16,...
   'VerticalGap',16,...
   'LeftMargin',12,...
   'TopMargin',20,...
   'PrintScale',1);

% Grid options
GridOptions = gridopts('nichols');
GridOptions.Zlevel = -10;

% Create @axesgrid object
AxesGrid = ctrluis.axesgrid(gridsize, ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'GridFcn', {@LocalPlotGrid this},...
   'GridOptions', GridOptions,...
   'LimitFcn',  {@updatelims this}, ...
   'XLimSharing', 'column', ...
   'YLimSharing', 'row', ...
   'XLabel', 'Real Axis',...
   'YLabel', 'Imaginary Axis',...
   'Title', 'Nyquist Diagram');
this.AxesGrid = AxesGrid;

% Create background lines
LocalCreateBackgroundLines([], [], this)

% Generic initialization
init_graphics(this)

% Add standard listeners
addlisteners(this)

% Other listeners
AxStyle = AxesGrid.AxesStyle;
p_color = [findprop(AxStyle,'XColor'),findprop(AxStyle,'YColor')];
L = [handle.listener(AxesGrid,AxesGrid.findprop('Grid'),...
      'PropertyPostSet',{@LocalSetYAxisVis this});...
      handle.listener(AxesGrid,'SizeChanged',{@LocalCreateBackgroundLines this});...
      handle.listener(AxStyle,p_color,'PropertyPostSet',{@LocalSetColor this});...
      handle.listener(AxesGrid,'PreLimitChanged',{@LocalAdjustView this})];
this.addlisteners(L);



%-------------------------- Local Functions ----------------------------

function LocalSetColor(eventsrc,eventdata,this)
% Adjust axis line color
set(this.BackgroundLines(:,:,1),'Color',eventdata.AffectedObject.XColor)  % Xaxis
set(this.BackgroundLines(:,:,2),'Color',eventdata.AffectedObject.YColor)  % Yaxis


function LocalSetYAxisVis(eventsrc,eventdata,this)
% Hide Y axis line when plotting special grid
Yaxis = this.BackgroundLines(:,:,2);
if (prod(size(Yaxis))>1 | strcmp(eventdata.NewValue,'off'))
   set(Yaxis,'Visible','on')
else
   set(Yaxis,'Visible','off')
end


function GridHandles = LocalPlotGrid(this)
% Plot Nyquist grid (M and N circles in SISO case)
AxGrid = this.AxesGrid;
Options = AxGrid.GridOptions;
Options.FrequencyUnits = this.FrequencyUnits;
Options.MagnitudeUnits = this.MagnitudeUnits;
AxGrid.GridOptions = Options;
GridHandles = AxGrid.plotgrid('nyquist');


function LocalAdjustView(eventsrc, eventdata, this)
% Prepares view for limit picker
% REVISIT: use FIND
for r=this.Responses(strcmp(get(this.Responses,'Visible'),'on'))'
   adjustview(r,'prelim')
end


function LocalCreateBackgroundLines(eventsrc, eventdata, this)
% Creates and updates background x-y lines (during axes grid resize)
% Delete existing lines
BL = this.BackgroundLines(:);
delete(BL(ishandle(BL)))
% Create new lines
AxGrid = this.AxesGrid;
ax = getaxes(AxGrid); % HG axes
AxStyle = AxGrid.AxesStyle;
gridsize = AxGrid.Size([1 2]);
LineSpan = infline(-Inf,Inf);
npts = length(LineSpan);
for ct=prod(gridsize):-1:1
   % Real/Imag axes lines
   Xaxis(ct,1) = line(LineSpan,zeros(1,npts),repmat(-10,[1 npts]),...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle',':','Color',AxStyle.YColor,...
      'HitTest','off','HandleVis','off','Parent',ax(ct));
   Yaxis(ct,1) = line(zeros(1,npts),LineSpan,repmat(-10,[1 npts]),...
      'XlimInclude','off','YlimInclude','off',...
      'LineStyle',':','Color',AxStyle.XColor,...
      'HitTest','off','HandleVis','off','Parent',ax(ct));
   % Critical points
   CritPoint(ct,1) = line(-1,0,-10,'Color','r','Parent',ax(ct),...
      'Marker','+','HitTest','off','HandleVisibility','off');
end
this.BackgroundLines = reshape([Xaxis Yaxis CritPoint],[gridsize 3]);
