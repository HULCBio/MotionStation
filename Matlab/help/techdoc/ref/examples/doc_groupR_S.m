function doc_groupR_S
% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Demos rotation and scaling

% Copyright 2002-2004 The MathWorks, Inc.

clf
% Set the limits and select a view
ax = axes('XLim',[-1.5 1.5],'YLim',[-1.5 1.5],'ZLim',[-1.5 1.5]);
view(3); grid on; axis equal

% Create objects to group
[x y z] = cylinder([.2 0]);
h(1) = surface(x,y,z,'FaceColor','red');
h(2) = surface(x,y,-z,'FaceColor','green');
h(3) = surface(z,x,y,'FaceColor','blue');
h(4) = surface(-z,x,y,'FaceColor','cyan');
h(5) = surface(y,z,x,'FaceColor','yellow');
h(6) = surface(y,-z,x,'FaceColor','magenta');
set(h,'Clipping','off')

% Create group object and parent surfaces
t = hgtransform('Parent',ax);
set(h,'Parent',t)

% Set the renderer to OpenGL and update the display
set(gcf,'Renderer','opengl')
drawnow; 

% Rotate 360 degrees (2*pi radians)
for r = 1:.1:2*pi
    % z-axis rotation matrix 
    Rz = makehgtform('zrotate',r);
    % scaling matrix
    Sxy = makehgtform('scale',r/4);
   
    % Concatenate the transforms and 
    % set the transform Matirx property 
    set(t,'Matrix',Rz*Sxy)
    drawnow
end
pause(1)
% Reset to the original orientation and size using the identity matrix
set(t,'Matrix',eye(4))
