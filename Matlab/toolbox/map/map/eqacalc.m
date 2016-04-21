function [out1,out2] = eqacalc(in1,in2,origin,direction,units,geoid)

%EQACALC  Transformation of data to and from an Equal Area space
%
%  [x,y] = EQACALC(lat,lon,'forward') transforms Greenwich
%  coordinate data to a Cylindrical Equal Area space.  This
%  transformation is useful when manipulating data for equal area
%  statistical calculations, etc.  This allows data to be operated
%  on in the workspace.
%
%  [x,y] = EQACALC(lat,lon,'forward',geoid) transforms the Greenwich
%  coordinate data on the ellipsoid defined by the input geoid. The
%  geoid vector is of the form [semimajor axes, eccentricity].  If
%  omitted, the unit sphere, geoid = [1 0], is assumed.
%
%  [x,y] = EQACALC(lat,lon,'forward','units') and
%  [x,y] = EQACALC(lat,lon,'forward','units',geoid) uses the input
%  'units' to define the angle units of the input data.  If omitted,
%  'degrees' are assumed.
%
%  [lat,lon] = EQACALC(x,y,'inverse') transforms from the Cylindrical
%  Equal Area space to the Greenwich coordinate frame.
%
%  [lat,lon] = EQACALC(x,y,'inverse',geoid),
%  [lat,lon] = EQACALC(x,y,'inverse','units') and
%  [lat,lon] = EQACALC(x,y,'inverse','units',geoid) are all valid
%  calling forms.
%
%  See also  MERCCALC

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.1 $ $Date: 2003/08/01 18:16:11 $
%  Written by:  E. Byrns, E. Brown




if nargin < 4
    error('Incorrect number of arguments')
elseif nargin == 4
    units = [];     geoid = [];
elseif nargin == 5 & isstr(units)
    geoid = [];
elseif nargin == 5 & ~isstr(units)
    geoid = units;     units = [];
end

%  Set default data if necessary

if isempty(units);   units  = 'degrees';   end
if isempty(geoid);   geoid  = [1 0];       end
if isempty(origin);  origin = [0 0 0];     end

%  Dimension tests

if ~isequal(size(in1),size(in2))
     error('Inconsistent dimensions on inputs')
end

%  Test the geoid input

[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

%  Construct the necessary map structure

mstruct = defaultm('eqacylin');

mstruct.geoid        = geoid;
mstruct.angleunits   = units;
mstruct.mapparallels = [0 0];        %  Hard code some options used
mstruct.origin       = origin;       %  in eqacylin.m
mstruct.aspect       = 'normal';
mstruct.flatlimit    = angledim([-90 90],'deg',units);
mstruct.flonlimit    = angledim([-180 180],'deg',units);

mstruct = defaultm(eqacylin(mstruct));

%  Set some interface variables for eqacylin

object = 'text';           %  Suppress all clips and trims
savepts.trimmed = [];      %  Savepts needed in inverse direction
savepts.clipped = [];

[out1,out2] = eqacylin(mstruct,in1,in2,object,direction,savepts);

