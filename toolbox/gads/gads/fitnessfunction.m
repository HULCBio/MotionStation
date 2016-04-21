%FITNESSFUNCTION Help on fitness functions.
% 	
% 	A fitness function is the function to be minimized by the Genetic Algorithm. 
%   A fitness function has the following syntax:
% 	
% 	 function SCORES = yourFitnessFcn(POP)
% 	
% 	POP is the population to be evaluated.  By default, POP is a vector of size
% 	1-by-numberOfVariables and SCORES is a scalar that represents POP evaluated
% 	by the fitness function.
%
%   If your fitness function is vectorized, that is it can take a matrix
%   POP, then it will often run faster than the non-vectorized version.  In
%   this case, POP is a matrix of size POPULATIONSIZE-by-numberOfVariables, and  
%   SCORES is a vector of scores, one for each row of POP.  To take
%   advantage of the vectorization, set the Vectorized field of GAOPTIMSET
%   to 'on':
%       opt = gaoptimset('Vectorized','on');
%       x = ga(@yourFitnessFcn,numberOfVariables,opt);
% 	
% 	To provide additional arguments to your fitness function, add your extra 
%   arguments to the end of your functions argument list:
% 	    function SCORES = yourFitnessFcn(POP,extraArg1,extraArg2)
%
%   GA will call your fitness function with just the one argument 'x', but 
%   your fitness function has additional arguments: extraArg1 and extraArg2. 
%   We can use an anonymous function to capture the values of the additional
%   arguments, the constants extraArg1 and extraArg2. We create a function
%   handle 'FitnessFcn' to an anonymous function that takes one input 'x', 
%   but calls 'yourFitnessFcn' with x, extraArg1, and extraArg2. The variables
%   extraArg1 and extraArg2 have values when the function handle 'FitnessFcn'
%   is created, so these values are captured by the anonymous function.
%
%       extraArg1  = ... % extraArg1 value is defined here
%       extraArg2  = ... % extraArg2 value is defined here
% 	    FitnessFcn = @(POP) yourFitnessFcn(POP,extraArg1,extraArg2);
% 	    [X,FVAL]   =  ga(FitnessFcn,numberOfVariables,options)
%
%   Example:
%     If your fitness function is vectorized, then if you have a
%     population size of 4 with 2 number of variable 2, your input to your 
%     fitness function is
%               POP = [1   3.4
%                     3   -4.1
%                     2    0
%                     3.4  2.1]
%    Then the vector SCORES is a column vector of length 4 
%              SCORES = [ 3.2; 1.2; 4.9; 1.2] 
%
%    See also ACKLEYFCN.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2004/03/22 23:54:00 $
