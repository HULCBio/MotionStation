function clearplot(hFit)
%CLEARPLOT Clear plot information from fit object

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:41 $
%   Copyright 2003-2004 The MathWorks, Inc.

hFit.x = [];
hFit.y = [];
if ~isempty(hFit.linehandle) && ishandle(hFit.linehandle)
   delete(hFit.linehandle);
end
