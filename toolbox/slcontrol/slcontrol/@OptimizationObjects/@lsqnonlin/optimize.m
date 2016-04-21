function [oppoint,opreport,exitflag,output] = optimize(this);

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/19 01:32:07 $

%% Construct the inputs to the optimizer
X = [this.x0(this.indx);this.u0(this.indu)];
LB = [this.lbx(this.indx);this.lbu(this.indu)];
UB = [this.ubx(this.indx);this.ubu(this.indu)];

%% Call the optimizer 
[X,resnorm,residual,exitflag,output] = lsqnonlin(@LocalFunctionEval,X,LB,UB,...
                                         this.linoptions.OptimizationOptions,this);

x = this.x0;
x(this.indx) = X(1:length(this.indx));

u = this.u0;
u(this.indu) = X(length(this.indx)+1:end);

%% Compute the results
[oppoint,opreport] = computeresults(this,x,u);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,G] = LocalFunctionEval(X,this)

%% Compute the errors in the constraints
UpdateErrors(this,X);

%% Compute the cost functions
F = [this.F_dx(:); this.F_y(:)];
%% Compute the Jacobian if needed.
if nargout > 1
    G = LocalComputeGradient(this.model, this.idx, this.indx, this.indu, this.iy_unique);
else
    G = [];
end

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = LocalComputeGradient(fcn, idx, indx, indu, iy)
%% Compute the gradient exactly using the Jacobian of the model

%% Compute the Jacobian
J = get_param(fcn,'Jacobian');
a = J.A; b = J.B; c = J.C; d = J.D; M = J.Mi;

P = speye(size(d,1)) - d*M.E;
Q = P \ c;
R = P \ d;

%% Close the LFT
A = a + b * M.E * Q;
B = b * (M.F + M.E * R * M.F);
C = M.G * Q;
D = M.H + M.G * R * M.F;

G = full([A(idx,indx), B(idx,indu); C(:,indx), D(:,indu)]);
