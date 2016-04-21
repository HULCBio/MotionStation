function Str = describe(Constr, keyword)
%DESCRIBE  Returns Closed-loop peak gain constraint description.

%   Author(s): Bore Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:11:47 $

Str = 'Closed-Loop Peak Gain';

if (nargin == 2) & strcmp(keyword, 'detail')
  str1 = unitconv(Constr.PeakGain,   'dB', Constr.MagnitudeUnits);
  str2 = unitconv(Constr.OriginPha, 'deg', Constr.PhaseUnits);
  Str = sprintf('%s (%0.3g at %0.3g)', Str, str1, str2); 
end
