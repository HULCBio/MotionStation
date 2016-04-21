function tf=ishandle(p)
%ISHANDLE returns true if the pointer handle is valid
%   TF=ISHANDLE(P) returns true if P.h is a non-integer HG handle

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:45 $

if ishandle(p.h) & p.h/floor(p.h)>1
   tf=logical(1);
else
   tf=logical(0);
end