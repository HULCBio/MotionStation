function delete(aObj)
%HGBIN/DELETE Delete hgbin object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/01/15 21:12:48 $


for anItem = aObj.Items
   delete(anItem);
end

delete(aObj.scribehgobj);
