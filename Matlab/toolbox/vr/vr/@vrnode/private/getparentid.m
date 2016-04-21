function x = getparentid(n)
%GETPARENTID Get the ID of the parent VRWORLD object.
%   X = GETPARENTID(N) gets the ID of the parent VRWORLD object.
%
%   Private function.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.2.4.1 $ $Date: 2002/11/17 14:14:04 $ $Author: batserve $

sw = struct(n.World);
x = [sw.id];
