function setStateCheckBoxData(this,type,checkedstate);

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:37:02 $

import java.lang.* java.awt.*;
states = this.OpSpecData.states;

if (type==2 && checkedstate)
    for ct = 1:length(states)
        states(ct).Known = ones(states(ct).Nx,1);
    end
elseif (type==2 && ~checkedstate)
    for ct = 1:length(states)
        states(ct).Known = zeros(states(ct).Nx,1);
    end    
elseif (type==3 && checkedstate)
    for ct = 1:length(states)
        states(ct).SteadyState = ones(states(ct).Nx,1);
    end
elseif (type==3 && ~checkedstate)
    for ct = 1:length(states)
        states(ct).SteadyState = zeros(states(ct).Nx,1);
    end    
end

%% Set the dirty flag
this.setDirty
