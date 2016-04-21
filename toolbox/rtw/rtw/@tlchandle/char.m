function c=char(t)
%CHAR converts the TLCHANDLE object into a string

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:28 $

c=num2str(t.Handle);
