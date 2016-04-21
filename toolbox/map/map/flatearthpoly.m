function [lat2,lon2]=flatearthpoly(lat,lon,origin)
%FLATEARTHPOLY inserts points along the dateline to the pole
%
% [lat2,lon2] = FLEATEARTHPOLY(lat,lon) inserts points in the
% input latitude and longitude vectors at +/- 180 longitude 
% and to the poles. The resulting vectors look like the result
% of PATCHM on a cylindrical projection and do not encompass 
% the poles. Inputs and outputs are in degrees.
%
% [lat2,lon2] = FLEATEARTHPOLY(lat,lon,origin) centers the 
% polygon on the provided origin. Points are inserted in the
% input latitude and longitude vectors at +/- 180 longitude 
% from the origin and to the poles. The origin is a scalar 
% longitude or a three element vector containing latitude, 
% longitude and orientation in units of degrees.
%
% Example:
%
% [lat,long]=extractm(worldlo('POpatch'),'Antarctica');
% plot(long,lat)
%
% [lat2,lon2]=flatearthpoly(lat,long);
% plot(lon2,lat2)
% ylim([-100 -60])
%
% POLYBOOL, MFWDTRAN

%  Written by:  W. Stumpf
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:16:15 $

if nargin < 2; error('Incorrect number of input arguments.'); end
if nargin == 2; origin = 0; end

% Check origin input;
if length(origin) ~= 1
   error('Origin must be a 1 element vector containing longitude.')
   if ~isnumeric(origin)
      error('Origin must be numeric.')
   end
end

origin = [0 origin 0];

% Check vector input
msg = inputcheck('vector',lat,lon);
if ~isempty(msg); error(msg); end

% Define a cylindrical platte carree projection
mstruct=defaultm('pcarree');
mstruct.origin = origin;
mstruct=defaultm(pcarree(mstruct));

% Forward project lat-long as a patch to insert 
% points at the edges of the map
[x,y]=mfwdtran(mstruct,lat,lon,[],'patch');

% Inverse transformation without undoing inserted points
[lat2,lon2]=deal(rad2deg(y),rad2deg(x));

% compensate for shifts introduced in projection
lat2 = lat2 + origin(1);
lon2 = lon2 + origin(2);



