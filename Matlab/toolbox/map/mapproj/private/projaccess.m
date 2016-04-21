function [a, b]  = projaccess(fcn, proj, in_x, in_y);
%PROJACCESS Process a PROJ.4 projection.
%
%   [A, B] = PROJACCESS(FCN, PROJ, IN_X, IN_Y) returns the transformed
%   coordinates, A, B from the PROJ.4 projection.  FCN is a string with
%   value 'fwd', or 'inv',  indicating a forward or inverse projection. If
%   FCN is 'inv', then A and B are latitude and longitude arrays;
%   otherwise, A and B are map X and Y coordinates. PROJ is a structure
%   defining the map projection.  PROJ may be a map projection MSTRUCT or a
%   GeoTIFF INFO structure.  IN_X and IN_Y are arrays of longitude and
%   latitude or X and Y map coordinates. 
%
%   See also PROJFWD, PROJINV, PROJLIST.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/10 23:23:21 $

% Get the PROJ.4 directories
[epsgDirName, projDirName] = feval(mapgate('getprojdirs'));

% Process the points using PROJ.4
[a, b] = feval(['gtifproj4' lower(fcn)], proj2gtif(proj), in_x, in_y, ...
               epsgDirName, projDirName);

% Reshape output to the input and convert Inf to NaN.
a = reshape(a,size(in_x));
a(a==Inf) = NaN;
b = reshape(b,size(in_y));
b(b==Inf) = NaN;

%#function gtifproj4fwd gtifproj4inv
