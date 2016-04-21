function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:27 $

if strcmp(c.att.ObjType,'Object')
   objName=xlate('HG Object');
else
   objName=xlate(c.att.ObjType);
end

strout=sprintf('%s Name',objName);