function Str = describe(Constr, keyword)
%DESCRIBE  Returns Phase Margin constraint description.

%   Author(s): Bore Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 05:09:42 $

Str = 'Phase Margin';

if (nargin == 2) & strcmp(keyword, 'detail')
  str1 = unitconv(Constr.MarginPha, 'deg', Constr.PhaseUnits);
  str2 = unitconv(Constr.OriginPha, 'deg', Constr.PhaseUnits);
  Str = sprintf('%s (%0.3g at %0.3g)', Str, str1, str2); 
end
