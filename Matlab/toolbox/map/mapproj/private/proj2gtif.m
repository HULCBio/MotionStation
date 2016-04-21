function gtif  = proj2gtif(proj)
%PROJ2GTIF Convert a projection structure to a GTIF structure.
%
%   GTIF = PROJ2GTIF(PROJ) returns a GTIF structure. PROJ is
%   a structure returned from GEOTIFFINFO or a valid MSTRUCT.
%
%   See also GEOTIFFINFO, MSTRUCT2GTIF.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:25 $

if isGeoTiff(proj)
  % GeoTIFF
  gtif = proj;
  % Verify GeoTIFF
  code = projcode(gtif.CTProjection);
  if (isequal(code.CTcode, 32767))
    eid = sprintf('%s:%s:invalidGeoTIFF', getcomp, mfilename);
    msg = sprintf('The GeoTIFF structure does not contain valid fields.');
    error(eid, '%s',msg)
  end
  gtif.GeoTIFFCodes = int16GeoTiffCodes(gtif.GeoTIFFCodes);
elseif ismstruct(proj)
  % mstruct
  gtif = mstruct2gtif(proj);
else
  eid = sprintf('%s:%s:invalidPROJ', getcomp, mfilename);
  msg = sprintf('The PROJ structure does not contain valid fields.');
  error(eid, '%s',msg)
end

