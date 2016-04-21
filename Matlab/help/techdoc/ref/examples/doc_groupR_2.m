function doc_groupR_2
% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Demos rotating stars

% Copyright 2002-2004 The MathWorks, Inc.

clf
% Create the axes object
ax = axes('XLim',[-2 1],'YLim',[-2 1],'ZLim',[-1 1]);
view(3); grid on; axis equal
% Create objects to group
[x y z] = cylinder([.3 0]);
h(1) = surface(x,y,z,'FaceColor','red');
h(2) = surface(x,y,-z,'FaceColor','green');
h(3) = surface(z,x,y,'FaceColor','blue');
h(4) = surface(-z,x,y,'FaceColor','cyan');
h(5) = surface(y,z,x,'FaceColor','magenta');
h(6) = surface(y,-z,x,'FaceColor','yellow');
% Create group object
t1 = hgtransform('Parent',ax);
t2 = hgtransform('Parent',ax);

% Set the renderer to ZBuffer or OpenGL
set(gcf,'Renderer','opengl')

% Parent objects and copy of objects to respective groups
set(h,'Parent',t1)
h2 = copyobj(h,t2);

% Translate one thing to (-1.5,-1.5)
Txy = makehgtform('translate',[-1.5 -1.5 0]);
set(t2,'Matrix',Txy)
drawnow

% Loop through angles (5 full rotations)
for r = 1:.1:10*pi
    % Form z-axis rotation matrix 
    Rz = makehgtform('zrotate',r);
   
  % Set transforms for both groups
    set(t1,'Matrix',Rz)
    set(t2,'Matrix',Txy*inv(Rz)*eye(4))
    drawnow
end


