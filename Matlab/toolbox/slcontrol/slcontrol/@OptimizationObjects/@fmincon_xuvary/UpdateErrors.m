function UpdateErrors(this,X)
% UPDATEERRORS

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:35:05 $

%% Create the state and input vectors
x = X(1:length(this.x0));
u = X(length(this.x0)+1:end);

%% Compute with the output constraint deviations
y = getOutputs(this.opcond,x,u);
F_y = zeros(length(y),1);
F_y(this.iy) = y(this.iy) - this.y0(this.iy);
F_y(this.indy) = -max([y(this.indy)-this.uby(this.indy),...
                         this.lby(this.indy)-y(this.indy),...
                         zeros(length(this.indy),1)]');
this.F_y = F_y;

%% Compute the derivatives and the update deviations
dx = feval(this.model, this.t, x, u, 'derivs');
xk1 = feval(this.model, this.t, x, u, 'update');
if ~isempty(xk1)
    dx = [dx(:);xk1(:)-x(this.ncstates+1:end,:)];
end

%% Compute the error in dx/dt = 0, xk+1 - xk = 0 
F_dx = dx(this.idx) - this.dx0(this.idx);
this.F_dx = F_dx;

%% Compute the errors in x and u
if ~isempty([this.ix(:);this.iu(:)])
    this.F_x = x(this.ix)-this.x0(this.ix);
    this.F_u = u(this.iu)-this.u0(this.iu);
else
    this.F_x = x - this.x0(:);
    this.F_u = u - this.u0(:);
end
