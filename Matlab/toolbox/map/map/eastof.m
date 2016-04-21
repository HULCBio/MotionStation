function lon = eastof(lon,lon0,units)

%EASTOF wraps longitudes to values east of a meridian
% 
%   ang = EASTOF(angin,meridian) transforms input angles into equivalent 
%   angles east of the specified meridian.
%   
%   ang = EASTOF(angin,meridian,'units') uses the units defined by the input 
%   string 'units'.  If omitted, default units of 'degrees' are assumed.
%   
%   See also WESTOF, ZERO22PI, NPI2PI, SMOOTHLONG, ANGLEDIM

%
%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%   $Revision: 1.5.4.1 $    $Date: 2003/08/01 18:16:02 $


if nargin <= 1; error('Incorrect number of arguments'); end

sz=size(lon);
lon=lon(:);

onerev = 360;
if nargin == 3
	onerev = angledim(onerev,'degrees',units);
end

% move to the left of lon0

lon = lon-onerev*floor(max(lon-lon0)/onerev);

% move to the right

indx = find(lon < lon0);
while ~isempty(indx)
	lon(indx) = lon(indx)+onerev;
	indx = find(lon < lon0);
end

lon=reshape(lon,sz);
