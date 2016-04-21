function [newlat,newlong] = antipode(lat,long,units)
%ANTIPODE Compute the point on the opposite side of the globe.
%
%   [lat,long] = ANTIPODE(lat0,long0) returns the antipodal point
%   for the input lat0, long0.  The antipodal point is the point
%   exactly opposite the input point on the other side of the sphere.
%
%   [lat,long] = ANTIPODE(lat0,long0,'units') uses the input string
%   'units' to define the angle units of the input and output points.
%   If omitted, 'degrees' are assumed.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Brown, E. Byrns
%   $Revision: 1.9.4.2 $    $Date: 2003/12/13 02:50:05 $

checknargin(2,3,nargin,mfilename);
if nargin == 2
    units = 'degrees';
end

newlat  = angledim(-lat,units,units);    %  Complex argument test in angledim
unitpi  = angledim(pi,'radians',units);
newlong = npi2pi(long+unitpi,units,'exact');

%  Set output arguments if necessary
if nargout < 2;
    newlat = [newlat newlong];
end
