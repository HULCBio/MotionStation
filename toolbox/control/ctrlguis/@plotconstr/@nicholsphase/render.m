function render(Constr, varargin)
%RENDER   Sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $ $Date: 2002/04/10 05:09:59 $

% Set number of points in rendered line
nP = 5;

% Get axes info
PlotAxes = Constr.Parent;
HostFig  = PlotAxes.Parent;

if ~Constr.Activated
    % Initialize when constraint is not activated yet (preset for Activated=1)
    % Construct the constraint patch
    Patch = patch( ...
        'Parent', PlotAxes, ...
        'XlimInclude','off',...
        'YlimInclude','off',...        
        'EdgeColor', 'none', ...
        'CDataMapping', 'Direct', ...
        'FaceColor', 'interp', ...
        'HelpTopicKey', 'phasemarginconstraint', ...
        'UIContextMenu',  Constr.addmenu(HostFig), ...
        'ButtonDownFcn',Constr.ButtonDownFcn);
    
    % Transparent line to delimit extent for limit picker
    Edge = line('Parent', PlotAxes, 'LineStyle','none', ...
        'Color','k', 'HitTest','off');
    
    % Construct the constraint patch end markers
    Props = struct(...
        'Parent', PlotAxes, ...
        'LineStyle', 'none', ...
        'Marker', 's', ...
        'MarkerSize', 4, ... 
        'MarkerFaceColor', 'k', ...
        'MarkerEdgeColor', 'k', ...
        'ButtonDownFcn',{Constr.ButtonDownFcn},...
        'Visible', Constr.Selected);
    Markers = [line(Props); line(Props)];
    
    Constr.HG = struct('Patch',Patch,'Edge',Edge,'Markers',Markers);
end

% Get margin info
Margin = Constr.MarginPha; % in deg
Origin = Constr.OriginPha; % in deg

% Create a multi-point line for curved constraint boundaries
XData = linspace(Origin-Margin, Origin+Margin, nP); % Phase in deg
YData = linspace(0, 0, nP);                         % Magnitude in dB
XData = unitconv(XData, 'deg', Constr.PhaseUnits);
YData = unitconv(YData, 'dB',  Constr.MagnitudeUnits);

% Thickness is already in YScale units so do not reconvert
YLims = PlotAxes.Ylim;
if strcmp(PlotAxes.Yscale, 'linear')
    YDataH = YData + (YLims(2) - YLims(1)) / 2 * Constr.Thickness;
    YDataL = YData - (YLims(2) - YLims(1)) / 2 * Constr.Thickness;
else  % YScale is log
    YDataH = YData * (YLims(2) / YLims(1))^(Constr.Thickness / 2);
    YDataL = YData / (YLims(2) / YLims(1))^(Constr.Thickness / 2);
end

% Construct new X, Y and Z data for the patch
PatchXData = [XData fliplr(XData) XData];
PatchYData = [YDataH YData YDataL];
PatchZData = Constr.Zlevel(ones(3*nP,1),:);

% Set the new patch data values
Vertices = [PatchXData(:) PatchYData(:) PatchZData(:)];
Faces1 = [1:nP-1 ; 2:nP ; 2*nP-1:-1:nP+1 ; 2*nP:-1:nP+2]';
Faces2 = [nP+1:2*nP-1 ; nP+2:2*nP ; 3*nP-1:-1:2*nP+1 ; 3*nP:-1:2*nP+2]';
Faces = [Faces1 ; Faces2];
ColorData = [64*ones(nP,1) ; 40*ones(nP,1) ; 64*ones(nP,1)];
set(Constr.HG.Patch, 'Faces', Faces, ...
    'FaceVertexCData', ColorData, ...
    'Vertices', Vertices);

% Plot left and right constraint selection markers in new position
set(Constr.HG.Edge,...
    'XData',XData([1 nP]),'YData', YData([1 nP]),'Zdata',Constr.Zlevel([1 1]))
set(Constr.HG.Markers(1), 'XData', XData(1),  'YData', YData(1), ...
    'Zdata', Constr.Zlevel);
set(Constr.HG.Markers(2), 'XData', XData(nP), 'YData', YData(nP), ...
    'Zdata', Constr.Zlevel);
