function out1 = setSelectedRows(h,theseRows)

% SETSELECTEDROWS Returns the table size (including any leading column) to java

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:06 $

import java.lang.*;

out1 = java.lang.Boolean(true);
try
   h.selectedrows = double(theseRows)+1;
catch
   out1 = java.lang.Boolean(false);
end

        