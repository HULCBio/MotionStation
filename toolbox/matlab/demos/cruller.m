%% Cruller
% Construct a cruller by revolving the eccentric ellipse defined by the
% function XYCRULL.
%
% Thanks to C. Henry Edwards, Dept. of Mathematics, Univerity of 
% Georgia, 6/20/93.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 5.11.4.1 $  $Date: 2004/03/02 21:46:48 $

ab = [0 2*pi];
rtr = [8 1.5 1];
pq = [40 40];
box = [-10 10 -10 10 -3 3];
vue = [90 50];

tube('xycrull',ab,rtr,pq,box,vue)
colormap(hot);
view(-37.5,65);
