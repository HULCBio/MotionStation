function [X, Y, W] = cfviewdata(dataset)
% CFVIEWDATA Helper function for the Curve Fitting toolbox viewdata panel
%
%    [X, Y, W] = CFVIEWDATA(DATASET)
%    returns the x, y and w values for the given dataset
%	 (in a manner that the Java GUI can use)

%   Copyright 2001-2004 The MathWorks, Inc. 
%   $Revision: 1.2.2.1 $  $Date: 2004/02/01 21:40:19 $

ds = handle(dataset);
X = ds.x;
Y = ds.y;
W = ds.weight;
