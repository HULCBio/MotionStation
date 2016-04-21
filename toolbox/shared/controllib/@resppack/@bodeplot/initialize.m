function initialize(this, ax, gridsize)
%INITIALIZE  Initializes the @bodeplot objects.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:20:22 $

% Axes geometry parameters (main grid and 2x1 subgrid)
geometry = struct(...
   'HeightRatio',{[];[.53 .47]},...
   'HorizontalGap',{16;0},...
   'VerticalGap',{16;12},...
   'LeftMargin',{12;0},...
   'TopMargin',{20;0},...
   'PrintScale',1);

% Create @axesgrid object
this.AxesGrid = ctrluis.axesgrid([gridsize 2 1], ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'LimitFcn',  {@updatelims this}, ...
   'LabelFcn',  {@LocalBuildLabels this}, ...
   'Title',    'Bode Diagram', ...
   'XLabel',   'Frequency',...
   'XScale',   'log',...
   'XUnit',  'rad/sec',...
   'YLabel', {'Magnitude' ; 'Phase'},...
   'YUnit',  {'dB' ; 'deg'},...
   'RowVisible', this.io2rcvis('r',this.OutputVisible));  % to account for PhaseVisible state

% Generic initialization
init_graphics(this)

% Add listeners
addlisteners(this)

%----------------- Local Functions --------------------------------------------

function LabelMap = LocalBuildLabels(this)
% Builds labels for Bode plots
AxGrid = this.AxesGrid;

% Initialize label map
LabelMap = struct(...
   'XLabel',sprintf('%s %s',AxGrid.XLabel,LocalUnitInfo(AxGrid.XUnits)),...
   'XLabelStyle',AxGrid.XLabelStyle,...
   'YLabel',[],...
   'YLabelStyle',AxGrid.YLabelStyle,...
   'ColumnLabel',{AxGrid.ColumnLabel},...
   'ColumnLabelStyle',AxGrid.ColumnLabelStyle,...
   'RowLabel',[],...
   'RowLabelStyle',[]);

% Y label and row labels
MagLabel = sprintf('%s%s',AxGrid.YLabel{1},LocalUnitInfo(AxGrid.YUnits{1}));
PhaseLabel = sprintf('%s%s',AxGrid.YLabel{2},LocalUnitInfo(AxGrid.YUnits{2}));
MagVis = strcmp(this.MagVisible,'on');
PhaseVis = strcmp(this.PhaseVisible,'on');

if prod(AxGrid.Size(1:2))>1
   % MIMO case: Mag and Phase go to the YLabel field
   LabelMap.RowLabel = AxGrid.RowLabel;   
   LabelMap.RowLabelStyle = AxGrid.RowLabelStyle;   
   if MagVis & PhaseVis
      LabelMap.YLabel = sprintf('%s ; %s',MagLabel,PhaseLabel);
   elseif MagVis
      LabelMap.YLabel = MagLabel;
   elseif PhaseVis
      LabelMap.YLabel = PhaseLabel;
   end
   
else
   % SISO case: Mag and Phase go to the RowLabel field
   LabelMap.YLabel = '';
   LabelMap.RowLabel = {MagLabel ; PhaseLabel};
   LabelMap.RowLabelStyle = AxGrid.YLabelStyle;   
end


function str = LocalUnitInfo(unit)
% Returns string capturing unit and transform info
if isempty(unit)
   str = '';
else
   str = sprintf(' (%s)',unit);
end