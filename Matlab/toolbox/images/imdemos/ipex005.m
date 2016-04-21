function ipex005(A, uData, vData, B, xData, yData)
% Provides a graphical exploration of the conformal map defined by
%
%           w = (z + 1/z)/2         [our inverse transformation]
% and
%         z = w +/- sqrt(w^2 -1)    [our forward transformations].
%
% Uses MAKETFORM with 'custom' and applies TFORMFWD to vector
% data (grids and circles).

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $ $Date: 2003/05/03 17:53:36 $

% Create a TFORM structure for each branch of the forward
% transformation.  (No need for an inverse transformation or
% a TDATA object.)
t1 = maketform('custom', 2, 2, @Forward1, [], []);
t2 = maketform('custom', 2, 2, @Forward2, [], []);

% Illustrate the transformation of a grid of lines.
f3 = figure;
set(f3,'Color','w','Name','Conformal Transformation: Grid Lines');
axIn  = SetUpInputAxes( subplot(1,2,1));
axOut = SetUpOutputAxes(subplot(1,2,2));
ShowLines(axIn,axOut,t1,t2);

% Illustrate the transformation of an array of circles.
f4 = figure;
set(f4,'Color','w','Name','Conformal Transformation: Circles');
axIn  = SetUpInputAxes( subplot(1,2,1));
axOut = SetUpOutputAxes(subplot(1,2,2));
ShowCircles(axIn,axOut,t1,t2);

% Display the input image over the input axes of the conformal map.
f5 = figure;
set(f5,'Color','w','Name','Original Image Superposed on Input Plane');
axIn = SetUpInputAxes(axes);
ShowInput(axIn,A,uData,vData);

% Display the output image over the output axes of the conformal map.
f6 = figure;
set(f6,'Color','w','Name','Transformed Image Superposed on Output Plane');
axOut = SetUpOutputAxes(axes);
ShowOutput(axOut,B,xData,yData);

%-------------------------------------------------------------

function X = Forward1(U, t)
% FORWARD conformal transformation with positive square root.

W = complex(U(:,1),U(:,2));
Z = W + sqrt(W.^2 - 1);
X(:,2) = imag(Z);
X(:,1) = real(Z);

%-------------------------------------------------------------

function X = Forward2(U, t)
% FORWARD conformal transformation with negative square root.

W = complex(U(:,1),U(:,2));
Z = W - sqrt(W.^2 - 1);
X(:,2) = imag(Z);
X(:,1) = real(Z);

%-------------------------------------------------------------

function ShowLines(axIn, axOut, t1, t2)
% Plots a grid of lines before and after transformation.

d = 1/16;
u1 = [-5/4 : d : -d, -1e-6];
u2 =    0  : d : 5/4;
v1 = [-3/4 : d : -d, -1e-6];
v2 =    0  : d : 3/4;

% Lower left quadrant
[U,V] = meshgrid(u1,v1);
color = [0.3 0.3 0.3];
PlotMesh(axIn,U,V,color);
PlotMesh(axOut,tformfwd(t1,U,V),color);
PlotMesh(axOut,tformfwd(t2,U,V),color);

% Upper left quadrant
[U,V] = meshgrid(u1,v2);
color = [0 0 0.8];
PlotMesh(axIn,U,V,color);
PlotMesh(axOut,tformfwd(t1,U,V),color);
PlotMesh(axOut,tformfwd(t2,U,V),color);

% Lower right quadrant
[U,V] = meshgrid(u2,v1);
color = [0 0.8 0];
PlotMesh(axIn,U,V,color);
PlotMesh(axOut,tformfwd(t1,U,V),color);
PlotMesh(axOut,tformfwd(t2,U,V),color);

% Upper right quadrant
[U,V] = meshgrid(u2,v2);
color = [0 0.7 0.7];
PlotMesh(axIn,U,V,color);
PlotMesh(axOut,tformfwd(t1,U,V),color);
PlotMesh(axOut,tformfwd(t2,U,V),color);

%-------------------------------------------------------------

function ShowCircles(axIn, axOut, t1, t2)
% Plots a set of adjacent circles before and after transformation.

sep = 0.002;   % Separation between circles
d = 1/8;       % Center-to-center distance
radius = (d - sep)/2;   % Radius of circles
for u = -(5/4 - d/2) : d : (5/4 - d/2)
    for v = -(3/4 - d/2) : d : (3/4 - d/2)
        % Draw circle on input axes
        [uc,vc] = Circle(u,v,radius);
        line(uc,vc,'Parent',axIn,'Color',[0.3 0.3 0.3]);

        % Apply z = w + sqrt(w^2-1), draw circle on output axes
        [xc,yc] = tformfwd(t1,uc,vc);
        line(xc,yc,'Parent',axOut,'Color',[0 0.8 0]);
        
        % Apply z = w - sqrt(w^2-1), draw circle on output axes
        [xc,yc] = tformfwd(t2,uc,vc);
        line(xc,yc,'Parent',axOut,'Color',[0 0 0.9]);
    end
