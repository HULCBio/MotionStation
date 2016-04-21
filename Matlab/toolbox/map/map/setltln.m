function [lat,lon,badindx] = setltln(map,maplegend,row,col)

%SETLTLN  Convert data grid rows and colums to latitude-longitude.
%
%  [lat,lon] = SETLTLN(map,maplegend,row,col) converts row and column
%  matrix index vectors to the corresponding latitude and longitude
%  positions for the supplied regular matrix map.
%
%  [lat,lon,badindx] = SETLTLN(...) returns the vector badindx containing
%  the indices of points falling outside the map.
%
%  mat = SETLTLN(...) returns a single output, where mat = [lat lon].
%
%   See also SETPOSTN, LTLN2VAL, PIX2LATLON.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.2 $    $Date: 2003/12/13 02:53:07 $


if nargin ~= 4;	 error('Incorrect number of arguments');   end

%  Input dimension tests

if ~isequal(size(row),size(col))
    error('Inconsistent dimensions on row and col inputs')
elseif ndims(map) > 2
    error('Input map can not have pages')
elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')
elseif any([~isreal(maplegend) ~isreal(row) ~isreal(col)])
    warning('Imaginary parts of complex arguments ignored')
	maplegend = real(maplegend);   row = real(row);   col = real(col);
end

%  Ensure integer row and column inputs

row = round(row);    col = round(col);

%  Test the input data to lie within the map

[r,c] = size(map);
badindx = find( row>r | row<1 | col>c | col<1);
if ~isempty(badindx)
     warning('Points lie outside of the map')
	 row(badindx) = [];    col(badindx) = [];
end

%  Get the limits of the map

[latlim,lonlim] = limitm(map,maplegend);

%  Compute the latitude and longitude of the row/col data
%  Assume that each point is in the center of the specified
%  cell (hence the use of delta/2 below).

delta = 1/maplegend(1);
lat   = min(latlim) + (row-1)*delta + delta/2;
lon   = min(lonlim) + (col-1)*delta + delta/2;

%  Set the output arguments if necessary

if nargout < 2;   lat = [lat lon];  end
