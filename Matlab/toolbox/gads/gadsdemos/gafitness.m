%% Coding and minimizing a fitness function using the Genetic Algorithm
% This is a demonstration of how to create and minimize a fitness
% function using the Genetic Algorithm in the Genetic Algorithm and
% Direct Search Toolbox.

%   Copyright 2004 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $   $Date: 2004/03/22 23:53:44 $

%%  A simple fitness function
% Here we want to minimize a simple function of two variables
%
%     min f(x) = 100 * (x(1)^2 - x(2)) ^2 + (1 - x(1))^2;
%      x

%%  Coding the fitness function
% We create an M-file named simple_fitness.m with the following
% code in it:
%
%     function y = simple_fitness(x) 
%     y = 100 * (x(1)^2 - x(2)) ^2 + (1 - x(1))^2;
%
% The Genetic Algorithm solver assumes the fitness function will take one
% input x where x is a row vector with as many elements as number of
% variables in the problem.  The fitness function computes the value of
% the function and returns that scalar value in its one return argument
% y.

%% Minimizing using GA
% To minimize our fitness function using the GA function, we need to pass
% in a function handle to the fitness function as well as specifying the
% number of variables in the problem.

   FitnessFunction = @simple_fitness;
   numberOfVariables = 2;
   [x,fval] = ga(FitnessFunction,numberOfVariables)

%% 
% The x returned by the solver is the best point in the final
% population computed by GA. The fval is the value of the function
% @simple_fitness evaluated at the point x.

%%  A fitness function with additional arguments
% Sometimes we want our fitness function to be parameterized by extra
% arguments that act as constants during the optimization.  For example,
% in the previous fitness function, say we want to replace the
% constants 100 and 1 with parameters that we can change to create a
% family of objective functions. We can re-write the above function to 
% take two additional parameters to give the new minimization problem
%
%     min f(x) = a * (x(1)^2 - x(2)) ^2 + (b - x(1))^2;
%      x
%
% a and b are parameters to the fitness function that act as constants
% during the optimization (they are not varied as part of the
% minimization). One can create an M-file called parameterized_fitness.m
% containing the following code:
%
%     function y = parameterized_fitness(x,a,b)
%     y = a * (x(1)^2 - x(2)) ^2 + (b - x(1))^2;
%

%% Minimizing using additional arguments
% Again, we need to pass in a function handle to the fitness function
% as well as the number of variables as the second argument. 
%
% GA will call our fitness function with just one argument 'x', but 
% our fitness function has three arguments: x, a, b. We can use an anonymous
% function to capture the values of the additional arguments, the constants
% a and b. We create a function handle 'FitnessFunction' to an anonymous 
% function that takes one input 'x', but calls 'parameterized_fitness' with 
% x, a, and b. The variables a and b have values when the function handle
% 'FitnessFunction' is created, so these values are captured by the anonymous
% function.

   a = 100; b = 1; % define constant values
   FitnessFunction = @(x) parameterized_fitness(x,a,b);
   numberOfVariables = 2;
   [x,fval] = ga(FitnessFunction,numberOfVariables)

%% Vectorizing your fitness function
% Consider the previous fitness function again:
%
%     f(x) = a * (x(1)^2 - x(2)) ^2 + (b - x(1))^2;
%
% By default, the GA solver only passes in one point at a time to the
% fitness function. However, sometimes speed up can be achieved if the
% fitness function is vectorized to take a set of points and return a set
% of function values.
%
% For example if the solver wants to evaluate a set of five points in one
% call to this fitness function, then it will call the function with a
% matrix of size 5-by-2, i.e. , 5 rows and 2 columns (recall 2 is the number
% of variables).
%
% Create an M-file called vectorized_fitness.m with the following code:
%
%     function y = vectorized_fitness(x,a,b)
%     y = zeros(size(x,1),1); %Pre-allocate y
%     for i = 1:size(x,1)
%       x1 = x(i,1);
%       x2 = x(i,2);
%       y(i) = a * (x1^2 - x2) ^2 + (b - x1)^2;
%     end
%
% This vectorized version of the fitness function takes a matrix x with
% an arbitrary number of points, the rows of x, and returns a column
% vector y of length the same as the number of rows of x. 
%
% We need to specify that the fitness function is vectorized using the
% options structure created using GAOPTIMSET. The options structure is
% passed in as the third argument.
   
   FitnessFunction = @(x) vectorized_fitness(x,100,1);
   numberOfVariables = 2;
   options = gaoptimset('Vectorized','on');
   [x,fval] = ga(FitnessFunction,numberOfVariables,options)
