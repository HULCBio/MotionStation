function [outlat,outlon]=gcwaypts(lat1,lon1,lat2,lon2,nlegs);

%GCWAYPTS   Computes equally spaced waypoint coordinates along a great circle
%
%  [lat,lon] = GCWAYPTS(lat1,lon1,lat2,lon2) returns ten ordered
%  waypoints for the purpose of approximating great circle sailing.
%  All inputs must be scalars.
%
%  [lat,lon] = GCWAYPTS(lat1,lon1,lat2,lon2,nlegs) computes "nlegs"
%  waypoints.
%
%  mat = GCWAYPTS(...) returns a single output, where mat = [lat lon].
%
%  Note:  This is a navigational function -- all lats/longs are in
%         degrees, all distances in nautical miles, all times
%         in hours, and all speeds in knots (nautical miles per hour).
%
%  See also NAVFIX, TRACK, DRECKON, LEGS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:16:17 $



if nargin < 4
    error('Incorrect number of arguments')

elseif nargin==4
	nlegs = [];

elseif nargin>5
    error('Incorrect number of arguments')
end

%  Empty argument tests.  Set defaults

if isempty(nlegs);   nlegs = 10;          end

%  Argument dimension tests

if any([max(size(lat1)) max(size(lon1)) max(size(lat2)) max(size(lon2))] ~= 1)
	 error('Lat and long inputs must be scalars')

elseif max(size(nlegs)) ~= 1
     error('Number of legs must be a scalar')

elseif ~isreal(nlegs)
     warning('Imaginary part of complex NLEGS argument ignored')
	 nlegs = real(nlegs)
end

%  Ensure that nlegs is an integer

nlegs = round(nlegs);

%  Special case if starting from a Polar point (02012002 LSJ)
if lat1 == 90 | lat1 == -90
    
    [outlat,outlon] = track2(lat1,lon1,lat2,lon2,[],'',nlegs);
    
else
    
	%  Determine total gc distance and initial azimuth
	
	rng = distance('gc',lat1,lon1,lat2,lon2);
	az  = azimuth('gc',lat1,lon1,lat2,lon2);
	
	%  Split the ranges into a number of legs
	%  Convert units to rad for calculation since can't do
	%  math on dms or dm, then convert back
	
	rng=rng/nlegs;
	rngvec=rng*(1:nlegs)';
	
	%  Expand the input data for vector processing in reckon
	
	latvec=lat1(ones(size(rngvec)));
	lonvec=lon1(ones(size(rngvec)));
	azvec=az(ones(size(rngvec)));
	
	%  Compute the way pts
	
	[outlat,outlon] = reckon('gc',latvec,lonvec,rngvec,azvec);
	
	%  Build the way point matrix
	
	outlat=[lat1;outlat];  outlon=[lon1;outlon];
    
end

%  Set output arguments if necessary

if nargout < 2;  outlat = [outlat  outlon];   end
