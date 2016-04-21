function draw_rlsdemo
%DRAW_RLSDEMO Draws the schematic block diagram for the RLS adaptive filter demo.

%   Author(s): A. Charry
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 15:17:55 $

% Set up the picture "frame"
xBox= [0 1 1 0 0];                                       
yBox= [0 0 1 1 0];  
bb = patch(xBox,yBox,'w');
set(bb,'facecolor',[0.75 0.75 0.75])

% Create the "Sine Wave", "Noise" and "LP FIR" blocks
drawbox(0.05,0.85,0.1,0.15,'c',sprintf('Sine\nWave'));
drawbox(0.05,0.6,0.1,0.15,'c','Noise');
drawbox(0.25,0.6,0.2,0.15,'c',sprintf('LP FIR\nNoise Filter'));

% Create a two input summing block
rectangle('Position',[0.5 0.5 0.05 0.07],'Curvature',[1 1]);
text(0.51,0.53,'+','fontsize',6);
text(0.52,0.55,'+','fontsize',6);

% Another two input summing block
rectangle('Position',[0.7 0.5 0.05 0.07],'Curvature',[1 1]);
text(0.71,0.53,'+','fontsize',6);
text(0.72,0.51,'-','fontsize',6);

% Create the "RLS", "Freq. Response" and "Results" blocks. 
drawbox(0.25,0.35,0.25,0.2,'r',sprintf('In                  Out\nRLS\nDes          Coeffs'));
drawbox(0.7,0.25,0.15,0.15,'c',sprintf('Freq.\nResponse'));
drawbox(0.85,0.85,0.1,0.28,'c','Results');

% Connect all the blocks up
drawarrow(0.15,0.85,0.78,0.78);
drawarrow(0.15,0.25,0.53,0.53);
drawarrow(0.45,0.5,0.53,0.53);
drawarrow(0.55,0.7,0.53,0.53);
drawarrow(0.524,0.524,0.78,0.57);
line([0.62 0.62],[0.53 0.71],'color',[0 0 0]);
drawarrow(0.62,0.85,0.71,0.71);
drawarrow(0.19,0.25,0.3,0.3);
line([0.19,0.19],[0.53,0.3],'color',[0 0 0]);
drawarrow(0.5,0.72,0.3,0.3);
line([0.72 0.72],[0.3 0.5],'color',[0 0 0]);
line([0.75 0.78],[0.53 0.53],'color',[0 0 0]);
line([0.78 0.78],[0.53 0.64],'color',[0 0 0]);
drawarrow(0.78,0.85,0.64,0.64);
line([0.62 0.62],[0.53 0.05],'color',[0 0 0]);
line([0.62 0.19],[0.05 0.05],'color',[0 0 0]);
line([0.19 0.19],[0.05 0.19],'color',[0 0 0]);
drawarrow(0.19,0.25,0.19,0.19);
drawarrow(0.5,0.7,0.19,0.19);

% Draw nodes
% Noise to Filter block
rectangle('Position',[.188,.525,0.005,0.005],'Curvature',[1,1]);
% Sine wave to Results block
rectangle('Position',[.522,.775,0.005,0.005],'Curvature',[1,1]);
% Sine+filtered noise sum block to the next sum block
rectangle('Position',[.618,.525,0.005,0.005],'Curvature',[1,1]);

% Add text and labels
text(0.5,0.95,'Adaptive Noise Cancellation Demo','Horizontal','Center');
text(0.18,0.74,'Input Signal','fontsize',7);
text(0.66,0.68,'Signal + Noise','fontsize',7);
text(0.76,0.5,'Error Signal','fontsize',7);
text(0.38,0.07,'Desired Signal','fontsize',7);

