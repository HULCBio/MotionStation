function y = subsref(x, s)
%SUBSREF  Subscripted reference for VRWORLD objects.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2004/04/06 01:11:13 $ $Author: batserve $


% '.' overloads to 'vrnode', everything else left alone
switch s(1).type
  case '.'
    y = vrnode(x, s(1).subs);
  otherwise
    y = builtin('subsref', x, s(1));
end

% if this is not the last level of subsref, do the rest
if length(s)>1
  y = subsref(y, s(2:end));
end
