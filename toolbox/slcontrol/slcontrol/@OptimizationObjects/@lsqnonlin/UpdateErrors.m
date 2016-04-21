function UpdateErrors(this,X)
% UPDATEERRORS

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:36:56 $

%% Create the state and input vectors
x = this.x0;
x(this.indx) = X(1:length(this.indx));
u = this.u0;
u(this.indu) = X(length(this.indx)+1:end);

%% Compute with the output constraint deviations
% warning('1')
y = getOutputs(this.opcond,x,u);
F_y = zeros(length(y),1);
F_y(this.iy) = y(this.iy) - this.y0(this.iy);
F_y(this.indy) = -max([y(this.indy)-this.uby(this.indy),this.lby(this.indy)-y(this.indy),zeros(length(this.indy),1)]');
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