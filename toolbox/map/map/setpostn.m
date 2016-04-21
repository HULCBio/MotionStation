function [row,col,badindx] = setpostn(map,maplegend,lat,long,units)

%SETPOSTN  Convert latitude-longitude to data grid rows and columns.
%
%  indx = SETPOSTN(map,maplegend,lat,long) converts Greenwich frame
%  lat/long data to the indices of the regular matrix coordinate frame.
%  The input angle data must be in degrees.
%
%  [row,col] = SETPOSTN(...) returns the indices in row/column format.
%
%  [row,col,badindx] = SETPOSTN(...) returns the vector badindx containing
%  the indices of points falling outside the map.
%
%  See also LATLON2PIX, LTLN2VAL, SETLTLN.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%  $Revision: 1.12.4.2 $    $Date: 2003/12/13 02:53:08 $


if nargin < 4;              error('Incorrect number of arguments')
    elseif nargin == 4;     units = 'degrees';
end


%  Input dimension tests

if ~isequal(size(lat),size(long))
    error('Inconsistent dimensions on lat and long inputs')
elseif ndims(map) > 2
    error('Input map can not have pages')
elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')
elseif any([~isreal(lat) ~isreal(long) ~isreal(maplegend)])
    warning('Imaginary parts of complex arguments ignored')
	lat = real(lat);    long = real(long);  maplegend = real(maplegend);
end

%  Initialize output

badpts = [];

%  Test the input data to lie within the map

[latlim,lonlim] = limitm(map,maplegend);

originalLong = long;

if any(lonlim<0);
	long = npi2pi(long);
else 
	long = zero22pi(long);
end

% SPECIAL CASE I ---
% Left edge of map starts on a Western Lontitude (maplegend(3) < 0)
% and crosses across the Prime Meridian (travelling East)
if maplegend(3) < 0 & sign(lonlim(1)) == -1 & sign(lonlim(2)) == 1
    indx = find(long<lonlim(1));
    if ~isempty(indx)
        long(indx) = long(indx)+360;
    end
end

% SPECIAL CASE II ---
% Left edge of map starts on a Eastern Longitude (maplegend(3) > 0)
% and crosses across the Prime Meridian (travelling East)
if maplegend(3) > 0 & sign(lonlim(1)) == 1 & sign(lonlim(2)) == 1
    indx = find(long<lonlim(1));
    if ~isempty(indx)
        long(indx) = long(indx)+360;
    end
end

badindx = find( lat  > max(latlim) | lat  < min(latlim) | ...
                long > max(lonlim) | long < min(lonlim) );
if ~isempty(badindx)
     warning('Point outside of the map')
	 lat(badindx) = [];    long(badindx) = [];
end


%  Get the map starting position in cell coordinates

latdiff = lat  - min(latlim);
londiff = long - min(lonlim);

row = ceil(roundn(latdiff*maplegend(1),-6));
col = ceil(roundn(londiff*maplegend(1),-6));

%  Adjust the row and column positions at map start

indx = find(row < 1);
if ~isempty(indx);   row(indx) = 1;   end

indx = find(col < 1);
if ~isempty(indx);    col(indx) = 1;  end

%  Set the output matrix if necessary

if nargout < 2;   row = (col-1)*size(map,1) + row;   end

