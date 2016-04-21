function isEqual=eq(a,b)
%EQ

%   Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/10 17:57:16 $
b=tlchandle(b);
isEqual=(a.Handle==b.Handle);