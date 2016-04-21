function [vis,visprofile,dist,z,lattrk,lontrk] ...
  = los2(map,maplegend,lat1,lon1,lat2,lon2,oalt,talt,...
         oaltopt,taltopt,actualradius,apparentradius)
%LOS2 Line of sight visibility between two points in terrain.
%
%   LOS2 computes the mutual visibility between two points on a displayed
%   digital elevation map.  LOS2 uses the current object if it is a regular
%   matrix map, or the first regular matrix map (data grid) found on the
%   current axes. The map's zdata is  used for the profile.  The color data
%   is used in the absence of data in z.  The two points are selected by
%   clicking on the map. The result is displayed in a new figure.  Markers
%   indicate visible and obscured points along the profile.  The profile is
%   shown in a cartesian coordinate system with the origin at the
%   observer's location.  The displayed z coordinate accounts for the
%   elevation of the terrain and the curvature of the body.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2) computes the mutual
%   visibility between pairs of points on a digital elevation map.  The
%   elevations are provided as a regular matrix map containing elevations
%   in units of meters.  The two points are provided as vectors of
%   latitudes and longitudes in units of degrees.  The resulting logical
%   variable vis is equal to one when the two points are visible to each
%   other, and zero when the line of sight is obscured by terrain.  If any
%   of the  input arguments are empty, LOS2 attempts to gather the data
%   from the current axes.  With one or more output arguments, no figures
%   are created and only the data is returned.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1) places the first
%   point at the specified altitude in meters above the surface.  This is
%   equivalent to putting the point on a tower.  If omitted, the point is
%   assumed to be on the surface.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1,alt2) also places the
%   second point at a specified altitude in meters above the surface. If
%   omitted, the point is assumed to be on the surface.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1,alt2,alt1opt)
%   controls whether the first point is at a relative or absolute 
%   altitude. If the altitude option is 'AGL', the point's altitude is in
%   meters above the terrain ground level. If alt1opt is 'MSL', alt1 is
%   interpreted as altitude above zero, or mean sea level. If omitted,
%   'AGL' is assumed.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1,alt2,alt1opt,...
%   alt2opt) also controls the interpretation of the second point's 
%   altitude. 
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1,alt2,alt1opt,...
%   alt2opt,actualradius) does the visibility calculation on a sphere with
%   the specified radius.  If omitted, the radius of the earth in meters is
%   assumed.  The altitudes, elevations and the radius should be in the
%   same units.  This calling form is most useful for computations on
%   bodies other than the earth.
%
%   vis = LOS2(map,maplegend,lat1,lon1,lat2,lon2,alt1,alt2,alt1opt,...
%   alt2opt,actualradius,effectiveradius) assumes a larger radius for
%   propagation of the line of sight.  This can account for the curvature
%   of the signal path due to refraction in the atmosphere.  For example,
%   radio propagation in the atmosphere is commonly treated as straight
%   line propagation on a sphere with 4/3rds the radius of the earth.  In
%   that case the last two arguments would be R_e and 4/3*R_e, where R_e is
%   the radius of the earth.  Use Inf as the effective radius for flat  
%   earth visibility calculations.  The altitudes, elevations and the radii
%   should be in the same units. 
%
%   [vis,visprofile,dist,z,lattrk,lontrk] = LOS2(...) also returns vectors
%   of points along the path between the two points. The visprofile is a
%   vector containing ones where the intermediate points are visible.  Dist
%   is the distance along the path (in meters or the units of the radius).
%   Z contains the terrain profile relative to the z datum along the path.
%   Lattrk and lontrk are the latitudes longitudes of the the points along
%   the path.
%
%   LOS2(...), with no output arguments, displays the visibility profile
%   between the two points in a new figure. 
%
%   Example
%   -------
%   map = 500*peaks(100);
%   maplegend = [ 1000 0 0];
%   [lat1,lon1,lat2,lon2]=deal(-0.027,0.05,-0.093,0.042);
%
%   los2(map,maplegend,lat1,lon1,lat2,lon2,100);
% 
%   figure;
%   axesm('globe','geoid',almanac('earth','sphere','meters'))
%   meshm(map,maplegend,size(map),map); axis tight
%   camposm(-10,-10,1e6); camupm(0,0)
%   demcmap('inc',map,1000); shading interp; camlight
% 
%   [vis,visprofile,dist,z,lattrk,lontrk] = los2(map,maplegend,lat1,lon1,lat2,lon2,100);
%   plot3m(lattrk([1;end]),lontrk([1; end]),z([1; end])+[100; 0],'r','linewidth',2)
%   plotm(lattrk(~visprofile),lontrk(~visprofile),z(~visprofile),'r.','markersize',10)
%   plotm(lattrk(visprofile),lontrk(visprofile),z(visprofile),'g.','markersize',10)
% 
%   See also VIEWSHED.

