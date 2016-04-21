function render(Constr,varargin)
%RENDER sets the vertices, X and Y data properties of the patch and markers.

%   Author(s): N. Hickey
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 05:07:52 $

% Set number of points in rendered line
nX = 50;
MagAxes = Constr.Parent; 
HostFig = double(MagAxes.Parent); 

if ~Constr.Activated
    % Initialize when constraint is not activated yet (preset for Activated=1)
    % Construct the constraint patch and edge
    % RE: The edge is the only object visible to the limit picker
    Patch = patch( ...
        'Parent', MagAxes, ...
        'XlimInclude','off',...
        'YlimInclude','off',...        
        'EdgeColor','none', ...
        'CDataMapping','Direct', ...
        'FaceColor','interp', ...
        'HelpTopicKey','bodegainconstraint',...
        'UIContextMenu',Constr.addmenu(HostFig),...
        'ButtonDownFcn',Constr.ButtonDownFcn);
    
    % Edge line to delimit extent for limit picker
    Edge = line('Parent',MagAxes,'Color',[0 0 0],'HitTest','off');
    
    % Construct the resize markers
    Props = struct(...
        'Parent', MagAxes,...
        'LineStyle','none', ...
        'Marker','s', ...
        'MarkerSize',4, ... 
        'MarkerFaceColor','k', ...
        'MarkerEdgeColor','k', ...
        'ButtonDownFcn',{Constr.ButtonDownFcn});
    Markers = [line(Props);line(Props)];
    Constr.HG = struct('Patch',Patch,'Edge',Edge,'Markers',Markers);
end

% Determine if an upper or lower constraint is to be drawn
if strcmpi(Constr.Type,'upper')
   Thickness = Constr.Thickness;
else % Lower constraint
   Thickness = -Constr.Thickness;
end

% Create a multipoint line to allow curved constraint lines
Fdec = log10(Constr.Frequency);  % frequency in decade
XData = linspace(Fdec(1),Fdec(2),nX);

% Calculate original slope of constraint
Slope = (Constr.Magnitude(2) - Constr.Magnitude(1)) / (Fdec(2) - Fdec(1));

% Calculate new extra Y data points using Y = m.X + c
YData = Slope * (XData-XData(1)) + Constr.Magnitude(1);

% Take inverse log to convert back to original linear units
XData  = unitconv(10.^XData,'rad/sec',Constr.FrequencyUnits);
YData  = unitconv(YData,'dB',Constr.MagnitudeUnits);

% Thickness is already in YScale units so dont reconvert
AxesLimits = get(MagAxes,'Ylim');
if strcmp(get(MagAxes,'Yscale'),'linear')
   YWidth = YData + (AxesLimits(2) - AxesLimits(1)) * Thickness;
else  % YScale is log
   YWidth = YData * (AxesLimits(2) / AxesLimits(1))^Thickness;
end

% Construct new X, Y and Z data for the patch
lx = length(XData);
PatchXData = [XData  fliplr(XData)];
PatchYData = [YData  fliplr(YWidth)];
PatchZData = Constr.Zlevel(ones(2*lx,1),:);

% Set the new patch data values
Vertices = [PatchXData(:) PatchYData(:) PatchZData];
Faces = [1:2*lx];
ColorData = [40*ones(lx,1) ; 64*ones(lx,1)];
set(Constr.HG.Patch,'Faces',Faces,'FaceVertexCData',ColorData,...
   'Vertices',Vertices,'Visible','on');

% Position edge
set(Constr.HG.Edge,'XData',XData,'YData',YData,'ZData',Constr.Zlevel(ones(1,nX)))

% Position resize markers
set(Constr.HG.Markers(1),'XData',XData(1),'YData',YData(1),'Zdata',Constr.Zlevel);
set(Constr.HG.Markers(2),'XData',XData(nX),'YData',YData(nX),'Zdata',Constr.Zlevel);

% Marker visibility
set(Constr.HG.Markers,'Visible',Constr.Selected)