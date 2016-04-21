%MTWASHINGTONDEMO  load data for white mountains and open PSEARCHTOOL with a problem
%for pattern search.
%Credit:
%   United States Geological Survey (USGS) 7.5-minute Digital Elevation
%   Model (DEM) in Spatial Data Transfer Standard (SDTS) format for the
%   Mt. Washington quadrangle, with elevation in meters.
%   http://edc.usgs.gov/products/elevation/dem.html

%   Copyright 2004 The MathWorks, Inc.  
%   $Revision: 1.1 $  $Date: 2004/01/14 15:35:19 $

%Load data for white mountains
load mtWashington   
%Load psproblem which have all required settings for pattern search
load psproblem
%Open PSEARCHTOOL.
psearchtool(psproblem)
