function [PointerType,Status] = hoverstatus(Editor,Status)
%HOVERSTATUS  Sets pointer type and status when hovering editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.23 $  $Date: 2002/04/10 04:56:08 $

% RE: AXES is the axis on which zoom is occurring

HG = Editor.HG;
SISOfig = double(Editor.Axes.Parent);

% Get handles of movable markers and lines
MovableMarkers = [HG.Compensator.Magnitude;HG.Compensator.Phase];
NWM = strcmp(get(MovableMarkers,{'Tag'}),'NotchWidthMarker');
MovableLine = HG.BodePlot(1);
FixedLines = HG.BodePlot(2:end);
    
% Get currently hovered object
HitObject = hittest(SISOfig);   

% Set pointer and status
if HitObject==MovableLine
    PointerType = 'hand';
    Status = sprintf('%s\nLeft click and move this curve up or down to adjust the %s.',...
        get(HitObject,'Tag'),Editor.describe('gain'));
elseif any(HitObject==FixedLines)
    PointerType = 'arrow';
    Status = sprintf('%s\nRight click for design options.',get(HitObject,'Tag'));  
elseif any(HitObject==MovableMarkers(NWM,:)),
    % Notch width marker is in focus
    PointerType = 'lrdrag';
    Status = sprintf('Left click and move left or right to adjust the notch filter width');
elseif any(HitObject==MovableMarkers(~NWM,:))
    % Pole or zero in focus
    PointerType = 'hand';
    if strcmp(get(HitObject,'Marker'),'x')
        Status = sprintf('Left click to move this pole of the %s.',Editor.describe('comp'));
    else
        Status = sprintf('Left click to move this zero of the %s.',Editor.describe('comp'));
    end
else
    PointerType = 'arrow';
end

