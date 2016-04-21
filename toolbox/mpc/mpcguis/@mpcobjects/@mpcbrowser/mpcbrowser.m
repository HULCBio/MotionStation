function h = mpcbrowser

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2004/04/10 23:37:46 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.mpc.*;

h = mpcobjects.mpcbrowser;
h.javahandle = MPCimportView(h);

