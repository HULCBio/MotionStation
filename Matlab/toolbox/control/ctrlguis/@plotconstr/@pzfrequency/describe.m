function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $ $Date: 2002/04/10 05:10:02 $

Str = 'Natural Frequency';

if (nargin == 2) & strcmp(keyword, 'detail')
  str1 = unitconv(Constr.Frequency, 'rad/sec', Constr.FrequencyUnits);
  
  Str = sprintf('%s (%0.3g)', Str, str1);
end
