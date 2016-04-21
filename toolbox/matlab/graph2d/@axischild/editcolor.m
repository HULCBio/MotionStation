function aObj = editcolor(aObj)
%AXISCHILD/EDITCOLOR Edit axischild color
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:11:29 $

HG = get(aObj,'MyHGHandle');
c = uisetcolor(HG);

if length(c)>1
   aObj = set(aObj,'Color',c);
   refresh;
end

