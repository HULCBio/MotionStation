function [submap,sublegend] = maptrims(map,maplgnd,latlim,lonlim,scale)

%MAPTRIMS  Trim a regular data grid to a specified region.
%
%   Z_TRIMMED = MAPTRIMS(Z,REFVEC,LATLIM,LONLIM) trims a regular data grid
%   Z to the region specified by LATLIM and LONLIM.  LATLIM and LONLIM are
%   two-element vectors, defining the latitude and longitude limits
%   respectively.  The output grid Z_TRIMMED has the same sample size as
%   the input.
%
%   Z_TRIMMED = MAPTRIMS(Z,REFVEC,LATLIM,LONLIM,SCALE) uses SCALE to reduce
%   the size of the output.  The elements of REFVEC must be evenly
%   divisible by SCALE.
%
%   [Z_TRIMMED,REFVEC_TRIMMED] = MAPTRIMS(...) returns the referencing
%   vector for the trimmed data grid.
%
%   See also MAPTRIML, MAPTRIMP.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.11.4.2 $    $Date: 2004/02/01 21:57:33 $

if nargin < 4
	error('Incorrect number of arguments')

elseif nargin == 4
    scale = [];
end

%  Test the inputs

if ndims(map) > 2
    error('Input map can not have pages')

elseif ~isequal(sort(size(maplgnd)),[1 3])
    error('Input maplegend must be a 3 element vector')

elseif ~isequal(sort(size(latlim)),sort(size(lonlim)),[1 2])
    error('Lat and lon limit inputs must be 2 element vectors')

elseif length(scale) > 1
    error('Scale input must be a scalar')

end

%  Test for real inputs

if any([~isreal(map) ~isreal(maplgnd) ~isreal(latlim) ~isreal(lonlim) ~isreal(scale)])
    warning('Imaginary parts of complex arguments ignored')
	map = real(map);         maplgnd = real(maplgnd);
	latlim = real(latlim);   lonlim = real(lonlim);
	scale  = real(scale);
end

%  Error check on scale
tol = 1E-5; % allow for floating point roundoff
if isempty(scale)
   scale = maplgnd(1);

elseif rem(maplgnd(1),scale) > tol
   error('MAPLEGEND(1) must be evenly divisible by SCALE')
end

%  If reduction is requested, ensure that input map is binary

if maplgnd(1) ~= scale & issparse(map) & any(nonzeros(map) ~= 1)
      error('Scale reduction requires binary maps as input')
end

%  Get the corners of the submap region

up    = max(latlim);   low  = min(latlim);
left  = lonlim(1);     right = lonlim(2);

%  Test the submap corners for consistency

if low >= up | left >= right;  error('Non-unique corner definition');   end

%  Test the corners of the submap region to lie within the map limits

[maplat,maplon] = limitm(map,maplgnd);

if low < min(maplat) | low > max(maplat)
    error('Lower edge does not lie within the map')
elseif up < min(maplat) | up > max(maplat)
    error('Upper edge does not lie within the map')
elseif left < min(maplon) | left > max(maplon)
    error('Left edge does not lie within the map')
elseif right < min(maplon) | right > max(maplon)
    error('Right edge does not lie within the map')
end

factor = scale/maplgnd(1);
% If inceasing resolution, resize first. This ensures the closest match to the limits. 
if scale > maplgnd(1) % resolution increase    
	[map,maplgnd] = resizem(map,factor,maplgnd,'nearest');
end

% Trim the map
[rlim,clim] = setpostn(map,maplgnd,[low up],[left right]);
rlim = rlim + [1 -1]; clim = clim + [1 -1]; % ensure that trimmed map is completely within limits
submap = map(rlim(1):rlim(2),clim(1):clim(2));
[lat1,lon1] = setltln(map,maplgnd,rlim(2),clim(1));
sublegend = [maplgnd(1) lat1+0.5/maplgnd(1) lon1-0.5/maplgnd(1)];

% If decreasing resolution, trim first, then resize. This ensures the closest match to the limits. 
if scale < maplgnd(1) % resolution decrease    
	[submap,sublegend] = resizem(submap,factor,sublegend,'nearest');
end
