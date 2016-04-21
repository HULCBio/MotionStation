function [out1,out2] = merccalc(in1,in2,direction,units,geoid)

%MERCCALC  Transformation of data to and from a Mercator space
%
%  [x,y] = MERCCALC(lat,lon,'forward') transforms Greenwich
%  coordinate data to a Mercator space.  This transformation is
%  useful when manipulating data for heading calculations,
%  navigation calculations, etc.  This allows data to be operated
%  on in the workspace, independent of a map axes.
%
%  [x,y] = MERCCALC(lat,lon,'forward',geoid) transforms the Greenwich
%  coordinate data on the ellipsoid defined by the input geoid. The
%  geoid vector is of the form [semimajor axes, eccentricity].  If
%  omitted, the unit sphere, geoid = [1 0], is assumed.
%
%  [x,y] = MERCCALC(lat,lon,'forward','units') and
%  [x,y] = MERCCALC(lat,lon,'forward','units',geoid) uses the input
%  'units' to define the angle units of the input data.  If omitted,
%  'degrees' are assumed.
%
%  [lat,lon] = MERCCALC(x,y,'inverse') transforms from the Mercator
%  space to the Greenwich coordinate frame.
%
%  [lat,lon] = MERCCALC(x,y,'inverse',geoid),
%  [lat,lon] = MERCCALC(x,y,'inverse','units') and
%  [lat,lon] = MERCCALC(x,y,'inverse','units',geoid) are all valid
%  calling forms.
%
%  See also  EQACALC

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.10.4.1 $ $Date: 2003/08/01 18:17:11 $
%  Written by:  E. Byrns, E. Brown


if nargin < 3
    error('Incorrect number of arguments')
elseif nargin == 3
    units = [];     geoid = [];
elseif nargin == 4 & isstr(units)
    geoid = [];
elseif nargin == 4 & ~isstr(units)
    geoid = units;     units = [];
end

%  Set default data if necessary

if isempty(units);  units = 'degrees';   end
if isempty(geoid);  geoid = [1 0];       end

%  Dimension tests

if ~isequal(size(in1),size(in2))
     error('Inconsistent dimensions on inputs')
end

%  Test the geoid input

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Construct the necessary map structure

mstruct = defaultm('mercator');

mstruct.geoid        = geoid;
mstruct.angleunits   = units;
mstruct.mapparallels = [0 0];        %  Hard code some options used
mstruct.origin       = [0 0 0];      %  in mercator.m
mstruct.aspect       = 'normal';
mstruct.flatlimit    = angledim([-90 90],'degrees',units);
mstruct.flonlimit    = angledim([-180 180],'degrees',units);

mstruct.trimlat = angledim([-89.9 89.9],'degrees',units);

mstruct = defaultm(mercator(mstruct));

%  Set some interface variables for mercator

object = 'text';           %  Suppress all clips and trims
savepts.trimmed = [];      %  Savepts needed in inverse direction
savepts.clipped = [];

[out1,out2] = mercator(mstruct,in1,in2,object,direction,savepts);

