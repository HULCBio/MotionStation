function middrag(HG)
%MIDDRAG  Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 04:07:53 $

ud = getscribeobjectdata(HG);
middrag(ud.HandleStore);
