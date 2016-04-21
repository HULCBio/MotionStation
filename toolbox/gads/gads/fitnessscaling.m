%FITNESSSCALING Help on fitness scaling functions.
% 		
%   Fitness scaling is the process of mapping raw fitness scores
%   as returned by the fitness function, to an expected number of 
% 		children for each individual. It is important that the expected 
% 		number of children for each individual be in a "good" range. 
% 		
% 		If the expectations have too large a range, then the individuals with
%   the highest	expectation will reproduce too rapidly, taking over the 
%   population	gene pool too quickly, and preventing the Genetic Algorithm 
%   from searching other	areas of the solution space.	On the other hand, if 
%   the expectations do not vary enough, then all individuals have about the 
%   same chance of reproduction and the search will progress very slowly. 
% 		
% 		The fitness scaling function attempts to map an arbitrary fitness range 
% 		into a good expectation range. Experimentally, it has been found that if 
% 		the most fit individual reproduces about twice as often as the average 
% 		individual the Genetic Algorithm progresses about as quickly as possible.
% 		
% 		You can choose a fitness scaling function if you like. The OPTIONS
% 		structure has a field called 'FitnessScalingFcn' that you can assign. The
% 		toolbox contains several fitness scaling functions. The help for each of
% 		the provided fitness scaling functions describes the advantages and 
% 		disadvantages of that particular algorithm. If you do not specify a 
% 		fitness scaling function the default, FITSCALINGRANK, will be used.
% 		
% 		You can also write you own scaling function. You register a fitness 
%   scaling function in the options structure like this:
% 		
% 		  options = gaoptimset('FitnessScalingFcn',@yourFcnName);
%
%   Your fitness scaling function must have this calling syntax:
% 		
% 		  function expectations = yourFcnName(scores,nParents)
% 		
% 		scores will be an array of scalars, one for each member of the
% 		population. nParents is the number of parents needed from this
% 		population. Your result, expectations, should be a vector of scalars
% 		that is the same length as the scores vector, giving the expected number
% 		of offspring for each member of the population. The sum of the
% 		expectations should be equal to nParents.
% 		
% 		You can provide additional arguments to your function if you need to.
% 		Add your extra arguments to the end of your functions argument list:
% 		
% 		  function expectations = yourFcnName(scores,nParents,extraArg1,extraArg2)
% 		
% 		When you register your fitness scaling function in the options, use a cell
% 		array to group your function with it's additional arguments:
% 		
% 		  options = gaoptimset('FitnessScalingFcn',{@yourFcnName, 7.3, rand(4)}) ;
% 		
% 		These arguments will be passed to your function when it is	called.
% 		
% 		Note: Do not confuse a fitness scaling function with a fitness function, 
%   which	calculates the raw score for an individual.
 		
% 		Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2004/01/16 16:51:39 $
