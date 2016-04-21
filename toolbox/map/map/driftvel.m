function [windfrom,windspeed] = driftvel(course,groundspeed,heading,airspeed)

%DRIFTVEL wind or current from heading, course and speeds
%
% [windfrom,windspeed] = DRIFTVEL(course,groundspeed,heading,airspeed)
% computes the wind (for aircraft) or current (for watercraft) from 
% course, heading and speeds. Course and groundspeed are the direction 
% and speed of movement relative to the ground (in degrees), Heading 
% is the direction in which the vehicle is steered, and airspeed is the
% speed of the vehicle relative to the airmass or water. The output 
% windfrom is the direction facing into the wind or current (in degrees), 
% and windspeed is the speed of the wind or current (in the same units 
% as airspeed and groundspeed).
%
% See also DRIFTCORR

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.1 $ $Date: 2003/08/01 18:16:01 $

if nargin < 4
   error('Incorrect number of input arguments')
end

[x1,y1] = pol2cart(deg2rad(course),groundspeed);
[x2,y2] = pol2cart(deg2rad(heading),airspeed);
[th,windspeed] = cart2pol(x2-x1,y2-y1);
windfrom = zero22pi(rad2deg(th));


