function angout = zero22pi(angin,units,approach)

%ZERO22PI Truncates angles into the 0 deg to 360 deg range
%
%  ang = ZERO22PI(angin) transforms input angles into the
%  0 to 360 degree range.
%
%  ang = ZERO22PI(angin,'units') uses the units defined by the
%  input string 'units'.  If omitted, default units of 'degrees'
%  are assumed.
%
%  ang = ZERO22PI(angin,'units','method') uses the method
%  defined by the corresponding input string.  Valid methods are:
%  'exact' for the exact transformation; 'inward' where all angles
%  are shifted epsilon towards the origin before the 0 to 360 degree
%  transformation; 'outward' where all angles are shifted epsilon
%  away from the origin before the 0 to 360 degree transformation.
%  If omitted, default method of 'exact' is assumed.
%
%  See also NPI2PI, ANGLEDIM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:20:42 $

if nargin == 0
    error('Incorrect number of arguments')
elseif nargin == 1
    units = [];     approach = [];
elseif nargin == 2
    approach = [];
end

%  Empty argument tests

if isempty(approach);   approach = 'exact';    end
if isempty(units);      units    = 'degrees';  end

%  Convert inputs to radians, the to the -pi to pi range

angin = angledim(angin,units,'radians');
angout = npi2pi(angin,'radians','exact');

epsilon = -epsm('radians');        %  Allow points near zero
indx = find(angout<epsilon);       %  to remain there

%  Shift the points in the -pi to 0 range to the pi to 2pi range

if ~isempty(indx);  angout(indx) = angout(indx) + 2*pi;  end;

indx = find(angout<0);            %  Reset near zero points
if ~isempty(indx);  angout(indx) = zeros(size(indx));  end

angout = angledim(angout,'radians',units);  %  Convert to output units
