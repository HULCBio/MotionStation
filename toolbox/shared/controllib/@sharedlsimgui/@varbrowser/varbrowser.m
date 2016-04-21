function h = varbrowser

% Author(s): J. G. owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:15 $

import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.varbrowser;
h.javahandle = ImportView(h);

