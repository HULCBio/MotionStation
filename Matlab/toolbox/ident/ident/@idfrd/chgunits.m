function sys = chgunits(sys,newUnits)
%CHGUNITS  Change frequency units of an IDFRD model.
%
%   SYS = CHGUNITS(SYS,UNITS) changes the units of the frequency
%   points stored in the IDFRD model SYS to UNITS, where UNITS
%   is either 'Hz or 'rad/s'.  A 2*pi scaling factor is applied
%   to the frequency values and the 'Units' property is updated.
%   If the 'Units' field already matches UNITS, no action is taken.
%
%   See also FRD, SET, GET.

%       Author(s): S. Almy
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.5 $  $Date: 2002/01/21 09:34:19 $

if ~ischar(newUnits)
   error('Second argument to CHGUNITS must be a UNITS string');
elseif ~strncmpi(sys.Units,newUnits,1)
   if strncmpi(newUnits,'h',1)
      sys.Units = 'Hz';
      sys.Frequency = sys.Frequency / (2*pi);
   elseif strncmpi(newUnits,'r',1)
      sys.Units = 'rad/s';
      sys.Frequency = sys.Frequency * (2*pi);
   else
      error('Unrecognized UNITS string.');
   end
end

