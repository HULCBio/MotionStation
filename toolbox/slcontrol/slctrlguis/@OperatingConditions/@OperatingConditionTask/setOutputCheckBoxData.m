function setOutputCheckBoxData(this,type,checkedstate);

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:37:00 $

import java.lang.* java.awt.*;
outputs = this.OpSpecData.outputs;

if (type==2 && checkedstate)
    for ct = 1:length(outputs)
        outputs(ct).Known = ones(outputs(ct).PortWidth,1);
    end
elseif (type==2 && ~checkedstate)
    for ct = 1:length(outputs)
        outputs(ct).Known = zeros(outputs(ct).PortWidth,1);
    end    
end

%% Set the dirty flag
this.setDirty
