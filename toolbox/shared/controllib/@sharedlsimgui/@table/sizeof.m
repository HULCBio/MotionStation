function out1 = sizeof(h)

% SIZEOF Returns the table size (including any leading column) to java

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:07 $

out1 = javaArray('java.lang.Double',2);
out1(2) = java.lang.Double(size(h.celldata,2));
out1(1) = java.lang.Double(size(h.celldata,1));
        