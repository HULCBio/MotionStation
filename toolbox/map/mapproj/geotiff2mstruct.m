function mstruct = geotiff2mstruct(gtif)
%GEOTIFF2MSTRUCT Convert GeoTIFF info to a map projection structure.
%
%   MSTRUCT = GEOTIFF2MSTRUCT(INFO) converts the GeoTIFF info structure,
%   INFO, to the map projection structure, MSTRUCT.
%
%   Example 
%   -------
%   % Verify the info structure from 'boston.tif' converts
%   % to a mstruct.
%
%   % Obtain the info structure of 'boston.tif'.
%   info = geotiffinfo('boston.tif');
%
%   % Get the projection list structure for conversion from
%   % GeoTIFF to a map projection structure.
%   S = projlist('all');
%
%   % Verify info converts to a mstruct.
%   id = strmatch(info.CTProjection,{S.GeoTIFF},'exact');
%   if ~isempty(id) && S(id).mstruct
%     mstruct = geotiff2mstruct(info);
%   else
%     fprintf('Unable to convert %s to a mstruct.\n',info.CTProjection);
%   end
%
%   See also AXESM, GEOTIFFINFO, PROJFWD, PROJINV, PROJLIST.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:59:01 $

checknargin(1,1,nargin,mfilename);

% Verify the input structure
if ~isGeoTiff(gtif)
  eid = sprintf('%s:%s:invalidGeoTIFF', getcomp, mfilename);
  msg = sprintf('The GeoTIFF structure is not valid.');
  error(eid, '%s',msg)
end

% Get the projection code structure
code = projcode(gtif.CTProjection);
if (isequal(code.mapprojection,'Unknown'))
  eid = sprintf('%s:%s:unknownPROJ', getcomp, mfilename);
  msg = sprintf('%s%s%s\n%s', ...
                'The GeoTIFF projection ''', ...
                gtif.CTProjection, ...
                ''' can not be converted to an mstruct.', ...
                'Consider using PROJFWD or PROJINV.');
  error(eid, '%s',msg)
end

% Create a default mstruct using the mapprojection name
mstruct = defaultm(code.mapprojection);

% Get the mstruct projection parameters from GeoTIFF
[origin, parallels, scale, easting, northing] = getProjParm( code.index, ...
 gtif.ProjParm(1:2), gtif.ProjParm(3:4), gtif.ProjParm(5), ...
 gtif.ProjParm(6), gtif.ProjParm(7));

% Reshape the origin and mapparallels
mstruct.origin = reshape(origin,1,2) ;
mstruct.mapparallels = reshape(parallels,1,2);

% scalefactor must be 1 if not set
if (isequal(scale,0))
  mstruct.scalefactor = 1;
else
  mstruct.scalefactor = scale;
end

% Assign the falseeasting and northing parameters
mstruct.falseeasting  = easting; 
mstruct.falsenorthing = northing; 

% Set reasonable map limits
mstruct.maplatlimit=[min(gtif.CornerCoords.LAT) max(gtif.CornerCoords.LAT)];
mstruct.maplonlimit=[min(gtif.CornerCoords.LON) max(gtif.CornerCoords.LON)];

% Set the 'geoid' field 
mstruct.geoid = [gtif.SemiMajor  axes2ecc(gtif.SemiMajor, gtif.SemiMinor)];

% Verify the mstruct
mstruct = defaultm(mstruct);
