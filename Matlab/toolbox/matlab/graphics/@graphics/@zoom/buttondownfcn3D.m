function buttondownfcn3D(hZoom,hAxesVector)
%BUTTONDOWNFCN3D
% Button down function for 3-D zooming

% Copyright 2003 The MathWorks, Inc.

hFig = get(hZoom,'FigureHandle');

% For now, only consider the first axes
hAxes = hAxesVector(1);

% Set the original camera view angle
% We'll need this for generating the undo/redo
% command object.
set(hZoom,'CameraViewAngle',camva(hAxes));

% Force axis to be 'vis3d' to avoid wacky resizing
axis(hAxes,'vis3d');

% Set the window button motion and up fcn's.
set(hFig, 'WindowButtonMotionFcn',{@local3DButtonMotionFcn,hZoom,hAxes});
set(hFig, 'WindowButtonUpFcn', {@local3DButtonUpFcn,hZoom,hAxes});

%---------------------------------------------------%
function local3DButtonMotionFcn(hcbo,eventData,hZoom,hAxes)

% Move this function into a method called "buttonmotionfcn3d" 
% after UDD class loading performance improves.

hFig = get(hZoom,'FigureHandle');

% Get figure current point in pixels
origUnits = get(hFig,'Units');
set(hFig,'Units','Pixels');
new_pt = get(hFig,'CurrentPoint'); 
set(hFig,'Units',origUnits);

starting_pt = get(hZoom,'MousePoint');
if isempty(starting_pt)
   set(hZoom,'MousePoint',new_pt);
else
   % Determine change in pixel position
   xy = new_pt - starting_pt;
   
   % Heuristic for pixel change to camera zoom factor 
   q = max(-.9, min(.9, sum(xy)/70))+1;

   % Limit zoom out view angle
   va = camva(hAxes);
   if q>1 || va<get(hZoom,'MaxViewAngle')     
         camzoom(hAxes,q);
   end
   
   % Flush render update and restore double buffer state
   drawnow expose;
      
   set(hZoom,'MousePoint',new_pt);
end

%---------------------------------------------------%
function local3DButtonUpFcn(hobj, eventData, hZoom,hAxes)

hFig = get(hZoom,'FigureHandle');

% If the mouse position never moved then just zoom in
% on the mouse click
if isempty(get(hZoom,'MousePoint'))
   localOneShot3DZoom(hZoom,hAxes); 
end

% Add zoom operation to undo/redo stack
origVa = get(hZoom,'CameraViewAngle');
newVa = camva(hAxes);
create3Dundo(hZoom,hAxes,origVa,newVa);

% Clear window button motion & up functions.
set(hFig,'windowbuttonmotionfcn', '');
set(hFig,'windowbuttonupfcn', '');

% Clear out Mouse Position
set(hZoom,'MousePoint',[]);

% Clear out original camera view angle
set(hZoom,'CameraViewAngle',[]);

%---------------------------------------------------%
function localOneShot3DZoom(hZoom,hAxes)
% If button motion function never ran then do a 
% simple 3D zoom based on current mouse position

if strcmpi(get(hZoom,'Direction'),'in')
   zoomLeftFactor = 1.5;
   zoomRightFactor = .75;         
else
   zoomLeftFactor = .75;
   zoomRightFactor = 1.5;
end

% Determine new zoom factor based on mouse click
hFig = get(hZoom,'FigureHandle');
switch get(hFig,'selectiontype')            
   case 'normal' % Left click
      factor = zoomLeftFactor;

   case 'open' % Double click
        % do nothing

   otherwise % Right click
      factor = zoomRightFactor;
end

% Actual zoom operation
newct = mean(get(hAxes,'CurrentPoint'),1);  
origct = camtarget(hAxes);      
set(hAxes,'CameraTarget',newct);
origva = camva(hAxes);
camzoom(hAxes,factor);
newva = camva(hAxes);

% Add operation to undo/redo stack
create3Dundo(hZoom,hAxes,origva,newva,origct,newct);








