function [latbin,lonbin,count,wcount] = histr(lats,lons,bindensty,units)

%HISTR  Spatial equirectangular histogram
%
%  [lat,lon,ct] = HISTR(lat0,lon0) computes a spatial histogram of
%  geographic data using equirectangular binning of one degree.  In
%  other words, one degree increments of latitude and longitude to
%  define the bins throughout the globe.  As a result, these bins are
%  not equal area.  The outputs are the location of bins in which the
%  data was accumulated, as well as the number of occurrences in these bins.
%
%  [lat,lon,ct] = HISTR(lat0,lon0,binsize) uses the bin size specified
%  by the input.  This input must be in the same units as the lat and
%  lon input.
%
%  [lat,lon,ct] = HISTR(lat0,lon0,'units') and
%  [lat,lon,ct] = HISTR(lat0,lon0,binsize,'units') use the input
%  'units' to define the angle units of the inputs and outputs.
%  If omitted, 'degrees' are assumed.
%
%  [lat,lon,ct,wt] = HISTR(...) returns the number of occurrences,
%  weighted by the area of each bin.  The weighting factors assume that
%  bins along the equator are given an area of 1.0.
%
%  See also HISTA

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:31 $


if nargin < 2
    error('Incorrect number of arguments')

elseif nargin == 2
 units = [];               bindensty = [];

elseif nargin == 3
    if isstr(bindensty)
     units = bindensty;    bindensty = [];
 else
     units = [];
 end
end

%  Empty argument tests

if isempty(units);       units = 'degrees';   end
if isempty(bindensty);   bindensty = 1;       end

%  Argument tests

if ~isequal(size(lats),size(lons))
    error('Inconsistent latitude and longitude dimensions')
elseif max(size(bindensty)) ~= 1
    error('Scalar bin density is required')
elseif ~isreal(bindensty)
    warning('Imaginary part of complex BINDENSITY argument ignored')
 bindensty = real(bindensty);
end

%  Convert to degrees and ensure column vectors
%  Ensure that the longitude data is between -180 and 180

lats = angledim(lats(:),units,'degrees');
lons = angledim(lons(:),units,'degrees');
lons = npi2pi(lons,'degrees','exact');

%  Construct a sparse matrix to bin the data into

latlim = [floor(min(lats))   ceil(max(lats))];
lonlim = [floor(min(lons))   ceil(max(lons))];

[map,maplegend] = spzerom(latlim,lonlim,bindensty);

%  Bin the data into the sparse matrix

indx = setpostn(map,maplegend,lats,lons,'degrees');
for i = 1:length(indx);   map(indx(i)) = map(indx(i)) + 1;   end

%  Determine the locations of the binned data

[row,col,count] = find(map);
[latbin,lonbin] = setltln(map,maplegend,row,col);

%  Convert back to the proper units

latbin = angledim(latbin,'degrees',units);
lonbin = angledim(lonbin,'degrees',units);

%  Determine the data occurrences weighted by the bin area
%  If this output is not requested, don't waste time calculating it.

if nargout == 4
    [a,areavec]=areamat(map>0,maplegend);
    wcount = full(max(areavec(row)) * count ./ areavec(row) );
end
