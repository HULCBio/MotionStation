function [course,dist]=legs(lat,lon,str);

%LEGS  Provides courses and distances between track waypoints
%
%  [course,dist] = LEGS(lat,lon) takes a series of waypoints in
%  navigation track format, calculates the new course and distance
%  for each point.  The default method is rhumb line ('rh'), the common
%  navigational method.
%
%  [course,dist] = LEGS(lat,lon,'method') uses the method string
%  to specify the navigation track.  Allowable method strings are
%  'gc' for great circle tracks, and 'rh' for rhumb line tracks.
%
%  [course,dist] = LEGS(mat) and [course,dist] = LEGS(mat,'method')
%  uses a single input matrix mat, where mat = [lat lon].
%
%  mat = LEGS(...) returns a single output, where mat = [course,dist].
%
%  Note:  This is a navigational function -- all lats/longs are in
%         degrees, all distances in nautical miles, all times
%         in hours, and all speeds in knots (nautical miles per hour).
%
%  See also NAVFIX, TRACK, DRECKON, GCWAYPTS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:53 $



if nargin == 0
    error('Incorrect number of arguments')

elseif nargin == 1
    if size(lat,2) ~= 2 | ndims(lat) > 2
	    error('Input matrix must have two columns [lat lon]')
	else
	    lon = lat(:,2);      lat = lat(:,1);    str = 'rh';
	end

elseif nargin == 2
    if isstr(lon)
        if size(lat,2) ~= 2 | ndims(lat) > 2
	        error('Input matrix must have two columns [lat lon]')
	    else
	        str = lon;   lon = lat(:,2);      lat = lat(:,1);
	    end
	else
	    str = 'rh';
	end
end

%  Input dimension tests

if any([min(size(lat))    min(size(lon))]    ~= 1) | ...
   any([ndims(lat) ndims(lon)] > 2)
    error('Latitude and longitude inputs must a vector')

elseif ~isequal(size(lat),size(lon))
    error('Inconsistent dimensions on lat and lon input')

elseif max(size(lat)) == 1
    error('At least 2 way points are required')
end

%  Ensure lat and lon are column vectors

lat = lat(:);      lon = lon(:);

%  Compute vectors of start and end points

startlats = lat(1:length(lat)-1);   endlats = lat(2:length(lat));
startlons = lon(1:length(lon)-1);   endlons = lon(2:length(lon));

%  Compute the course

course=azimuth(str,startlats,startlons,endlats,endlons,'degrees');

% There are 60 nautical miles in a degree of arc length

dist=distance(str,startlats,startlons,endlats,endlons,'degrees');
dist = deg2nm(dist);

%  Pack up output vector if necessary

if nargout < 2;  course = [course dist];  end
