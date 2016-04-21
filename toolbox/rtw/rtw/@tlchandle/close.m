function close(t)
%CLOSE closes a tlc context
%   CLOSE(H) where H is a TLCHANDLE object closes
%   the current context.
%
%   See also: TLCHANDLE

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:25 $

tlc('close',t.Handle);