function clearplot(ds)
%CLEARPLOT Clear current plot data

%   $Revision: 1.1.6.2 $  $Date: 2004/01/24 09:32:28 $
%   Copyright 2003-2004 The MathWorks, Inc.

ds.plotx = [];
ds.ploty = [];
if ~isempty(ds.line) && ishandle(ds.line)
   delete(ds.line);
end
