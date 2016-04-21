function scriberestoresavefcns
%SCRIBERESTORESAVEFCNS Plot Editor helper function

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2002/04/15 04:08:25 $

if isappdata(gcbo,'ScribeSaveFcns')
   saveFcns = getappdata(gcbo,'ScribeSaveFcns');
   set(gcbo,'ButtonDownFcn',saveFcns);
end