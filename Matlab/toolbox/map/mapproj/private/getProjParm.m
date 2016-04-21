function [origin, parallels, scalefactor, ...
          easting, northing] = getProjParm( projnum, ...
                                            in_origin, in_parallels, ...
                                            in_scalefactor, ...
                                            in_easting, in_northing)
%GETPROJPARM Get the projection parameters based on a proj number.
%
%   [ORIGIN, PARALLELS, SCALEFACTOR, ...
%    EASTING, NORTHING] = GETPROJPARM( PROJNUM, ...
%                                     IN_ORIGIN, IN_PARALLELS, ...
%                                     IN_SCALEFACTOR, ...
%                                     IN_EASTING, IN_NORTHING)
%   Converts GeoTiff to MSTRUCT or MSTRUCT to GeoTiff projection
%   parameters.   Returns the projection parameters given an input
%   projection code and the input projection parameters. PROJNUM is the
%   projection code number as defined by the function PROJCODE. 
%
%   See also GEOTIFF2MSTRUCT, MSTRUCT2GTIF, PROJCODE.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:15 $

% Set the input origin vector to 2 elements
if (isempty(in_origin))
  in_origin = [0 0];
end
in_origin    = in_origin(1:2);

% Set the input parallels vector to 2 elements
if (isempty(in_parallels))
  in_parallels = [0 0];
end
if (numel(in_parallels) < 2)
  in_parallels(2) = 0; 
end
in_parallels = in_parallels(1:2);

% Copy the input to the output
origin      = in_origin;
parallels   = in_parallels;
scalefactor = in_scalefactor;
easting     = in_easting;
northing    = in_northing;

% Make sure the scalefactor is 1 if 0 or empty
if (isempty(scalefactor))
  scalefactor=1;
end

% Make sure the easting and northing are 0 if empty
if (isempty(easting))
  easting=0;
end
if (isempty(northing))
  northing=0;
end

% Switch cases that do not fit standard
switch (projnum)

  case 11    % Albers 
     origin = in_parallels;
     parallels = in_origin;

  case 13    % Equidistant conic
     origin = in_parallels;
     parallels = in_origin;

end


