function obj=subsasgn(obj,subscript,value)
%SUBSASGN subsasgn for an avifile object

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:51 $

if length(subscript) > 1
  error('AVIFILE objects only support one level of subscripting.');
end

switch subscript.type
 case '.'
  param = subscript.subs;
  obj = set(obj,param,value);
 otherwise
  error('AVIFILE objects only support structure subscripting.')
end
