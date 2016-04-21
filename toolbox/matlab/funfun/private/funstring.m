function s = funstring(fun)
% Yield a string representing fun.

%   Mike Karr, Jacek Kierzenka, 11-19-99
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/01/24 09:21:51 $

if isa(fun, 'function_handle')
  s = upper(func2str(fun));
elseif ischar(fun)
  s = upper(fun);
elseif isa(fun, 'inline')
  s = formula(fun);
else
  s = 'unknown';
end
