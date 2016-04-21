%LABELACC Script to add labels and forces to ACC benchmark schematic.
%   LABELACC labels the schematic drawn by DRAWACC. This is a
%   subroutine used by ACCDM2.

%   Denise L. Chen, 8-93
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/16 22:19:42 $

%====================================================================
% Text Parameters 
%offset = 0.02;
offset = 0.04;
yPos1 = 0.5+2.5*offset;
yPos2 = 0.5+offset;
yPos2a = 0.5-offset;
yPos1a= 0.5-2.5*offset;

%====================================================================
% Draw and Label the Control and Disturbance Forces

% The Control Force u

forcLgth = 0.1;
forcWid = spWid;
forcClr = 'y';
arrWid = 0.03;
arrLgth = arrWid/2;

% draw the straight line part
%arrleft = 0.4-carWid-forcLgth;
arrleft = 0.1-forcLgth;
h = plot(arrleft: forcLgth: arrleft+forcLgth, [0.5 0.5], forcClr);
set(h,'LineWidth',forcWid);

% draw the arrowhead
left = arrleft+forcLgth-arrLgth;
right = left+arrLgth;
xPos = [left right left];
yPos = [0.5*arrWid+0.5 0.5 0.5-0.5*arrWid];
patch(xPos,yPos,forcClr);

% label the control force
h1 = text(arrleft-offset,yPos1,'Control');
h2 = text(arrleft+0.5*forcLgth,yPos2,'u');

uHndl = [h1 h2];

% The Disturbance w

% draw the straight line part
arrleft = 0.6+carWid;
h = plot(arrleft: forcLgth: arrleft+forcLgth, [0.5 0.5], forcClr);
set(h,'LineWidth',forcWid);

% draw the arrowhead
left = arrleft+forcLgth-arrLgth;
right = left+arrLgth;
xPos = [left right left];
yPos = [0.5*arrWid+0.5 0.5 0.5-0.5*arrWid];
patch(xPos,yPos,forcClr);

% label the disturbance force
twid = 0.015;
h1 = text(arrleft+0.5*offset,yPos2a,'Disturbance');
h2 = text(arrleft+2*offset,yPos1a,'w');
%h1 = text(arrleft+offset,yPos2a,'Disturbance');
%h2 = text(arrleft+4*offset,yPos1a,'w');

dHndl = [h1 h2];

%====================================================================
% Label the Spring Constant
kHndl = text(0.47,yPos2,'k');
%kHndl = text(0.5,yPos2,'k');

%====================================================================
% Draw and Label the Distance Parameters x1 and x2
distHt = 0.07;
yPos3 = 0.4+carHt+distHt;
distClr = 'w';

%%%%%%%%%%%%%
% x1 Case
% draw the straight line part
%arrleft = 0.4-carWid/2;
arrleft = 0.1+carWid/2;
h = plot(arrleft: forcLgth: arrleft+forcLgth, [yPos3 yPos3], distClr);
set(h,'LineWidth',forcWid);

% draw the arrowhead
left = arrleft+forcLgth-arrLgth;
right = left+arrLgth;
xPos = [left right left];
yPos = [0.5*arrWid+yPos3 yPos3 yPos3-0.5*arrWid];
patch(xPos,yPos,distClr);

% draw the reference line in 
h = plot([arrleft arrleft],[yPos3-distHt yPos3+distHt],'w');
set(h,'LineWidth',forcWid);

% label x1
text(right+offset, yPos3, 'x1');

%%%%%%%%%%%%%
% x2 Case
% draw the straight line part
arrleft = 0.6+carWid/2;
h = plot(arrleft: forcLgth: arrleft+forcLgth, [yPos3 yPos3], distClr);
set(h,'LineWidth',forcWid);

% draw the arrowhead
left = arrleft+forcLgth-arrLgth;
right = left+arrLgth;
xPos = [left right left];
yPos = [0.5*arrWid+yPos3 yPos3 yPos3-0.5*arrWid];
patch(xPos,yPos,distClr);

% draw the reference line in 
h = plot([arrleft arrleft],[yPos3-distHt yPos3+distHt],'w');
set(h,'LineWidth',forcWid);

% label x2
text(right+offset, yPos3, 'x2');
text(right, yPos3+1.5*offset, 'Measurement');