%  Written by Walter Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.2 $    $Date: 2003/12/13 02:50:21 $

if nargin < 2 | (isempty(map) & isempty(maplegend))
   [map,maplegend,source] = getrmm;
end

if nargin < 4 | (isempty(lat1) & isempty(lon1))
   disp('Click on the map for point 1')
   [lat1,lon1] = inputm(1);
end

if nargin < 6 | (isempty(lat2) & isempty(lon2))
   disp('Click on the map for point 2')
   [lat2,lon2] = inputm(1);
end

if nargin < 7; oalt = 100*eps; end % observer on the surface
if nargin < 8; talt = 0; end % look at terrain, not above it
if nargin < 9; oaltopt = 'AGL'; end % observer altitude above ground level
if nargin < 10; taltopt = 'AGL'; end % target above ground level
if nargin < 11; actualradius = almanac('earth','radius','m'); end
if nargin < 12; apparentradius = actualradius; end % use Inf for flat earth LOS calculations

%Check inputs

msg = inputcheck('rmm',map,maplegend); if ~isempty(msg); error(msg); end
msg = inputcheck('vector',lat1,lon1); if ~isempty(msg); error(msg); end
msg = inputcheck('vector',lat2,lon2); if ~isempty(msg); error(msg); end

% loop over pairs of observer and target locations
for i=1:length(lat1)
    
    % compute the elevation profile between the start and end point
    [z{i},dist{i},lattrk{i},lontrk{i}] = ...
       mapprofile(map,maplegend,...
       [lat1(i); lat2(i)],[lon1(i); lon2(i)],...
       actualradius,'gc','bilinear');

    
    % compute vibility of points on the track between the start and end point
    visprofile{i} = losprofile(dist{i},z{i},oalt,talt,oaltopt,taltopt,apparentradius,nargout);
    visprofile{i} = reshape(visprofile{i},size(lattrk{i}));
    
    vis(i) = visprofile{i}(end);

end

% output cell arrays only if necessary
if length(lat1) == 1
    visprofile = visprofile{1};
    z = z{1};
    dist = dist{1};
    lattrk = lattrk{1};
    lontrk = lontrk{1};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function vis = losprofile(rng,zin,oalt,talt,oaltopt,taltopt,apparentradius,nout)

% vis = losprofile(rng,zin)
% vis = losprofile(rng,zin,oalt)
% vis = losprofile(rng,zin,oalt,talt)
% vis = losprofile(rng,zin,oalt,talt,oaltopt)
% vis = losprofile(rng,zin,oalt,talt,oaltopt,taltopt)
% vis = losprofile(rng,zin,oalt,talt,oaltopt,taltopt,apparentradius)


% needs alt, rng and radius in same units 
if nargin < 2; error('Incorrect number of input arguments'); end
if nargin < 3; oalt = 10*eps; end % observer on the surface
if nargin < 4; talt = 0; end % look at terrain, not above it
if nargin < 5; oaltopt = 'AGL'; end % observer altitude above ground level
if nargin < 6; taltopt = 'AGL'; end % target above ground level
if nargin < 7; apparentradius = Inf; end % flat earth calculation

rng = rng(:)';
zin = zin(:)';

if ~isinf(apparentradius)

% Adjust the terrain slice for the curvature of the sphere. The radius may
% potentially be different from the actual body, for example to model refraction
% of radio waves.

    mstruct = defaultm('globe');
    mstruct.geoid = [apparentradius 0];
    mstruct = defaultm(globe(mstruct));
    
    [z,y,x] = mfwdtran(mstruct,rad2deg(rng/apparentradius),rng*0,zin);
    z = z-apparentradius;

else

    x = rng;
    z = zin;

end

% Convert AGL observer altitude to MSL 

switch upper(oaltopt)
case 'AGL'
    oalt =  z(1) + oalt;%  0bserver is at first location
case 'MSL'
otherwise
    error('Valid altitude options are ''AGL'' or ''MSL''')
end

