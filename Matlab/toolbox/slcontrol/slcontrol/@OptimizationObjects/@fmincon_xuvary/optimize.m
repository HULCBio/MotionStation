function [oppoint,opreport,exitflag,output] = optimize(this);

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:35:07 $

%% Construct the inputs to the optimizer
X = [this.x0;this.u0];
LB = [this.lbx;this.lbu];
UB = [this.ubx;this.ubu];

%% Call the optimizer 
[X,fval,exitflag,output] = constrsh(@LocalFunctionEval,X,...
                                           [],[],[],[],LB,UB,...
                                           @LocalEqualityConstraint,...
                                           this.linoptions.OptimizationOptions,this);
                                                  
%% Extract the state and input vectors                                    
x = X(1:length(this.x0));
u = X(length(this.x0)+1:end);

%% Compute the results
[oppoint,opreport] = computeresults(this,x,u);

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [F,G] = LocalFunctionEval(X,this)

%% Compute the errors in the constraints
UpdateErrors(this,X);

%% Compute scalar output
F = max(abs([this.F_x(:);this.F_u(:)]));

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [c,ceq,Gc,Gceq] = LocalEqualityConstraint(X,this);
%% LocalEqualityConstraint Helper function for TRIM.
%%   LocalEqualityConstraint is a helper function for trim to compute f(X)
%%   where X = [x;u] is a combination of the independent variables specified
%%   by the user.  The equation being forced to zero (fmincon) is
%%       
%%         |   dx/dt   |
%%   F  =  | xk+1 - xk |
%%         |  y - ydes | 

ceq = [this.F_dx(:);this.F_y(:)];

%% Compute the Jacobian
if nargout > 2
    Gceq = LocalComputeGradient(S.model, S.idx, S.indx, S.indu);
else
    Gceq = [];
end

%% Compute the cost function on the states and the inputs to be minimized.
%% This is done with the function f(x)
c = [];
Gc = [];

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function G = LocalComputeGradient(fcn, idx, indx, indu)
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

G = full([A(idx,indx), B(idx,indu);
    C(iy,indx),  D(iy,indu)]);
