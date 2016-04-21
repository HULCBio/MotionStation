function Str = describe(Constr, keyword)
%DESCRIBE  Returns constraint description.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:08:43 $

Str = 'Settling Time';

if (nargin == 2) & strcmp(keyword, 'detail')
  Str = sprintf('%s (%0.3g)', Str, Constr.SettlingTime); 
end
