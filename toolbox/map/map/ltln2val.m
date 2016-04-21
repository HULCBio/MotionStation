function code = ltln2val(map,maplegend,lat,long,method)

%LTLN2VAL  Returns map code value associated with positions
%
%  code = LTLN2VAL(map,maplegend,lat,long) returns a column
%  vector of a map's encoded values corresponding to the points
%  specified by column vectors of latitude and longitude.  The
%  map codes are determined using nearest neighbor interpolation
%  with the input latitude and longitude.
%
%  code = LTLN2VAL(map,maplegend,lat,long,'method') uses 'method'
%  to specify the interpolation scheme.  Allowable 'method'
%  strings are:  'bilinear' for linear interpolation;
%  'bicubic' for cubic interpolation; and 'nearest' for nearest
%  neighbor interpolation.
%
%  See also FINDM


%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:16:57 $


if nargin < 4
	error('Incorrect number of arguments');
elseif nargin == 4
    method = 'nearest';
end


%  Ensure that lat and long are consistently dimensioned

if ~isequal(size(lat),size(long))
    error('Inconsistent dimensions of lat and lon inputs')

elseif ndims(map) > 2
    error('Input map can not have pages')

elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')

elseif any([~isreal(lat) ~isreal(long)])
    warning('Imaginary parts of complex LAT and/or LONG arguments ignored')
	lat = real(lat);    long = real(long);
end

%  Get the limits of the map.

[latlim,lonlim] = limitm(map,maplegend);

%  Construct vectors corresponding to the row and column indices
%  for the map.  These vectors are constructed so that the interp2
%  function produces the correct result.  Each entry represents the
%  maximum x and y value which the matrix cell may represent.

row = 1:size(map,1);     col = 1:size(map,2);

delta  = 1/maplegend(1);
latvec = min(latlim)-delta/2 + row*delta;
lonvec = min(lonlim)-delta/2 + col*delta;

%  Adjust for any points falling between min(latlim) and the
%  first entry in latvec.  Similar adjustment for longitude data

indx = find(lat >= min(latlim) & lat <= min(latvec));
if ~isempty(indx);   lat(indx) = min(latvec);  end;

indx = find(long >= min(lonlim) & long <= min(lonvec));
if ~isempty(indx);   long(indx) = min(lonvec);  end;


%  If the interpolation method is nearest, do not call interp2.
%  It is extremely time consuming.  Instead, simply compute the
%  map indices and get the corresponding codes.

if method(1) == 'n'
    indx = setpostn(map,maplegend,lat,long)	;
    code = map(indx);
else

%  Note that latvec matches the rows of the map (Y dimension)
%  and lonvec matches the columns of the map (X dimension)

    code = interp2(lonvec,latvec,map,long,lat,method);
end

