function [x,y,colheadings,timeunits] = getdata(h,name)
%GETDATA
%
% Author(s): James G. Owen
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:48 $

% This method is called by the java detaset combo callback to
% populate the table view

% Find current data set 
h.Position = find(strcmp(name,get(h.Datasets,{'Name'})));

% Get column headings
colheadings = {['Time (', h.Datasets(h.Position).TimeUnits ')'], h.Datasets(h.Position).Headings{:}};

% Return time units so that filter frequency units and time constants can
% display correctly
timeunits = h.Datasets(h.Position).TimeUnits;

% Get data
x = h.Datasets(h.Position).Time;
y = h.Datasets(h.Position).Data(:);

% Hide the graphical edit window if it is open since this is a new dataset
h.setgraphvisibility('off')
