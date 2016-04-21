function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:14:06 $


switch c.att.LoopType
case 'ALL'
   suffix='all';
case 'CURRENT'
   suffix='current';
case 'TAG'
   suffix='by tag';
end

strout=sprintf('Figure Loop - %s', xlate(suffix));