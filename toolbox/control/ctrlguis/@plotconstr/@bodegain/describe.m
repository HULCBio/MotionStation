function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:08:13 $

if strcmp(Constr.Type, 'upper')
  Str = 'Upper Gain Limit';
else
  Str = 'Lower Gain Limit';
end

if (nargin == 2) & strcmp(keyword, 'detail')
  Slope = Constr.slope;
  Range = unitconv(Constr.Frequency, 'rad/sec', Constr.FrequencyUnits);
  Str = sprintf('%s (%0.3g dB/dec from %0.3g to %0.3g)', ...
		Str, Slope, Range(1), Range(2)); 
end
