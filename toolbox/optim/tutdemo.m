%% Tutorial for the Optimization Toolbox.
%
% This is a demonstration for the medium-scale algorithms in the Optimization
% Toolbox. It closely follows the Tutorial section of the users' guide.
%   
% All the principles outlined in this demonstration apply to the other 
% nonlinear solvers: FGOALATTAIN, FMINIMAX, LSQNONLIN, FSOLVE.
%
% The routines differ from the Tutorial Section examples in the User's
% Guide only in that some objectives are anonymous functions instead of
% M-file functions. 
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.18.4.3 $  $Date: 2004/04/06 01:10:34 $

%% Unconstrained optimization example
% Consider initially the problem of finding a minimum of the function:
%
%                                2        2
%       f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
% Define the objective to be minimized as an anonymous function:

fun = @(x) exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1)

%%
% Take a guess at the solution:

x0 = [-1; 1];

%%
% Set optimization options: turn off the large-scale algorithms (the default):

options = optimset('LargeScale','off');

%%
% Call the unconstrained minimization function:

[x, fval, exitflag, output] = fminunc(fun, x0, options);

%%
% The optimizer has found a solution at:
x

%%
% The function value at the solution is:
fval

%%
% The total number of function evaluations was: 

output.funcCount

%% Constrained optimization example: inequalities
%
% Consider the above problem with two additional constraints:
%
%                                      2        2
%   minimize  f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
%   subject to  1.5 + x(1).x(2) - x(1) - x(2) <= 0
%                   - x(1).x(2)               <= 10

%%
% The objective function this time is contained in an M-file, objfun.m:

type objfun

%%
% The constraints are also defined in an M-file, confun.m:

type confun

%%
% Take a guess at the solution:

x0 = [-1 1];

%%
% Set optimization options: turn off the large-scale algorithms (the 
% default) and turn on the display of results at each iteration:

options = optimset('LargeScale','off','Display','iter');

%%
% Call the optimization algorithm. We have no linear equalities or 
% inequalities or bounds, so we pass [] for those arguments:

[x,fval,exitflag,output] = fmincon(@objfun,x0,[],[],[],[],[],[],@confun,options);

%%
% A solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval 

%%
% Both inequality constraints are satisfied (and active) at the solution:

[c, ceq] = confun(x)

%%
% The total number of function evaluations was: 

output.funcCount

%% Constrained optimization example: inequalities and bounds
%
% Consider the previous problem with additional bound constraints:
%
%                                      2        2
%   minimize  f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
%   subject to  1.5 + x(1).x(2) - x(1) - x(2) <= 0
%                   - x(1).x(2)               <= 10
%
%          and                    x(1)        >= 0
%                                        x(2) >= 0

%%
% As in the previous example, the objective and constraint functions are
% defined in M-files. The file objfun.m contains the objective:

type objfun

%%
% The file confun.m contains the constraints:

type confun

%%
% Set the bounds on the variables:

lb = zeros(1,2); % Lower bounds x >= 0
ub = [];         % No upper bounds 

%%
% Again, make a guess at the solution:
  
x0 = [-1 1];

%%
% Set optimization options: turn off the large-scale algorithms (the 
% default). This time we do not turn on the Display option.

options = optimset('LargeScale','off');

%%
% Run the optimization algorithm:

[x,fval,exitflag,output] = fmincon(@objfun,x0,[],[],[],[],lb,ub,@confun,options);

%%
% The solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval

%%
% The constraint values at the solution are:

[c, ceq] = confun(x)

%%
% The total number of function evaluations was: 

output.funcCount

%% Constrained optimization example: user-supplied gradients
%
% Optimization problems can be solved more efficiently and accurately if
% gradients are supplied by the user. This demo shows how this may be
% performed. We again solve the inequality-constrained problem
%
%                                      2        2
%   minimize  f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
%   subject to  1.5 + x(1).x(2) - x(1) - x(2) <= 0
%                   - x(1).x(2)               <= 10

%%
% The objective function and its gradient are defined in the M-file 
% objfungrad.m:

type objfungrad

%%
% The constraints and their partial derivatives are contained in
% the M-file confungrad:

type confungrad 

%%
% Make a guess at the solution:

x0 = [-1; 1];

%%
% Set optimization options: since we are supplying the gradients, we have 
% the choice to use either the medium- or the large-scale algorithm; we will 
% continue to use the same algorithm for comparison purposes. 

options = optimset('LargeScale','off');

%%
% We also set options to use the gradient information in the objective
% and constraint functions. Note: these options MUST be turned on or
% the gradient information will be ignored.

options = optimset(options,'GradObj','on','GradConstr','on');

%%
% Call the optimization algorithm:

[x,fval,exitflag,output] = fmincon(@objfungrad,x0,[],[],[],[],[],[], ...
                                   @confungrad,options);

%%
% As before, the solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval

%%
% Both inequality constraints are active at the solution:

[c, ceq] = confungrad(x)

%%
% The total number of function evaluations was: 

output.funcCount

%% Constrained optimization example: equality constraints
%
% Consider the above problem with an additional equality constraint:
%
%                                      2        2
%   minimize  f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
%   subject to                  x(1)^2 + x(2)  = 1
%                              -x(1).x(2)     <= 10

%%
% Like in previous examples, the objective function is defined in the
% M-file objfun.m:

type objfun


%%
% The M-file confuneq.m contains the equality and inequality constraints:

type confuneq

%%
% Again, make a guess at the solution:

x0 = [-1 1];

%%
% Set optimization options: turn off the large-scale algorithms (the 
% default):

options = optimset('LargeScale','off');

%%
% Call the optimization algorithm:

[x,fval,exitflag,output] = fmincon(@objfun,x0,[],[],[],[],[],[],@confuneq,options);

%%
% The solution to this problem has been found at:

x 

%%
% The function value at the solution is: 

fval

%%
% The constraint values at the solution are:

[c, ceq] = confuneq(x)

%%
% The total number of function evaluations was: 

output.funcCount

%% Changing the default termination tolerances
%
% Consider the original unconstrained problem we solved first:
%
%                                      2        2
%   minimize  f(x) = exp(x(1)) . (4x(1)  + 2x(2)  + 4x(1).x(2) + 2x(2) + 1)
%
% This time we will solve it more accurately by overriding the 
% default termination criteria (options.TolX and options.TolFun). 

%%
% Create an anonymous function of the objective to be minimized:

fun = @(x) exp(x(1)) * (4*x(1)^2 + 2*x(2)^2 + 4*x(1)*x(2) + 2*x(2) + 1)

%%
% Again, make a guess at the solution:

x0 = [-1; 1];

%%
% Set optimization options: turn off the large-scale algorithms (the 
% default):

options = optimset('LargeScale','off');

%%
% Override the default termination criteria:

% Termination tolerance on X and f.
options = optimset(options,'TolX',1e-3,'TolFun',1e-3);      

%%
% Call the optimization algorithm:

[x, fval, exitflag, output] = fminunc(fun, x0, options);

%%
% The optimizer has found a solution at:

x

%%
% The function value at the solution is:

fval

%%
% The total number of function evaluations was: 

output.funcCount

%%
% Set optimization options: turn off the large-scale algorithms (the 
% default):

options = optimset('LargeScale','off');

%%
% If we want a tabular display of each iteration we can set
% options.Display = 'iter' as follows:

options = optimset(options, 'Display','iter');  

[x, fval, exitflag, output] = fminunc(fun, x0, options);

%%
% At each major iteration the table displayed consists of: (i) number of 
% function evaluations, (ii) function value, (iii) step length used in the 
% line search, (iv) gradient in the direction of search.
%


