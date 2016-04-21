function pop = create_permutations(NVARS,FitnessFcn,options)
%   This function creates a population of permutations
%   POP = CREATE_PERMUTATION(NVARS,FITNESSFCN,OPTIONS) creates a population
%  of permutations POP each with a length of NVARS. 
%
%   The arguments to the function are 
%     NVARS: Number of variables 
%     FITNESSFCN: Fitness function 
%     OPTIONS: Options structure used by the GA

%   Copyright 2004 The MathWorks, Inc.
%   $Revision: 1.1.4.1 $  $Date: 2004/03/26 13:25:59 $

totalPopulationSize = sum(options.PopulationSize);
n = NVARS;
pop = cell(totalPopulationSize,1);
for i = 1:totalPopulationSize
    pop{i} = randperm(n); 
end
