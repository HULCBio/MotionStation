function f = terrainfun(pop)
%TERRAINFUN finds the elevation at any (x,y) where, (x,y) are in easting
%and northing units. you must load the file "mtWashington.mat" before
%calling this function. 
%
%Credit:
%   United States Geological Survey (USGS) 7.5-minute Digital Elevation
%   Model (DEM) in Spatial Data Transfer Standard (SDTS) format for the
%   Mt. Washington quadrangle, with elevation in meters.
%   http://edc.usgs.gov/products/elevation/dem.html

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:15 $

% (x,y) are co-ordinates of a point in easting and northing units
% respectively and Z is the elevation in feets.

global x y Z HPOINTS TIMETOPLOT HBEST POPU
POPU = pop;

f = interp2(x,y,Z,pop(:,1),pop(:,2));
% We want to maximize, hence negative
f = -f;