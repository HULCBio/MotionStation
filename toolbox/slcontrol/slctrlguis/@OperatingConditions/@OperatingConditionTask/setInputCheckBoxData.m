function setInputCheckBoxData(this,type,checkedstate);
% SETINPUTCHECKBOXDATA

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:36:58 $

import java.lang.* java.awt.*;
inputs = this.OpSpecData.inputs;

if (type==2 && checkedstate)
    for ct = 1:length(inputs)
        inputs(ct).Known = ones(inputs(ct).PortWidth,1);
    end
elseif (type==2 && ~checkedstate)
    for ct = 1:length(inputs)
        inputs(ct).Known = zeros(inputs(ct).PortWidth,1);
    end    
end

%% Set the dirty flag
this.setDirty
