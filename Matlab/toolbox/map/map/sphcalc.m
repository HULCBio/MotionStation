function val = sphcalc(rad,calculation)

%SPHCALC  Computes volume and surface area for a sphere
%
%  SPHCALC(r,'volume') computes the volume of a sphere
%  defined by the input radius.  The units are defined
%  by the input radius.
%
%  SPHCALC(r,'surfarea') computes the surface area of a sphere
%  defined by the input radius.
%
%  See also ELPCALC

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:22 $


if nargin ~= 2
    error('Incorrect number of arguments')
elseif max(size(rad)) ~= 1
    error('Radius input must be a scalar')
end


if strcmp(calculation,'volume')
    val = (4*pi/3) * rad^3;

elseif strcmp(calculation,'surfarea')
    val = 4*pi*rad^2;

else
    error('Unrecognized calculation string')
end
