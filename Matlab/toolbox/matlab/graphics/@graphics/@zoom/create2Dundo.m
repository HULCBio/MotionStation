function create2Dundo(hZoom,hAxes,origLim,newLim)

% Copyright 2003 The MathWorks, Inc.

hFigure = ancestor(hAxes,'figure');

% Don't add operations that don't change limits
if(origLim==newLim)
  return;
end

% Determine undo stack name (this will appear in menu)
if all([origLim(1),origLim(3)] < [newLim(1),newLim(3)]) && ...
   all([origLim(2),origLim(4)] > [newLim(2),newLim(4)])
   name = 'Zoom In'; 
else
   name = 'Zoom Out';
end


% Create command structure
cmd.Name = name;
cmd.Function = @axis;
cmd.Varargin = {hAxes,newLim};
cmd.InverseFunction = @axis;
cmd.InverseVarargin = {hAxes,origLim};

% Register with undo/redo
uiundo(hFigure,'function',cmd);
