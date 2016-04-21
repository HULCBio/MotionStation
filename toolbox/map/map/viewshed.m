function [vismap,vismaplegend] = viewshed(map,maplegend,lat1,lon1,oalt,talt,oaltopt,taltopt,actualradius,apparentradius)
%VIEWSHED visible areas from a point on a digital elevation map
%
% [vismap,vismaplegend] = VIEWSHED(map,maplegend,lat1,lon1) 
% computes areas visible from a point on a digital elevation 
% map. The elevations are provided as a regular matrix map 
% containing elevations in units of meters. The observer 
% location is provided as scalar latitude and longitude in
% units of degrees. The resulting vismap contains ones at
% the surface locations visible from the observer location,
% and zeros where the line of sight is obscured by terrain. 
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt) places the observer
% at the specified altitude in meters above the surface. This
% is equivalent to putting the observer on a tower. If omitted, 
% the observer is assumed to be on the surface.
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt,talt) checks for 
% visibility of target points a specified distance above
% the terrain. This is equivalent to putting the target 
% points on towers, but the towers do not obstruct the view.
% if omitted, the target points are assumed to be on the 
% surface.
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt,talt,oaltopt) controls
% whether the observer is at a relative or absolute altitude.
% If the observer altitude option is 'AGL', the observer 
% altitude oalt is in meters above ground level. If oaltopt is
% 'MSL', oalt is interpreted as altitude above zero, or mean 
% sea level. If omitted, 'AGL' is assumed.
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt,talt,oaltopt,taltopt)
% controls whether the target points are at a relative or 
% absolute altitude. If the target altitude option is 'AGL', 
% the target altitude talt is in meters above ground level. 
% If taltopt is 'MSL', talt is interpreted as altitude above 
% zero, or mean sea level. If omitted, 'AGL' is assumed.
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt,talt,oaltopt,taltopt,...
% actualradius) does the visibility calculation on a sphere 
% with the specified radius. If omitted, the radius of the earth 
% in meters is assumed. The altitudes, elevations and the radius 
% should be in the same units. This calling form is most useful 
% for computations on bodies other than the earth.
%
% VIEWSHED(map,maplegend,lat1,lon1,oalt,talt,oaltopt,taltopt,...
% actualradius,effectiveradius) assumes a larger radius for
% propagation of the line of sight. This can account for the 
% curvature of the signal path due to refraction in the 
% atmosphere. For example, radio propagation in the atmosphere
% is commonly treated as straight line propagation on a 
% sphere with 4/3rds the radius of the earth. In that case the
% last two arguments would be R_e and 4/3*R_e, where R_e is the
% radius of the earth. Use Inf for flat earth viewshed 
% calculations. The altitudes, elevations and the radii should 
% be in the same units. 
%
% Example:
%
%    map = 500*peaks(100);
%    maplegend = [ 1000 0 0];
%    [lat1,lon1,lat2,lon2]=deal(-0.027,0.05,-0.093,0.042);
%    
%    [vismap,vismapleg] = viewshed(map,maplegend,lat1,lon1,100);
%    [vis,visprofile,dist,z,lattrk,lontrk] = los2(map,maplegend,lat1,lon1,lat2,lon2,100);
%  
%    axesm('globe','geoid',almanac('earth','sphere','meters'))
%    meshm(vismap,vismapleg,size(map),map); axis tight
%    camposm(-10,-10,1e6); camupm(0,0)
%    colormap(flipud(summer(2))); brighten(0.75);
%    shading interp; camlight
%    h = lcolorbar({'obscured','visible'});
%    set(h,'Position',[.875 .45 .02 .1])
%  
%    plot3m(lattrk([1;end]),lontrk([1; end]),z([1; end])+[100; 0],'r','linewidth',2)
%    plotm(lattrk(~visprofile),lontrk(~visprofile),z(~visprofile),'r.','markersize',10)
%    plotm(lattrk(visprofile),lontrk(visprofile),z(visprofile),'g.','markersize',10)
%
% See also LOS2


%  Written by Walter Stumpf and Betty Youmans.
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.1 $    $Date: 2003/08/01 18:20:38 $

% Elevations assumed to be in meters on the earth. 
% If not in meters, use DISTDIM to convert 
% If not on the earth, provide the actual (and optionally apparent) 
% radius of the spherical body in the same units as the elevation 
% data.


if nargin < 4; error('Incorrect number of input arguments.'); end
if nargin < 5; oalt = 10*eps; end % observer on the surface
if nargin < 6; talt = 0; end % look at terrain, not above it
if nargin < 7; oaltopt = 'AGL'; end % observer altitude above ground level
if nargin < 8; taltopt = 'AGL'; end % target above ground level
if nargin < 9; actualradius = almanac('earth','radius','m'); end 
if nargin < 10; apparentradius = actualradius; end; % use Inf for flat earth LOS calculations


msg = inputcheck('rmm',map,maplegend); if ~isempty(msg); error(msg); end
msg = inputcheck('scalar',lat1,lon1); if ~isempty(msg); error(msg); end


oaltopt = upper(oaltopt);
taltopt = upper(taltopt);

vismap = NaN*map;
vismaplegend = maplegend;

[nr,nc] = size(map);

for i=1:nr
   [lat2,lon2] = setltln(map,maplegend,i,1);
   
   [visQ,vis,dist,z,lat,lon] = los2(map,maplegend,lat1,lon1,lat2,lon2,...
      oalt,talt,oaltopt,taltopt,actualradius,apparentradius);
   
   
   vismap = imbedm(lat,lon,vis,vismap,vismaplegend);
   
   
   [lat2,lon2] = setltln(map,maplegend,i,nc);
   
   [visQ,vis,dist,z,lat,lon] = los2(map,maplegend,lat1,lon1,lat2,lon2,...
      oalt,talt,oaltopt,taltopt,actualradius,apparentradius);
   
   vismap = imbedm(lat,lon,vis,vismap,vismaplegend);
   
end


for i=1:nc
   [lat2,lon2] = setltln(map,maplegend,1,i);
   
   [visQ,vis,dist,z,lat,lon] = los2(map,maplegend,lat1,lon1,lat2,lon2,...
      oalt,talt,oaltopt,taltopt,actualradius,apparentradius);
   
   vismap = imbedm(lat,lon,vis,vismap,vismaplegend);
   
   [lat2,lon2] = setltln(map,maplegend,nr,i);
   
   [visQ,vis,dist,z,lat,lon] = los2(map,maplegend,lat1,lon1,lat2,lon2,...
      oalt,talt,oaltopt,taltopt,actualradius,apparentradius);
   
   vismap = imbedm(lat,lon,vis,vismap,vismaplegend);
   
end



% Use los2 to handle any remaing NaNs in mtx

nanvec=isnan(vismap);
[inan,jnan]=find(nanvec);

if length(inan)>0,
   for i=1:length(inan),
      [lat2,lon2]=setltln(map,maplegend,inan(i),jnan(i));
     vis=los2(map,maplegend,lat1,lon1,lat2,lon2,...
      oalt,talt,oaltopt,taltopt,actualradius,apparentradius);
   
      vismap = imbedm(lat2,lon2,vis,vismap,vismaplegend);
   end
end

