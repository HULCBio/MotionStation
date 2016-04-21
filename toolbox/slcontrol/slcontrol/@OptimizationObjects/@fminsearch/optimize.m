function [oppoint,opreport,exitflag,output] = optimize(this);
% OPTIMIZE

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:36:53 $

%% Construct the inputs to the optimizer
X = [this.x0(this.indx);this.u0(this.indu)];
LB = [this.lbx(this.indx);this.lbu(this.indu)];
UB = [this.ubx(this.indx);this.ubu(this.indu)];

%% Call the optimizer 
[X,fval,exitflag,output] = fminsearch(@LocalFunctionEval,X,...
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

%% Compute the errors in the constraints
F = norm([this.F_dx(:); this.F_y(:)]);
G = [];