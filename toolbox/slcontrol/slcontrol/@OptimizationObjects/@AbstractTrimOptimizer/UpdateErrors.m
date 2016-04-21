function UpdateErrors(this)
% UPDATEERRORS

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/01 09:20:00 $

%% Compute with the output constraint deviations
S.y = getOutputs(S.this,x,u);
F_y = zeros(length(S.y),1);
F_y(S.iy) = S.y(S.iy) - S.y0(S.iy);
F_y(S.indy) = -max([S.y(S.indy)-S.uby(S.indy),S.lby(S.indy)-S.y(S.indy),zeros(length(S.indy),1)]');
this.F_y = F_y;

%% Compute the derivatives and the update deviations
dx = feval(S.model, S.t, x, u, 'derivs');
xk1 = feval(S.model, S.t, x, u, 'update');
if ~isempty(xk1)
    dx = [dx(:);xk1(:)-x(S.nstates+1:end,:)];
end

%% Compute the error in dx/dt = 0, xk+1 - xk = 0 
F_dx = dx(S.idx) - S.dx0(S.idx);
this.F_dx = F_dx;