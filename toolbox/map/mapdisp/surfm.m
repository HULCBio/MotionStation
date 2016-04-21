function hndl = surfm(varargin)

%SURFM  Display a matrix map warped to a projected graticule
%
%  SURFM(lat,lon,map) will warp a matrix map to a projected
%  graticule mesh, thus allowing matrix surfaces to be displayed
%  in a map projection.  The graticule mesh is specified by the lat
%  and lon inputs.    SURFM will clear the current map if the hold
%  state is off.
%
%  SURFM(lat,lon,map,alt) uses the input alt as the zdata to
%  draw the graticule mesh.  In this case, size(alt) and size(lat)
%  must be the same.  If the alt input is not supplied, then the
%  graticule zdata is dependent on size(lat).  If size(lat) and
%  size(map) are not the same, then the graticule mesh is drawn
%  at the z = 0 plane.  However, if size(lat) and size(map) are
%  equal, then the graticule mesh is drawn with zdata = map,
%  thus producing a 3D surface map.
%
%  SURFM(lat,lon,map,'PropertyName',PropertyValue,...) and
%  SURFM(lat,lon,map,alt,'PropertyName',PropertyValue,...) display
%  general matrix map using the specified surface properties.
%
%  SURFM(map) and SURFM(map,npts) computes a default graticule mesh with 
%  MESHGRAT using the latitude and longitude limits in the current map axes 
%  definition.  If npts is supplied, then MESHGRAT is executed using npts and 
%  the map latitude and longitude limits in the current map axes.
%
%  h = SURFM(...) returns the handle to the surface object displayed.
%
%  SURFM, without any inputs, activates a GUI for projecting general
%  surfaces onto the current axes.
%
%  See also MESHM, SURFACEM, SURFLM, MESHGRAT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:22:54 $

if nargin == 0
	surfacem;  return

elseif nargin == 1
     varargin{2} = size(varargin{1});

elseif nargin >= 3       %  Test for lat/lon limit call
     lat = varargin{1};   lon = varargin{2};
	 if isequal(sort(size(lat)),sort(size(lon)),[1 2])
	     [lat,lon] = meshgrat(lat,lon,size(varargin{3}));
	     varargin{1} = lat;   varargin{2} = lon;
	 end
end


%  Display the map

nextmap;
[hndl0,msg] = surfacem(varargin{:});
if ~isempty(msg);  error(msg);  end

%  Set handle return argument if necessary

if nargout == 1;   hndl = hndl0;    end
