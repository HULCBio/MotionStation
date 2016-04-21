function out = ctrltbu1(x)
% CTRLTBU1 controller for the truck backer-upper when distance is far.

%   Roger Jang, 10-21-93, 1-16-94, 11-7-94
%   Copyright 1994-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/14 22:16:29 $

distance = norm(x(1:2));
alpha = acos(x(1)/distance) - pi/2; % abs(alpha) <= pi/2
tmp = x(3) - pi/2 - alpha;
beta = tmp - round(tmp/2/pi)*2*pi; % abs(beta) <= pi
out = - 3*alpha + 2*beta;
out = max(-pi/4, min(pi/4, out));
