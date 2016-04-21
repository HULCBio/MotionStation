function draw_nlmsdemo
%DRAW_NLMSDEMO Draws the schematic block diagram for the Normalized LMS adaptive filter demo.

%   Author(s): A. Charry
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:17:52 $

% Set up the picture "frame"
xBox= [0 1 1 0 0];                                       
yBox= [0 0 1 1 0];  
bb = patch(xBox,yBox,'w');
set(bb,'facecolor',[0.75 0.75 0.75])

% Create the "Sine Wave" and "Noise" blocks
drawbox(0.05,0.76,0.1,0.15,'c',sprintf('Sine\nWave'));
drawbox(0.05,0.5,0.1,0.15,'c','Noise');

% Create a two input summing block
rectangle('Position',[0.25,0.4,0.05,0.07],'Curvature',[1 1]);
text(0.26,0.43,'+','fontsize',6);
text(0.27,0.45,'+','fontsize',6);

% Create the "Delay" and the "NLMS" blocks
drawbox(0.35,0.5,0.1,0.1,'c','Delay');
drawbox(0.5,0.5,0.2,0.25,'r',sprintf('In            Out\nNLMS\nDes     Coeffs'));

% Another two input summing block
rectangle('Position',[0.7,0.65,0.05,0.07],'Curvature',[1 1]);
text(0.71,0.68,'+','fontsize',6);
text(0.72,0.66,'-','fontsize',6);

% Create the "Plot" block
drawbox(0.85,0.8,0.1,0.25,'c','Plot');

% Connect all these blocks up.
drawarrow(0.15,0.25,0.42,0.42);
drawarrow(0.3,0.35,0.45,0.45);
drawarrow(0.45,0.5,0.45,0.45);
drawarrow(0.15,0.7,0.68,0.68);
drawarrow(0.28,0.28,0.68,0.47);
drawarrow(0.75,0.85,0.68,0.68);
line([0.32 0.32],[0.45 0.75],'color',[0 0 0]);
drawarrow(0.32,0.85,0.75,0.75);
line([0.47 0.47],[0.68 0.31],'color',[0 0 0]);
drawarrow(0.47,0.5,0.31,0.31);
line([0.7 0.79],[0.44 0.44],'color',[0 0 0]);
line([0.72 0.72],[0.44 0.65],'color',[0 0 0]);
% Arrow head for this line
patch([.72,0.71,0.73],[0.64,0.63,0.63],'k')
line([0.79 0.79],[0.44,0.6],'color',[0 0 0]);
drawarrow(0.79,0.85,0.6,0.6);

% Draw nodes
% First node between the SineWave block and the Error sum-block
rectangle('posit',[.278,.675,0.005,0.005],'curva',[1,1]);
% Second node between the SineWave block and the Error sum-block
rectangle('Position',[.466,.675,0.005,0.005],'Curvature',[1,1]);
% Node between the noise-sum and the Delay blocks
rectangle('Position',[.316,.448,0.005,0.005],'Curvature',[1,1]);
% Node between the NLMS and the Plot blocks.
rectangle('Position',[.718,.438,0.005,0.005],'Curvature',[1,1]);

% Add text and labels.
text(0.5,0.9,'Normalized LMS Adaptive Linear Prediction ','fontsize',10,'horizon','center');
text(0.5,0.77,'Input Signal','fontsize',7);
text(0.72,0.4,'Prediction','fontsize',7);
text(0.76,0.7,'Error','fontsize',7);
text(0.5,0.19,'NLMS Adaptive Filter','fontsize',7);
text(0.16,0.7,'Desired Signal','fontsize',7);