% Shift terrain so observer is at altitude 0, and terrain altitudes are relative
% to the observer

z = z - oalt;%  0bserver is at first location

% vectorized calculation, optimized for speed over memory

% Compute the angles of sight from the observer to each point on the profile.
% measured positive up from the center of the sphere

ang = pi + atan2(z,x);
if x(1) == 0 && z(1) == 0
    ang(1) = pi/2;  % Look straight down at observer's location
end

% Create a matrix with rows containing 1:rownumber elements of ang.
% Compute a vectorized max of elevation angles of the obscuring terrain 
% up to each range

angmat = tril(repmat(ang,length(ang),1));
maxangtohere =max(angmat,[],2);


% Adjust the angles for the altitude of the target height above ground level 
% or sea level and redo calculation of angles. This makes the obsuring factor
% the terrain only, and not any target height. To model stuff above the terrain 
% like a forest canopy, pass in a z vector that has the added heights.

switch upper(taltopt)
case 'AGL'

    if ~isinf(apparentradius)
        [z2,y2,x2] = mfwdtran(mstruct,rad2deg(rng/apparentradius),rng*0,zin+talt);
        z2 = z2 - apparentradius - oalt;
    else
        z2 = z + talt;
        x2 = x;
    end

case 'MSL'

    if ~isinf(apparentradius)
        [z2,y2,x2] = mfwdtran(mstruct,rad2deg(rng/apparentradius),rng*0,(talt)*ones(size(zin)));
        z2 = z2-apparentradius-oalt;
    else
        z2 = (talt)*ones(size(zin))-oalt;
        x2 = x;
    end
otherwise
    error('Valid altitude options are ''AGL'' or ''MSL''')
end

% Compute line of sight angles again.

ang2 = pi + atan2(z2,x2);
if x2(1) == 0 && z2(1) == 0
    ang2(1) = pi/2;  % Look straight down at observer's location
end

% Visible are points that rise above the maximum angle of LOS of intervening 
% terrain.

vis = ang2 >= maxangtohere';

% Visibility of first point below terrain need a special test, since
% it always passes the "angles of terrain up to here" test

if z(1) > z2(1) & z(1) < 0
   vis(1) = 0;
end

% Display calculation if no output arguments in main function

if nout == 0
   
    h = NaN*ones(4,1);
   
    figure;
    hold on
    h(1) = plot(x,z,'k');
    if vis(end)
	    h(5) = plot([0;x2(end)],[0;z2(end)],'g');
    else
	    h(5) = plot([0;x2(end)],[0;z2(end)],'r');
    end
    if any(vis); h(2) = plot(x2(vis),z2(vis),'g+'); end
    if any(~vis); h(3) = plot(x2(~vis),z2(~vis),'ro'); end
    
    h(4) = plot(0,0,'mx');
    axis equal
    
    labels = {'Terrain','Visible','Obscured','Observer','Line of Sight'};
    indx = find(~isnan(h));
    legend(h(indx),labels(indx))
    xlabel 'Horizontal Distance from Observer'
    ylabel 'Vertical Distance from Observer'
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map,maplegend,source] = getrmm

hfig = get(0,'CurrentFigure');
msg = 'This calling form requires a map axes with a displayed regular matrix map';
if isempty(hfig); error(msg); end

haxes = get(hfig,'CurrentAxes');
if isempty(haxes); error(msg); end
if ~ismap(haxes); error(msg); end

mobjstruct = get(gco,'UserData');
if isfield(mobjstruct,'maplegend');
   hobj = gco;
else
   hobj = findall(haxes,'type','surface');
   if isempty(hobj); error(msg); end
   
   for i=length(hobj):-1:1
      mobjstruct = get(hobj(i),'UserData');
      if ~isfield(mobjstruct,'maplegend');
         hobj(i) = [];
      end
   end
   
   if isempty(hobj); error(msg); end
   if length(hobj) > 1; 
      warning('More than one Regular Matrix Map in axes. Using the first one');
      hobj = hobj(1); 
   end
   
end

mobjstruct = get(hobj,'UserData');
maplegend = mobjstruct.maplegend;

mats = get(hobj,{'XData','Ydata','ZData','CData'});
[xdata,ydata,zdata,cdata] = deal(mats{:});

mstruct = get(haxes,'UserData');

if ~isequal(max(zdata(:)),min(zdata(:)));
   map = zdata;
   source = 'ZData';
else
   map = cdata;
   source = 'CData';
end
