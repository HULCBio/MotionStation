function [oppoint,opreport] = computeresults(this,x,u)
% COMPUTERESULTS

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/12/04 02:36:46 $

%% Construct the operating condition object
oppoint = CreateOpPoint(this.opcond,x,u);

%% Compute with the output constraint deviations
y = getOutputs(this.opcond,x,u);

%% Compute the derivatives and the update deviations
dx = feval(this.model, this.t, x, u, 'derivs');
xk1 = feval(this.model, this.t, x, u, 'update');
if ~isempty(xk1)
    dx = [dx(:);xk1(:)-x(this.ncstates+1:end,:)];
end

%% Compute the operating condition report
opreport = CreateOpReport(this.opcond,x,u,y,dx);