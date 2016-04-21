function create3Dundo(hZoom,hAxes,origVa,newVa,origTarget,newTarget)

% Copyright 2003 The MathWorks, Inc.

if nargin==4
   localViewAngleUndo(hAxes,origVa,newVa);
elseif nargin==6
   localTargetViewAngleUndo(hAxes,origVa,newVa,origTarget,newTarget);
end
%---------------------------------------------------%
function localTargetViewAngleUndo(hAxes,...
                                    origVa,newVa,...
                                    origCamTarget,newCamTarget)

hFigure = ancestor(hAxes,'figure');

% Create command structure
cmd.Name = '3-D Zoom';
cmd.Function = @localUpdateCameraTargetViewAngle;
cmd.Varargin = {hAxes,newCamTarget,newVa};
cmd.InverseFunction = @localUpdateCameraTargetViewAngle;
cmd.InverseVarargin = {hAxes,origCamTarget,origVa};

uiundo(hFigure,'function',cmd);

%---------------------------------------------------%
function localUpdateCameraTargetViewAngle(hAxes,t,va)

camtarget(hAxes,t);
camva(hAxes,va);

%---------------------------------------------------%
function localViewAngleUndo(hAxes,origVa,newVa,origTarget,newTarget)

hFigure = ancestor(hAxes,'figure');

% Don't add operations that don't change limits
if (origVa==newVa)
  return
end

if origVa > newVa
  name = 'Zoom In';
else
  name = 'Zoom Out';
end

% Create command structure
cmd.Name = '3-D Zoom';
cmd.Function = @camva;
cmd.Varargin = {hAxes,newVa};
cmd.InverseFunction = @camva;
cmd.InverseVarargin = {hAxes,origVa};

% Register with undo/redo
uiundo(hFigure,'function',cmd);









