function [map,badpts] = imbedm(lat,long,code,map,maplegend,units)

%IMBEDM  Encodes data points into a regular matrix map
%
%  map = IMBEDM(lat,long,value,map,maplegend) encodes data
%  points into a regular matrix map.  The input value can
%  be either a scalar which is then used for all lat, long points,
%  or a matrix of the same size as the lat, long points
%
%  See also SETPOSTN, LTLN2VAL

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:40 $

if nargin < 5
     error('Incorrect number of arguments.')
elseif nargin == 5
     units = [];
end

%  Input checks

if isempty(units);          units = 'degrees';              end
if length(code) == 1;    code = code(ones(size(lat)));   end

if ~isequal(size(lat),size(long),size(code))
    error('Inconsistent dimensions for the lat, long and code inputs')
end

%  Eliminate NaNs from the input data

indx = find(isnan(lat) | isnan(long));
lat(indx) = [];    long(indx) = [];    code(indx) = [];

%  Convert the lat and long data to cell positions

[r,c,badpts] = setpostn(map,maplegend,lat,long,units);
if ~isempty(badpts);   code(badpts) = [];   end    %  Eliminate bad codes too

%  Imbed the points into the map

indx = (c-1)*size(map,1) + r;
map(indx) = code;

