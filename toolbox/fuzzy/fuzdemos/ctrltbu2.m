function out = ctrltbu2(x)
% CTRLTBU2 controller for the truck backer-upper when distance is near.

%   Roger Jang, 10-21-93, 1-16-94, 11-7-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:16:41 $

tmp = (x(3) - pi/2) - round((x(3)-pi/2)/(2*pi))*(2*pi); % abs(tmp) < pi
out = x(1)/8 + tmp;
out = max(-pi/4, min(pi/4, out));

