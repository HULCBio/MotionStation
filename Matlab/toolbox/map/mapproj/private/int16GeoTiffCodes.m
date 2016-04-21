function icodes = int16GeoTiffCodes(codes)
%INT16GEOTIFFCODES Converts the GeoTIFF double codes to type int16.
%
%   ICODES = INT16GEOTIFFCODES(CODES) Converts the fields of CODES  to type
%   INT16 and returns the structure as ICODES.
%
%   See also PROJ2GTIF, MSTRUCT2GTIF.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:19 $

if ~isstruct(codes)
    eid = sprintf('%s:%s:invalidGeoTIFFCodes', getcomp, mfilename);
    msg = sprintf('The GeoTIFFCodes parameter is not a structure.');
    error(eid, '%s',msg)
end
fields = fieldnames(codes);
icodes = codes;
for k=1:length(fields);
    if (isnumeric(codes.(fields{k})))
       icodes.(fields{k})= int16(codes.(fields{k}));
    else
       eid = sprintf('%s:%s:invalidGeoTIFFCodes', getcomp, mfilename);
       msg = sprintf('The GeoTIFFCodes field ''%s'' is not numeric.', ...
                     fields{k});
       error(eid, '%s',msg)
    end
end
