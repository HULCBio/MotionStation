function value=subsref(obj,subscript)
%SUBSREF subsref for a AVIFILE object

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:52 $

if length(subscript) > 1
  error('AVIFILE objects only support one level of subscripting.');
end

switch subscript.type
 case '.'
  param = subscript.subs;    
  value = get(obj,param);
 otherwise
  error('AVIFILE objects only support structure subscripting.')
end
