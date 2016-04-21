function [PointerType,Status] = hoverstatus(Editor,Status)
%HOVERSTATUS  Sets pointer type and status when hovering editor.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 04:57:28 $

HG = Editor.HG;
SISOfig = double(Editor.Axes.Parent);
MovableHandles = [HG.ClosedLoop ; HG.Compensator];

% Get currently hovered object
HitObject = hittest(SISOfig);   

if any(HitObject==MovableHandles)
    % Movable object is in focus
    PointerType = 'hand';
    % Give informative status
    if any(HitObject==HG.ClosedLoop)
        Status = sprintf('Left-click and move this closed-loop pole to adjust the loop gain.');
    elseif strcmp(get(HitObject,'Marker'),'x')
        Status = sprintf('Left-click to move this pole of the %s.',Editor.describe('comp'));
    else
        Status = sprintf('Left-click to move this zero of the %s.',Editor.describe('comp'));
    end
else
    PointerType = 'arrow';
    % If close to the locus, hint at selectgain feature
    if any(HitObject==HG.Locus)
        Status = sprintf('Root locus.  Left-click to move closed-loop pole to this location.');
    end
end
