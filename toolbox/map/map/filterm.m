function [newlat,newlong,indx] = filterm(lat,long,map,maplegend,allowed)

%FILTERM  Geographically filters data points
%
%  [latout,lonout] = FILTERM(lat,long,map,maplegend,allowed) filters
%  a set of latitudes and longitudes to include only those data points 
%  which have a corresponding value in map equal to allowed.
%
%  [latout,lonout,indx] = FILTERM(lat,long,map,maplegend,allowed) also 
%  returns the indices of the included points.
%
%  See also IMBEDM, HISTR, HISTA

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:12 $

if nargin ~= 5;   error('Incorrect number of arguments');   end


%  Input dimension tests

if length(size(map)) > 2
    error('Input map can not have pages')

elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')

elseif any([min(size(lat))    min(size(long))]    ~= 1) | ...
       any([length(size(lat)) length(size(long))] > 2)
         error('Latitude and longitude inputs must a vector')

elseif ~isequal(size(lat),size(long))
    error('Inconsistent dimensions on latitude and longitude inputs')
end


%  Retrieve the code for each lat/lon data point

code = ltln2val(map,maplegend,lat,long);

%  Test for each allowed code

indx = [];
for i = 1:length(allowed)
    testindx = find(code == allowed(i));

    if ~isempty(testindx)           %  Save allowed indices
	   indx  = [indx;  testindx];
    end
end

%  Sort indices so as to NOT alter the data point ordering in the
%  original vectors.  Eliminate double counting of data points.

if ~isempty(indx) & length(indx)>1
	indx = sort(indx); 
	indx = [indx(find(diff(indx)~=0)); indx(length(indx))];
end

%  Accept allowed data points

if ~isempty(indx)
	newlat  = lat(indx);    newlong = long(indx);
else
    newlat = [];   newlong = [];
end


%  Set output arguments if necessary

if nargout < 2;   newlat = [newlat newlong];  end


