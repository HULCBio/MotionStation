function V = unitconv(V,OldUnit,NewUnit);
%UNITCONV  Perform unit conversion on data
%
%   V = UNITCONV(V,OldUnit,NewUnit) converts the values in V based on
%   a unit conversion from OldUnit to NewUnit.
%
%   Supported magnitude unit types:
%      'abs'     ('absolute')
%      'dB'      ('decibels')
%
%   Supported phase unit types:
%      'deg'     ('degrees')
%      'rad'     ('radians')
%
%   Supported frequency unit types:
%      'Hz'      ('hertz')
%      'rad/sec' ('rad/s')

%   Author: Adam DiVergilio, 11-99
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2002/11/11 22:22:21 $

% RE: No error checking (optimized for speed)
if isequal(OldUnit,NewUnit) || isempty(NewUnit) || isempty(OldUnit)
   return
end

switch lower(OldUnit(1))
case 'a'
   % Absolute
   if strcmpi(NewUnit(1),'d')  % convert to dB
      % Protect against log(0)
      V = mag2dB(V);
   end
   
case 'd'
   % Degrees or dB
   if strncmpi(OldUnit,'deg',3)
      % OldUnit = degrees
      if strcmpi(NewUnit(1),'r')  % convert to radians
         V = V*(pi/180);
      end
   else
      % Assume dB or decibels
      if strcmpi(NewUnit(1),'a')  % convert to absolute
         V = 10.^(V/20);
      end
   end
   
case 'h'
   % Hertz
   if strcmpi(NewUnit(1),'r')  % convert to rad/sec
      V = V*(2*pi);
   end
   
case 'r'
   % Radians or rad/sec
   if strncmpi(OldUnit,'rad/s',5)
      % OldUnit = radians/sec
      if strcmpi(NewUnit(1),'h')  % convert to Hz
         V = V/(2*pi);
      end
   else
      % Assume radians
      if strcmpi(NewUnit(1),'d')  % convert to degrees
         V = V*(180/pi);
      end    
   end
end


