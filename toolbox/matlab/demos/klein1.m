%% Klein Bottle
% Generate a Klein bottle by revolving the figure-eight curve defined by
% XYKLEIN.
% 
% Thanks to C. Henry Edwards, Dept. of Mathematics, Univerity of 
% Georgia, 6/20/93.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 5.13.4.1 $  $Date: 2004/03/02 21:46:52 $

ab = [0 2*pi];
rtr = [2 0.5 1];
pq = [40 40];
box = [-3 3 -3 3 -2 2];
vue = [55 60];

tube('xyklein',ab,rtr,pq,box,vue);
shading interp
colormap(pink);
