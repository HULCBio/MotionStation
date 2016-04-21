function [zd, zoneletter, zone]=timezone(lon,units)

%TIMEZONE  Sets the time zone description for longitudes
%
%  [zd, zltr, zone] = TIMEZONE(lon) calculates the navigational
%  time zone (based on longitude, ignoring local statutory deviations).
%  It returns numerical zone description (add as hours to zone time
%  to get Greenwich Mean Time,(GMT=+0Z), alphabetical zone indicator,
%  and string zone description plus alphabetical zone indicator.
%  For example, GMT is equivalent to '+0Z'.
%
%  [zd, zltr, zone] = timezone(lon,'units') uses the input string
%  'units' to define the input angle units.  If omitted,
%  'degrees' are assumed.
%
%  See also NAVFIX, GCWAYPTS, DRECKON

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Brown, E. Byrns
%   $Revision: 1.11.4.1 $    $Date: 2003/08/01 18:20:30 $


if nargin < 1
   error('Incorrect number of arguments')
elseif nargin == 1
   units = 'degrees';
end

%  Ensure that longitude is a column vector, then convert to degrees.

lon = lon(:);
lon = angledim(lon,units,'degrees');

% Ensure that longitudes lie between +/-180

lon = npi2pi(lon,'degrees','exact');

% Ordered time zone indicators, +180 down to -180 degrees

zones = 'MLKIHGFEDCBAZNOPQRSTUVWXY';
zones = zones';

% Each zone is 15 degrees wide.  "Zero" zone centered
% on 0 degrees longitude

zd = -round(lon/15);

% Make a "sign" string.  ASCII '+' is 43, '-' is 45
% Note that Western (negative) longitudes return
% positive zone descriptions, and vice versa.  This
% flipping of the sign is accomplished above at the round step.

spacechar = setstr(32);    sgn = spacechar(ones(size(zd)));
indx = find(zd<0);   if ~isempty(indx);  sgn(indx) = '-';  end
indx = find(zd>0);   if ~isempty(indx);  sgn(indx) = '+';  end

% Format actual numerical ZD's as strings

zdstr=num2str(abs(zd),'%2g');

% ZD's can act as indices into the indicator string

zoneletter    = zones(zd+13);
zonesvec(:,2) = zoneletter;
zonesvec(:,1) = '*';        %  Enforce a space

% Pack up the string

zone=[sgn,zdstr,zonesvec];

zone = shiftspc(zone);
zone = leadblnk(zone,' ');

%  Replace the hold characters with a space

indx = find(zone == '*');
if ~isempty(indx);  zone(indx) = ' ';  end
