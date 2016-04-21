function [xe, ye] = poly2edgelist(x,y,scale)
%POLY2EDGELIST Computes list of horizontal edges from polygon.
%   [XE,YE] = POLY2EDGELIST(X,Y) rescales the polygon represented
%   by vectors X and Y by a factor of 5, and then quantizes them to
%   integer locations.  It then creates a new polygon by filling in
%   new vertices on the integer grid in between the original scaled
%   vertices.  The new polygon has only horizontal and vertical
%   edges.  Finally, it computes the locations of all horizontal
%   edges, returning the result in the vectors XE and YE.
%
%   [XE,YE] = POLY2EDGELIST(X,Y,SCALE) rescales by a factor of
%   SCALE instead of 5.  SCALE must be a positive odd integer.
%
%   See also EDGELIST2MASK, POLY2MASK, ROIPOLY.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/01/26 06:00:50 $

if nargin < 3
    scale = 5;
end

% Scale and quantize (x,y) locations to the higher resolution grid.
x = round(scale*(x - 0.5) + 1);
y = round(scale*(y - 0.5) + 1);

num_segments = length(x) - 1;
x_segments = cell(num_segments,1);
y_segments = cell(num_segments,1);
for k = 1:num_segments
    [x_segments{k},y_segments{k}] = intline(x(k),x(k+1),y(k),y(k+1));
end

% Concatenate segment vertices.
x = cat(1,x_segments{:});
y = cat(1,y_segments{:});

% Horizontal edges are located where the x-value changes.
d = diff(x);
edge_indices = find(d);
xe = x(edge_indices);

% Wherever the diff is negative, the x-coordinate should be x-1 instead of
% x.
shift = find(d(edge_indices) < 0);
xe(shift) = xe(shift) - 1;

% In order for the result to be the same no matter which direction we are
% tracing the polynomial, the y-value for a diagonal transition has to be
% biased the same way no matter what.  We'll always chooser the smaller
% y-value associated with diagonal transitions.
ye = min(y(edge_indices), y(edge_indices+1));


