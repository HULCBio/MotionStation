function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:16:14 $

if ~isempty(c.att.DescString)
   strout=sprintf('? Error - was "%s"', c.att.DescString );
else
   strout=xlate('<Empty>');
end


