function chgunits(sys,newUnits)
%CHGUNITS  Change frequency units of an FRD model.
%
%   SYS = CHGUNITS(SYS,UNITS) changes the units of the frequency
%   points stored in the FRD model SYS to UNITS, where UNITS
%   is either 'Hz or 'rad/s'.  A 2*pi scaling factor is applied
%   to the frequency values and the 'Units' property is updated.
%   If the 'Units' field already matches UNITS, no action is taken.
%
%   See also FRD, SET, GET.

%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.7 $  $Date: 2002/04/10 05:51:40 $

error('CHGUNITS is applicable to FRD models only.');