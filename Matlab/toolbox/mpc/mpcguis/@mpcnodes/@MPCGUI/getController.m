function MPCobj = getController(this, Controller)

% Searches for the designated MPCController
% node and retrieves its MPC object.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:36:11 $

MPCControllers = this.getMPCControllers;
Controllers = MPCControllers.getChildren;
if nargin > 1 && isempty(Controllers)
    MPCobj = [];
else
    if nargin < 2
        % Controller name not supplied.  Use current controller if 
        % designated.  If not, use first in list.
        Controller = MPCControllers.CurrentController;
        if isempty(Controller) && ~isempty(MPCControllers.Controllers)
            Controller = MPCControllers.Controllers{1};
        end
    end
    if ~isempty(Controller)
        % Controller name supplied.  Search for it.
        ControllerNode = Controllers.find('Label', Controller);
        if ~isempty(ControllerNode)
            MPCobj = ControllerNode.getController;
        else
            MPCobj = [];
        end
    else
        MPCobj = [];
    end
end
