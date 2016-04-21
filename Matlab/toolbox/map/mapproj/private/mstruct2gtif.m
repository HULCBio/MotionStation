function gtif = mstruct2gtif(mstruct)
%MSTRUCT2GTIF Convert a mstruct to GTIF.
%
%   GTIF = MSTRUCT2GTIF(MSTRUCT) Converts the mstruct, MSTRUCT, to a
%   limited GeoTIFF structure, GTIF. The MSTRUCT's geoid vector must be in
%   units of 'meters'.
%
%   Example
%   -------
%      mstruct = defaultm('miller');
%      mstruct.geoid = almanac('earth','clarke66','m');
%      gtif = mstruct2gtif(mstruct);
%
%   See also GEOTIFF2MSTRUCT, PROJ2GTIF.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/02/01 22:01:36 $


% Verify the mstruct
if ~ismstruct(mstruct)
  eid = sprintf('%s:%s:invalidMSTRUCT', getcomp, mfilename);
  msg = sprintf('The MSTRUCT does not contain valid fields.');
  error(eid,'%s',msg)
end

% Get the projection code conversion structure
code = projcode(mstruct.mapprojection);
if ( isequal(code.CTProjection, 'CT_LambertConfConic_2SP') && ...
     mstruct.nparallels < 2)
  code = projcode('CT_LambertConfConic_1SP');
end
if (isequal(code.mapprojection,'Unknown'))
  eid = sprintf('%s:%s:unknownPROJ', getcomp, mfilename);
  msg = sprintf('The map projection ''%s'' cannot be converted to GeoTIFF.', ...
                mstruct.mapprojection);
  error(eid,'%s',msg)
end

% Assign default GeoTIFFCode values
GeoTIFFCodes = initGeoTIFFCodes;

% Get the SemiMajor and Minor axes
gtif.SemiMajor = mstruct.geoid(1);
if (numel(mstruct.geoid) < 2)
   mstruct.geoid(2) = 0;
end
gtif.SemiMinor = minaxis(mstruct.geoid);

% Get the Ellipsoid code number if known 
Ellipsoid = findEllipsoid(mstruct.geoid);
if ~isempty(Ellipsoid)
  GeoTIFFCodes.Ellipsoid = Ellipsoid;
end
  
% Get the projection parameters
[origin, parallels, scale, easting, northing] = getProjParm( code.index, ...
         mstruct.origin, mstruct.mapparallels, mstruct.scalefactor, ...
         mstruct.falseeasting, mstruct.falsenorthing);
gtif.ProjParm = zeros(7,1);
gtif.ProjParm(1:2) = origin;
gtif.ProjParm(3:4) = parallels;
gtif.ProjParm(5) = scale;
gtif.ProjParm(6) = easting;
gtif.ProjParm(7) = northing;

% Set the GTIF CT projection
gtif.projname             = code.projname;
gtif.CTProjection         = code.CTProjection;
GeoTIFFCodes.CTProjection = code.CTcode;

% Set the GeoTIFFCodes
gtif.GeoTIFFCodes = GeoTIFFCodes;
gtif.GeoTIFFCodes = int16GeoTiffCodes(gtif.GeoTIFFCodes);

%--------------------------------------------------------------------------
function GeoTIFFCodes = initGeoTIFFCodes
% Default GeoTIFFCode values
GeoTIFFCodes.Model = 1;
GeoTIFFCodes.PCS = 32767;
GeoTIFFCodes.GCS = 32767;
GeoTIFFCodes.UOMAngle = 32767;
GeoTIFFCodes.Datum = 32767;
GeoTIFFCodes.PM = 32767;
GeoTIFFCodes.ProjCode = 32767;
GeoTIFFCodes.Projection= 32767;
GeoTIFFCodes.MapSys = 32767;

% Default units to meters for now
GeoTIFFCodes.UOMLength = 9001;

%--------------------------------------------------------------------------
function ellipsoid = findEllipsoid(geoid)
% Convert known PROJ4 ellipsoids
ellipsoids = [almanac('earth','grs80', 'm'); ...
              almanac('earth','clarke66', 'm'); ...
              almanac('earth','clarke80', 'm')];
indx = find((geoid(1) == ellipsoids(:,1)) &  ...
            (abs(geoid(2)-ellipsoids(:,2)) < 1e-13));
ellipsoid = [];
if isempty(indx)
  return 
end
switch (indx)
  case 1
     ellipsoid = 7019;
  case 2
     ellipsoid = 7008;
  case 3
     ellipsoid = 7034;
end
