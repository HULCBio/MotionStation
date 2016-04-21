function op = ConstructOpCond(this,x,u)
% CONSTRUCTOPCOND

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/01 09:19:59 $

%% Compute the outputs
y = getOutputs(this.opcond,x,u);
%% Compute the derivatives
dx = feval(this.model, this.t, x, u, 'derivs')';
xk1 = feval(this.model, this.t, x, u, 'update')';
if ~isempty(xk1)
    dx = [dx(:);xk1(:)-x(this.ncstates(1)+1:end,:)];
end   

%% Create the new operating condition object
op = CreateOpCond(this.opcond,x,u,y,dx);