function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:10:29 $

if strcmp(Constr.Format,'damping')
  Str = 'Damping Ratio';
else
  Str = 'Percent Overshoot';
end

if (nargin == 2) & strcmp(keyword, 'detail')
  if strcmp(Constr.Format, 'damping')
    Str = sprintf('%s (%0.3g)', Str, Constr.Damping); 
  else
    Str = sprintf('%s (%0.3g)', Str, Constr.overshoot); 
  end
end