end

%-------------------------------------------------------------

function ShowInput(ax, A, uData, vData)
% Uses IMAGE and LINE to superpose the input image on the 'w' plane.

line('Parent',ax,'XData',[0 0],'YData',get(ax,'YLim'),'Color','k','LineWidth',1);
line('Parent',ax,'XData',get(ax,'XLim'),'YData',[0 0],'Color','k','LineWidth',1);

h = image('Parent',ax,'CData',A,'XData',uData,'YData',vData);

% Plot the ellipse and the interval [-1 1] on the real axis.
theta = 2 * pi * (0 : 90) / 90;
line('Parent',ax,'XData',(5/4) * cos(theta),'YData',(3/4) * sin(theta),'Color','k','LineWidth',1);
line('Parent',ax,'XData',    1 * cos(theta),'YData',    0 * sin(theta),'Color','r','LineWidth',1);

% Use partial transparence to de-emphasize the image.
alphaData = 0.6 * ones(size(A,1),size(A,2));
set(h,'AlphaData',alphaData);

%-------------------------------------------------------------

function ShowOutput(ax, B, xData, yData)
% Uses 'image' and 'line' to superpose the output image on the 'z' plane.

line('Parent',ax,'XData',[0 0],'YData',get(ax,'YLim'),'Color','k','LineWidth',1);
line('Parent',ax,'XData',get(ax,'XLim'),'YData',[0 0],'Color','k','LineWidth',1);

h = image('Parent',ax,'CData',B,'XData',xData,'YData',yData);

% Plot circles with radii of 1, 2, and 1/2.
theta = 2 * pi * (0 : 90) / 90;
line('Parent',ax,'XData', 1*cos(theta),'YData', 1*sin(theta),'Color','r','LineWidth',1);
line('Parent',ax,'XData', 2*cos(theta),'YData', 2*sin(theta),'Color','k','LineWidth',1);
line('Parent',ax,'XData', cos(theta)/2,'YData', sin(theta)/2,'Color','k','LineWidth',1);

% Use partial transparence to de-emphasize the image
alphaData = 0.6 * ones(size(B,1),size(B,2));
set(h,'AlphaData',alphaData);

%-------------------------------------------------------------

function ax = SetUpInputAxes(ax)
% Sets up axes and labels in the input/'w' plane.

set(ax, 'DataAspectRatio',[1 1 1],...
		'XLimMode','manual',...
        'YLimMode','manual',...
		'PlotBoxAspectRatioMode', 'manual');
set(ax,'XLim',[-1.5 1.5]);
set(ax,'YLim',[-1.0 1.0]);
set(ax,'Xlabel',text('String','Re(w)'));
set(ax,'Ylabel',text('String','Im(w)'));
set(ax,'Title',text('String','Input Plane'));

%-------------------------------------------------------------

function ax = SetUpOutputAxes(ax)
% Sets up axes and labels in the output/'z' plane.

set(ax, 'DataAspectRatio',[1 1 1],...
		'XLimMode','manual',...
        'YLimMode','manual',...
		'PlotBoxAspectRatioMode', 'manual');
set(ax,'XLim',[-2.5 2.5]);
set(ax,'YLim',[-2.5 2.5]);
set(ax,'Xlabel',text('String','Re(z)'));
set(ax,'Ylabel',text('String','Im(z)'));
set(ax,'Title',text('String','Output Plane'));

%-------------------------------------------------------------

function [x, y] = Circle(xCenter, yCenter, radius)
% Returns vectors containing the coordinates of a circle
% with the specified center and radius.

n = 32;
theta = (0 : n)' * (2 * pi / n);
x = xCenter + radius * cos(theta);
y = yCenter + radius * sin(theta);

%-------------------------------------------------------------

function PlotMesh(varargin)
% Plots a mesh on the axes AX with color COLOR, via calls
% to 'LINE'.
%
%  PLOTMESH(AX,X,Y,COLOR) accepts two M-by-N arrays X and Y
%  -- like the output of MESHGRID.
%
%  PLOTMESH(AX,XY,COLOR) acceptsa single M-by-N-by-2 array XY
%  -- like the output of TFORMFWD.

if nargin == 3
  ax = varargin{1};
  XY = varargin{2};
  color = varargin{3};
  X = XY(:,:,1);
  Y = XY(:,:,2);
else
  ax = varargin{1};
  X  = varargin{2};
  Y  = varargin{3};
  color = varargin{4};
end
  
for k = 1:size(X,1)
    line(X(k,:),Y(k,:),'Parent',ax,'Color',color);
end

for k = 1:size(X,2)
    line(X(:,k),Y(:,k),'Parent',ax,'Color',color);
end
