function cmapeditor_example
% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Creates a slice plane graph of flow data

% Copyright 2002-2004 The MathWorks, Inc.

figure('DoubleBuffer','on')
% Generate data
[x,y,z,v] = flow;
xmin = min(x(:)); 
ymin = min(y(:)); 
xmax = max(x(:)); 
ymax = max(y(:)); 
v = -1.*v;
% Create a rotated slice plane
hslice = surf(linspace(xmin,xmax,100),...
   linspace(ymin,ymax,100),...  
   zeros(100));
rotate(hslice,[-1,0,0],-45)
xd = get(hslice,'XData');
yd = get(hslice,'YData');
zd = get(hslice,'ZData');
delete(hslice)
h = slice(x,y,z,v,xd,yd,zd);
set(h,'FaceColor','interp',...
    'EdgeColor','none')
% Ajust the view
daspect([1,1,1])
axis tight
view(-24.5,16)
camzoom(1.6)
camproj perspective
% Use a 48 element colormap
colormap(jet(48))
h = colorbar('horizontal');
set(gcf,'Renderer','zbuffer')
