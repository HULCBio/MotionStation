%% Coding and minimizing an objective function using Pattern Search
% This is a demonstration of how to create and minimize an objective
% function using Pattern Search in the Genetic Algorithm and Direct Search
% Toolbox.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.2 $  $Date: 2004/04/04 03:24:40 $

%% A simple objective function
% Here we want to minimize a simple function of two variables
%
%     min f(x) = (4 - 2.1*x1^2 + x1^4/3)*x1^2 + x1*x2 + (-4 + 4*x2^2)*x2^2;
%      x
% The above function is known as 'cam' as described in L.C.W. Dixon and
% G.P. Szegö (eds.), Towards Global Optimisation 2, North-Holland,
% Amsterdam, 1978. 

%% Coding the objective function
% We create an M-file named simple_objective.m with the following
% code in it:
%
%     function y = simple_objective(x) 
%     y = (4 - 2.1*x(1)^2 + x(1)^4/3)*x(1)^2 + x(1)*x(2) + ...
%         (-4 + 4*x(2)^2)*x(2)^2;
%
% The Pattern Search solver assumes the objective function will take one
% input x where x has as many elements as number of variables in the
% problem.  The objective function computes the value of the function and
% returns that scalar value in its one return argument y.

%% Minimizing using PATTERNSEARCH
% To minimize our objective function using the PATTERNSEARCH function, 
% we need to pass in a function handle to the objective function as well 
% as specifying a start point as the second argument. 

   ObjectiveFunction = @simple_objective;
   X0 = [0.5 0.5];   % Starting point 
   [x,fval] = patternsearch(ObjectiveFunction,X0)

%% A objective function with additional arguments
% Sometimes we want our objective function to be parameterized by extra
% arguments that act as constants during the optimization.  For example,
% in the previous objective function, say we want to replace the
% constants 4, 2.1, and 4 with parameters that we can change to create a
% family of objective functions. We can re-write the above function to 
% take three additional parameters to give the new minimization problem 
%
%     min f(x) = (a - b*x1^2 + x1^4/3)*x1^2 + x1*x2 + (-c + c*x2^2)*x2^2;
%      x
%
% a, b, and c are parameters to the objective function that act as
% constants during the optimization (they are not varied as part of the
% minimization). One can create an M-file called parameterized_objective.m 
% containing the following code:
%
%     function y = parameterized_objective(x,a,b,c)
%     y = (a - b*x(1)^2 + x(1)^4/3)*x(1)^2 + x(1)*x(2) + ...
%         (-c + c*x(2)^2)*x(2)^2;
%

%% Minimizing using additional arguments
% Again, we need to pass in a function handle to the objective function as
% well as a start point as the second argument. 
%
% PATTERNSEARCH will call our objective function with just one argument
% 'x', but our objective function has four arguments: x, a, b, c. We can
% use an anonymous function to capture the values of the additional
% arguments, the constants a, b, and c. We create a function handle
% 'ObjectiveFunction' to an anonymous function that takes one input 'x',
% but calls 'parameterized_objective' with x, a, b and c. The variables a,
% b, and c have values when the function handle 'ObjectiveFunction' is
% created, so these values are captured by the anonymous function.

  a = 4; b = 2.1; c = 4;    % define constant values
  ObjectiveFunction = @(x) parameterized_objective(x,a,b,c);
  X0 = [0.5 0.5];
  [x,fval] = patternsearch(ObjectiveFunction,X0)
   
%% Vectorizing your objective function
% Consider the above function again:
%
%     f(x) = (a - b*x1^2 + x1^4/3)*x1^2 + x1*x2 +(-c + c*x2^2)*x2^2;
%
% By default, the PATTERNSEARCH solver only passes in one point at a time
% to the objective function. However, sometimes speed up can be achieved
% if the objective function is vectorized to take a set of points and
% return a set of function values.
%
% For example if the solver wants to evaluate a set of five points in one
% call to this objective function, then it will call the objective with
% a matrix of size 5-by-2, i.e., 5 rows and 2 columns (recall 2 is the 
% number of variables). 
%
% Create an M-file called vectorized_objective.m with the following code:
%
%     function y = vectorized_objective(x,a,b,c)
%     y = zeros(size(x,1),1); %Pre-allocate y
%     for i = 1:size(x,1) % for the number of rows in x
%       x1 = x(i,1);
%       x2 = x(i,2);
%       y(i) = (a - b*x1^2 + x1^4/3)*x1^2 + x1*x2 + (-c + c*x2^2)*x2^2;
%     end
%
% This vectorized version of the objective function takes a matrix x
% with an arbitrary number of points, the rows of x, and returns
% a column vector y of length the same as the number of rows of x.
%
% To take advantage of the vectorized objective function, we need to tell
% PATTERNSEARCH that the objective is vectorized using the options
% structure that is created using PSOPTIMSET, and is passed in as the ninth
% argument.

  ObjectiveFunction = @(x) vectorized_objective(x,4,2.1,4);
  X0 = [0.5 0.5];
  options = psoptimset('Vectorized','on');
  [x,fval] = patternsearch(ObjectiveFunction,X0,[],[],[],[],[],[],options)
   
