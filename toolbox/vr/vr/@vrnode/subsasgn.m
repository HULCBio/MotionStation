function x = subsasgn(x, s, v)
%SUBSASGN  Subscripted assignment for VRNODE objects.

%   Copyright 1998-2004 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2004/03/02 03:08:11 $ $Author: batserve $


% '.' overloads to 'setfield', everything else left to subsref'ed objects
switch s(1).type
  case '.'
    setfield(x, s(1).subs, v);   %#ok this is overloaded SETFIELD
  otherwise
    subsasgn(subsref(x, s(1)), s(2:end), v);
end
