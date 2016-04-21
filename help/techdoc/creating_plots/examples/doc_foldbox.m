function doc_foldbox
% Example for hgtransform

% Copyright 2003-2004 The MathWorks, Inc.

clf
% Use double buffer to prevent flashing during the loop
% Set the renderer to Zbuffer
set(gcf,'DoubleBuffer','on');
set(gcf,'Renderer','zbuffer');

% Set axis limits and view
set(gca,'xlim',[0 4], 'ylim',[0 4], 'zlim', [0 3]);
view(3); axis equal; grid on

% Define the object hierarchy
t(1) = hgtransform;
t(2) = hgtransform('parent',t(1));
t(3) = hgtransform('parent',t(2));
t(4) = hgtransform('parent',t(3));
t(5) = hgtransform('parent',t(4));
t(6) = hgtransform('parent',t(5));

% Patch data
X = [0 0 1 1];
Y = [0 1 1 0];
Z = [0 0 0 0];

% Text data
Xtext = .5;
Ytext = .5;
Ztext = .15;

% Corresponding pairs of objects (patch and text)
% are parented into the object hierarchy
p(1) = patch('FaceColor','red','Parent',t(1));
txt(1) = text('String','Bottom','Parent',t(1));
p(2) = patch('FaceColor','green','Parent',t(2));
txt(2) = text('String','Right','Parent',t(2));
p(3) = patch('FaceColor','blue','Parent',t(3));
txt(3) = text('String','Back','Color','white','Parent',t(3));
p(4) = patch('FaceColor','yellow','Parent',t(4));
txt(4) = text('String','Top','Parent',t(4));
p(5) = patch('FaceColor','cyan','Parent',t(5));
txt(5) = text('String','Left','Parent',t(5));
p(6) = patch('FaceColor','magenta','Parent',t(6));
txt(6) = text('String','Front','Parent',t(6));
% All the patch objects use the same x, y, and z data
set(p,'XData',X,'YData',Y,'ZData',Z)
% Set the position and alignment of the text objects
set(txt,'Position',[Xtext Ytext Ztext],...
    'HorizontalAlignment','center',...
    'VerticalAlignment','middle')
% Display the objects in their current location
showit(1)

% Set up initial translation transforms 
% Translate 1 unit in x
Tx = makehgtform('translate',[1 0 0]);
% Translate 1 unit in y
Ty = makehgtform('translate',[0 1 0]);

% Translate the unit squares to the desired locations
% The drawnow and pause commands display
% the objects after each translation
set(t(2),'Matrix',Tx);
showit(1)
set(t(3),'Matrix',Ty);
showit(1)
set(t(4),'Matrix',Tx);
showit(1)
set(t(5),'Matrix',Ty);
showit(1)
set(t(6),'Matrix',Tx);
showit(1)

% Specify rotation angle (pi/2 radians = 90 degrees)
fold = pi/2; 

% Rotate -y, translate x
Ry = makehgtform('yrotate',-fold);
RyTx = Tx*Ry;

% Rotate x, translate y
Rx = makehgtform('xrotate',fold);
RxTy = Ty*Rx;

% Set the transforms 
% Draw after each group transform and pause
set(t(6),'Matrix',RyTx);
showit(1)
set(t(5),'Matrix',RxTy);
showit(1)
set(t(4),'Matrix',RyTx);
showit(1)
set(t(3),'Matrix',RxTy);
showit(1)
set(t(2),'Matrix',RyTx);
showit(1)

function showit(delay)
drawnow
pause(delay)
