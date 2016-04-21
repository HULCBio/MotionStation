%DRAWACC Script that draws the ACC Benchmark Schematic.
%   DRAWACC draws the coupled cart schematic for the ACC
%   Benchmark used in the ACCDM2 demo.

%   Denise L. Chen, Aug 1993.
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.7.4.3 $  $Date: 2004/04/11 00:12:22 $

%============================================================
% Draw the Cars

% set up the car parameters
carHt = 0.15;
carWid = 0.25;

% spacing parameter for positioning the hub of a wheel
% relative to the car body
hubSp = 0.05;

wheelRad = 0.0375;

% draw the left car
xPos = [.1 .1 .1+carWid .1+carWid];
%xPos = [.15 .15 .15+carWid .15+carWid];
yPos = [.4 .4+carHt .4+carHt .4];
patch(xPos,yPos,'r');

% draw the two wheels on the left car
hubR = .1+ hubSp;
%hubR = .15+ hubSp;
wheel(hubR,0.4,wheelRad);
hubL = .1+carWid-hubSp;
%hubL = .15+carWid-hubSp;
wheel(hubL,0.4,wheelRad);

% draw the right car and its two wheels
xPos = [.6 .6 .6+carWid .6+carWid];
patch(xPos,yPos,'b');
hubR = .6+ hubSp;
wheel(hubR,0.4,wheelRad);
hubL = .6+carWid-hubSp;
wheel(hubL,0.4,wheelRad);

%============================================================
% Draw the Spring

% define spring parameters
spWid = 0.005;
spLgth = 0.01;
ampl = 0.02;

% draw the spring
left = 0.1 +carWid+spLgth;
%left = 0.15+carWid+spLgth;
right = 0.6-spLgth;
dx = (right-left)/10;
t = left:dx:right;
ySp = ampl*(sin(pi*t/dx)-left)+0.5;
h = plot(t,ampl*(sin(pi*t/dx)-left)+0.5);
set(h,'LineWidth',spWid);

% draw the left connector
t = 0.1 +carWid: spLgth: left;
%t = 0.15+carWid: spLgth: left;
h = plot(t,ySp(1)*ones(size(t)));
set(h,'LineWidth',spWid);

% draw the right connector
t = right: spLgth: 0.6;
h = plot(t,ySp(1)*ones(size(t)));
set(h,'LineWidth',spWid);

%============================================================
% Draw the Ground
grdWid = 0.02;
%grdLgth = 0.92;
%spacing = (1-grdLgth)/2;
%xPos = [spacing spacing 1-spacing 1-spacing];
spacing = (1-0.6-carWid)/2;
xPos = [0.1-spacing 0.1-spacing 0.6+carWid+spacing 0.6+carWid+spacing];
ytop = 0.4-wheelRad;
ybot = ytop-grdWid;
yPos = [ybot ytop ytop ybot];
patch(xPos,yPos,[.5 .5 .5]);

%============================================================