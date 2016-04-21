function out = xpbanplt(currPos,prevPos)
%XPBANPLT Plots one step of solution path. Used by BANDEM.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/03/22 23:54:53 $

if nargin==1,
    x1=currPos(1);
    y1=currPos(2);
    z1=100*(y1-x1.^2).^2+(1-x1).^2;
    plot3(x1,y1,z1,'r.', ...
        'EraseMode','none', ...
        'MarkerSize',25);
    drawnow; % Draws current graph now
    out = [];

elseif nargin==2,
    x1=prevPos(1);
    x2=currPos(1);
    y1=prevPos(2);
    y2=currPos(2);
    z1=100*(y1-x1.^2).^2+(1-x1).^2;
    z2=100*(y2-x2.^2).^2+(1-x2).^2;

    plot3([x1 x2],[y1 y2],[z1 z2],'b-', ...
        'EraseMode','none', ...
        'LineWidth',2); 
    plot3([x1 x2],[y1 y2],[z1 z2],'r.', ...
        'EraseMode','none', ...
        'MarkerSize',25);

    drawnow; % Draws current graph now 
    out = [];
end
