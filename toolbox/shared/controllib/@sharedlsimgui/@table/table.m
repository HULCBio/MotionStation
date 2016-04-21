function h = table(x, colnames)

% TABLE Constructor

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:08 $

h = sharedlsimgui.table;
h.celldata = x;
h.colnames = colnames;

