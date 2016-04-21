function lon = westof(lon,lon0,units)

%WESTOF wraps longitudes to values west of a meridian
% 
%   ang = WESTOF(angin,meridian) transforms input angles into equivalent 
%   angles west of the specified meridian.
%   
%   ang = WESTOF(angin,meridian,'units') uses the units defined by the input 
%   string 'units'.  If omitted, default units of 'degrees' are assumed.
%   
%   See also EASTOF, ZERO22PI, NPI2PI, SMOOTHLONG, ANGLEDIM

%
%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.5.4.1 $    $Date: 2003/08/01 18:20:41 $


if nargin <= 1; error('Incorrect number of arguments'); end

sz=size(lon);
lon=lon(:);

onerev = 360;
if nargin == 3
	onerev = angledim(onerev,'degrees',units);
end

% move to the right of lon0

lon = lon-onerev*floor(min(lon-lon0)/onerev);

% move to the left

indx = find(lon > lon0);
while ~isempty(indx)
	lon(indx) = lon(indx)-onerev;
	indx = find(lon > lon0);
end

lon=reshape(lon,sz);
