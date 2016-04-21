function MPCobj = getController(this, Controller)

% Searches for the designated MPCController
% node and retrieves its MPC object.

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:37:05 $

if nargin > 1
    MPCobj = this.getRoot.getController(Controller);
else
    MPCobj = this.getRoot.getController;
end
