function aObj = editstyle(aObj, style)
%EDITLINE/EDITSTYLE Edit editline linestyle
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/01/15 21:12:21 $


switch style
case 'solid'
   val = '-';
case 'dash'
   val = '--';
case 'dot'
   val = ':';
case 'dashdot'
   val = '-.';
otherwise
   return
end

aObj = set(aObj, 'LineStyle', val);
