function b = subsref(a,s)
%SUBSREF Subscripted reference for Database Toolbox object.

%   Author(s): C.F.Garvin, 10-30-98
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.5 $   $Date: 2002/06/17 12:01:38 $

tmp = struct(a);    %Get object structure

switch s(1).type
  
  case '.'     %Access fields of object
    eval(['b = tmp.' s(1).subs ';'])
    
  otherwise    %Return object
    b = tmp;
    
end
