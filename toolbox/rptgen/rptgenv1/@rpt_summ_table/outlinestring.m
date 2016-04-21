function strout=outlinestring(r,c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:45 $

objInfo=get_table(r,c);

strout=sprintf('%s Summary Table ',xlate(objInfo.displayName));
