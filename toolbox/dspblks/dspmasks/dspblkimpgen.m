function [x, y] = dspblkimpgen
% DSPBLKIMPGEN Signal Processing Blockset Discrete Impulse Generator block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:06:43 $

blk = gcbh;

% Set up rectangular boxes/data points
nPts = 5;
dist = 0.6/nPts;
dx   = dist/3; dy = dist/3;
x    = (.1:1/nPts:.9);
z    = zeros(size(x));
imp  = [0 0 .5-dy 0 0];
y    = [0 0 .5 0 0];
n = NaN; n = n(ones(size(x)));
xn   = [x-dx; x+dx; x+dx; x-dx; x-dx; n; x; x; n];
yn   = [y-dy; y-dy; y+dy; y+dy; y-dy; n; z; imp; n];

% Set up x-axis
v = x;
offset = dx;
xline=[v(1)+offset v(2)-offset NaN v(2)+offset v(4)-offset NaN ...
       v(4)+offset v(5)-offset];

yline=[0 0 NaN 0 0 NaN 0 0];

% Final plotting variables
xn=xn(:);
yn=yn(:);
x=[xn; NaN; xline'];
y=[yn; NaN; yline'];


    
    