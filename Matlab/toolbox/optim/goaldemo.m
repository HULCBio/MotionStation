%% Multiobjective goal attainment optimization
% This demo shows how the Optimization Toolbox can be used to solve 
% a pole-placement problem using the multiobjective goal attainment method. 

% Copyright 1990-2004 The MathWorks, Inc.
% $Revision: 1.18.4.2 $  $Date: 2004/04/06 01:10:23 $

%%
% Consider here a 2-input 2-output unstable plant.

A =  [ -0.5  0  0;  0  -2  10;  0  1  -2 ];

B =  [ 1  0;  -2  2;  0  1 ];

C =  [ 1  0  0;  0  0  1 ];

%%
% Suppose we wish to design an output feedback controller, x, to have 
% poles to the left of the location [-5, -3, -1] in the complex plane. 
% The controller must not have any gain element exceeding an absolute 
% value of 4.

goal = [-5, -3, -1]

%%
% Set the weights equal to the goals to ensure same percentage 
% under- or over-attainment in the goals.

weight = abs(goal)

%%
% Initialize output feedback controller

x0 = [ -1 -1; -1 -1]; 

%%
% Set upper and lower bounds on the controller

lb = repmat(-4,size(x0)) 
ub = repmat(4,size(x0))

%%
% Set optimization display parameter to give output at each iteration:

options = optimset('Display','iter');

%%
% Create a vector-valued function eigfun that returns the eigenvalues of the 
% closed loop system.  This function requires additional parameters (namely, 
% the matrices A, B, and C); the most convenient way to pass these is through 
% an anonymous function:

eigfun = @(x) sort(eig(A+B*x*C))

%%
% To begin the optimization we call FGOALATTAIN:

[x,fval,attainfactor,exitflag,output,lambda] = ...
        fgoalattain(eigfun,x0,goal,weight,[],[],[],[],lb,ub,[],options); 

%%
% The value of the control parameters at the solution is:

x

%%
% The eigenvalues of the closed loop system are as follows:

eigfun(x)     % These values are also held in output fval

%%
% The attainment factor indicates the level of goal achievement.
% A negative attainment factor indicates over-achievement, positive
% indicates under-achievement. The value attainfactor we obtained in 
% this run indicates that the objectives have been over-achieved by 
% about 39 percent:

attainfactor 

%%
% Suppose we now require the eigenvalues to be as near as possible
% to the goal values, [-5, -3, -1]. 
% Set options.GoalsExactAchieve to the number of objectives that should be 
% as near as possible to the goals (i.e., do not try to over-achieve):

% All three objectives should be as near as possible to the goals.
options = optimset(options,'GoalsExactAchieve',3);

%%
% We are ready to call the optimization solver:

[x,fval,attainfactor,exitflag,output,lambda] = ...
    fgoalattain(eigfun,x0,goal,weight,[],[],[],[],lb,ub,[],options);

%%
% This time the eigenvalues of the closed loop system are as follows:
eigfun(x)     % These values are also held in output fval

%%
% The attainment factor is the level of goal achievement. A negative 
% attainment factor indicates over-achievement, positive indicates 
% under-achievement. The low attainfactor obtained indicates that the
% eigenvalues have almost exactly met the goals:

attainfactor





