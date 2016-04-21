function drawbox(x,y,xle,yle,color,tstr)
%DRAWBOX Draws a rectangular box with text in it.

%   Author(s): A. Charry
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 15:16:27 $

% Draw a rectangular patch. 
% x,y are the upper left hand co-ordinates
% and xle and yle are the width and height respectively.

pH = patch([x x x+xle x+xle x],[y y-yle y-yle y y],color); 
set(pH,'LineWidth',1);
tH = text(x+xle/2,y-yle/2,tstr,'Fontsize',8);
set(tH,'Horizontal','Center');

