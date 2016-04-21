function reservedNames = geoReservedNames
%GEOFIELDNAMES Return the reserved field names of a geographic data structure. 
%
%   NAMES = GEOFIELDNAMES Returns the reserved geographic data structure
%   field names in the cell array NAMES.
%
%   See also GEOATTRIBNAMES, GEOATTRIBSTRUCT.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:34 $

% Return the field names that are reserved
reservedNames = {'Geometry', 'X', 'Y', 'Lat', 'Lon', ...
                 'BoundingBox', 'Height', 'INDEX'};

