function first = utposfra(first,last,loc,val)
%UTPOSFRA Utilities  for setting frame position.
%   FIRST = UTPOSFRA(FIRST,LAST,LOC,VAL)

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 28-May-98.
%   Last Revision: 29-May-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 19:48:44 $

if     ~isinf(loc)    , first = loc(1)+(loc(2)-val)/2;
elseif ~isinf(first)  ,
elseif ~isinf(last)   , first = last-val;
else                  , first = 10;
end
