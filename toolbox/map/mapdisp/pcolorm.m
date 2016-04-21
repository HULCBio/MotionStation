function hndl = pcolorm(varargin)

%PCOLORM  Projected matrix map in the z = 0 plane
%
%  PCOLORM(lat,lon,map) will warp a matrix map to a projected
%  graticule mesh, thus allowing matrix surfaces to be displayed
%  in a map projection.  The graticule mesh is specified by the lat
%  and lon inputs.    PCOLORM will clear the current map if the hold
%  state is off.  Unlike MESHM and SURFM, PCOLORM will always
%  produce a map drawn in the z = 0 plane.
%
%  PCOLORM(lat,lon,map,'PropertyName',PropertyValue,...) and
%  PCOLORM(lat,lon,map,alt,'PropertyName',PropertyValue,...) display
%  general matrix map using the specified surface properties.
%
%  PCOLORM(map) and PCOLORM(map,npts) computes a default
%  graticule mesh is computed with MESHGRAT using the latitude
%  and longitude limits in the current map axes definition.  If
%  npts is supplied, then a MESHGRAT is executed using npts and
%  the map latitude and longitude limits in the current map axes.
%
%  h = PCOLORM(...) returns the handle to the surface object displayed.
%
%  PCOLORM, without any inputs, activates a GUI for projecting general
%  surfaces onto the current axes.
%
%  See also MESHM, SURFM, SURFACEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:19:13 $


if nargin == 0
	surfacem;  return

elseif nargin == 1

	[mstruct,msg] = gcm;
	if ~isempty(msg);   error(msg);   end
	latlim = mstruct.maplatlimit;
	lonlim = mstruct.maplonlimit;

     map = varargin{1};
     [lat,lon] = meshgrat(latlim,lonlim,size(map));
     varargin(1) = [];

elseif nargin == 2

	[mstruct,msg] = gcm;
	if ~isempty(msg);   error(msg);   end
	latlim = mstruct.maplatlimit;
	lonlim = mstruct.maplonlimit;

     map = varargin{1};     npts = varargin{2};
     [lat,lon] = meshgrat(latlim,lonlim,npts);
     varargin(1:2) = [];

else
     lat = varargin{1};     lon = varargin{2};
	 map = varargin{3};     varargin(1:3) = [];
end

%  Set the altitude

alt = zeros(size(lat));

%  Display the map

nextmap;
if ~isempty(varargin)
    [hndl0,msg] = surfacem(lat,lon,map,alt,varargin{:});
else
    [hndl0,msg] = surfacem(lat,lon,map,alt);
end

if ~isempty(msg);  error(msg);  end

%  Set handle return argument if necessary

if nargout == 1;   hndl = hndl0;    end
