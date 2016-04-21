function epsilon = epsm(units)

%EPSM  Calculate the accuracy of the map computations
%
%  e = EPSM returns the accuracy of computations performed in
%  the Mapping Toolbox.  The accuracy returned is in degrees.
%
%  e = EPSM('units') returns the accuracy in the units specified
%  by the string 'units'.  If omitted, 'degrees' are assumed.
%
%  See also EPS

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:16:09 $

%  Define the limit in degrees

degepsilon = 1.0E-6;

if nargin == 0
    epsilon = degepsilon;   return

%  Speed up function with special unit string tests

elseif strcmp(units,'degrees')
	epsilon = degepsilon;   return

elseif strcmp(units,'radians')
	epsilon = degepsilon*pi/180;   return

else
    [units,msg] = unitstr(units,'angles');
    if ~isempty(msg);   error(msg);   end
    epsilon = angledim(degepsilon,'degrees',units);
end
