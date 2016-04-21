function ans = eq(obj1,obj2)
%EQ  '==' method for fdmeas / fdspec objects

%   Author: T. Krauss
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.7 $

s1 = struct(obj1);
s2 = struct(obj2);

ans = [s1.h] == [s2.h];
