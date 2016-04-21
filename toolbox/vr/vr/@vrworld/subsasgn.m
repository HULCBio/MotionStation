function x = subsasgn(x, s, v)
%SUBSASGN  Subscripted assignment for VRWORLD objects.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2004/04/06 01:11:12 $ $Author: batserve $


% leave it to subsref'ed objects
subsasgn(subsref(x, s(1)), s(2:end), v);
