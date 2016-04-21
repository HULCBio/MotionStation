function render(Constr, varargin)
%RENDER   Sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $ $Date: 2002/04/10 05:12:04 $

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
        'HelpTopicKey', 'peakgainconstraint', ...
        'UIContextMenu', Constr.addmenu(HostFig),...
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
Gain   = Constr.PeakGain;  % in dB
Origin = Constr.OriginPha; % in deg

% Generate isogain lines for following gain values:
gain = Gain * [1 3];

% Phase points
phase = logspace(-3, log10(180), 35); % evently spaced points using approx.
phase = [phase, fliplr(360-phase(1:end-1))];

% Set number of points in rendered line
nP = length(phase);

% Convert data to open-loop gain and phase values
[g,p] = meshgrid(10.^(gain/20), (pi/180)*phase);  % mesh in H/(1+H) plane
z = g .* exp(j*p);
H = z ./ (1-z);

% Create a multi-point line for curved constraint boundaries
Angles = rem((180/pi)*angle(H(:)) + 360, 360) - 180; 
i90 = find(Angles>-90);
nM = max(30,i90(1));     % Marker position index
XData = Origin + Angles; % Phase in deg
YData = 20*log10(abs(H(:)));  % Magnitude in dB
XData = unitconv(XData, 'deg', Constr.PhaseUnits);
YData = unitconv(YData, 'dB',  Constr.MagnitudeUnits);

% Thickness is already in YScale units so do not reconvert
XLims = PlotAxes.Xlim;
YLims = PlotAxes.Ylim;

% Construct new X, Y and Z data for the patch
if (Gain <= 0)
    if strcmp(PlotAxes.Yscale, 'linear')
        YWidth = YData + (YLims(2) - YLims(1)) * Constr.Thickness;
    else  % YScale is log
        YWidth = YData * (YLims(2) / YLims(1))^Constr.Thickness;
    end
    PatchXData = [XData(1:nP) flipud(XData(1:nP))];
    PatchYData = [YData(1:nP) flipud(YWidth(1:nP))];
else
    Ymax = abs(max(YData(1:nP)) - max(YData(nP+1:end)));
    Ymin = abs(min(YData(1:nP)) - min(YData(nP+1:end)));
    YWidth = YData + (Ymax - Ymin) / 2;
    PatchXData = [XData(1:nP) flipud(XData(nP+1:end))];
    PatchYData = [YData(1:nP) flipud(YWidth(nP+1:end))];
end
PatchZData = Constr.Zlevel(ones(2*nP,1),:);

% Set the new patch data values
Vertices = [PatchXData(:) PatchYData(:) PatchZData(:)];
Faces = [1:nP-1 ; 2:nP ; 2*nP-1:-1:nP+1 ; 2*nP:-1:nP+2]';
ColorData = [40*ones(nP,1) ; 64*ones(nP,1)];
set(Constr.HG.Patch, 'Faces', Faces, ...
    'FaceVertexCData', ColorData, ...
    'Vertices', Vertices);

% Plot left and right constraint selection markers in new position
idx = nP-nM+1;  % Position of second marker
set(Constr.HG.Edge,'XData',XData([nM idx]),'YData', YData([nM idx]),...
    'Zdata',Constr.Zlevel([1 1]))
set(Constr.HG.Markers(1), 'XData', XData(nM),  'YData', YData(nM), ...
    'Zdata', Constr.Zlevel);
set(Constr.HG.Markers(2), 'XData', XData(idx), 'YData', YData(idx), ...
    'Zdata', Constr.Zlevel);
