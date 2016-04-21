% Genetic Algorithm Direct Search Toolbox
% Version 1.0.1 (R14) 05-May-2004
%
% Solvers
%   ga                    - Genetic algorithm solver.
%   gatool                - Genetic algorithm GUI.
%   patternsearch         - Pattern search solver.
%   psearchtool           - Pattern search GUI
%
% Accessing options
%   gaoptimset            - Create/modify a genetic algorithm options 
%                           structure.
%   gaoptimget            - Get options for genetic algorithm.
%   psoptimset            - Create/modify a pattern search options
%                           structure.
%   psoptimget            - Get options for pattern search.
% 
% Fitness scaling for genetic algorithm 
%   fitscalingshiftlinear - Offset and scale fitness to desired range.
%   fitscalingprop        - Proportional fitness scaling.
%   fitscalingrank        - Rank based fitness scaling.
%   fitscalingtop         - Top individuals reproduce equally.
%
% Selection for genetic algorithm
%   selectionremainder    - Remainder stochastic sampling without replacement.
%   selectionroulette     - Choose parents using roulette wheel.
%   selectionstochunif    - Choose parents using stochastic universal
%                           sampling (SUS). 
%   selectiontournament   - Each parent is the best of a random set.
%   selectionuniform      - Choose parents at random.
%
% Crossover (recombination) functions for genetic algorithm.
%   crossoverheuristic    - Move from worst parent to slightly past best 
%                           parent.
%   crossoverintermediate - Weighted average of the parents.
%   crossoverscattered    - Position independent crossover function.
%   crossoversinglepoint  - Single point crossover.
%   crossovertwopoint     - Two point crossover.
%
% Mutation functions for genetic algorithm
%   mutationgaussian      - Gaussian mutation.
%   mutationuniform       - Uniform multi-point mutation.
%
% Plot Functions for genetic algorithm
%   gaplotbestf           - Plots the best score and the mean score.
%   gaplotbestindiv       - Plots the best individual in every generation
%                           as a bar plot.
%   gaplotdistance        - Averages several samples of distances between 
%                           individuals.
%   gaplotexpectation     - Plots raw scores vs the expected number of 
%                           offspring.
%   gaplotgenealogy       - Plot the ancestors of every individual.
%   gaplotrange           - Plots the min, mean, and max of the scores.
%   gaplotscordiversity   - Plots a histogram of this generations scores.
%   gaplotscores          - Plots the scores of every member of the population.
%   gaplotselection       - A histogram of parents.
%   gaplotstopping        - Display stopping criteria levels.
%
% Output Functions for genetic algorithm
%   gaoutputgen           - Displays generation number and best function value
%                           in a separate window.
%   gaoutputoptions       - Prints all of the non-default options settings.
%
% Custom search functions for pattern search 
%   searchlhs             - Implements latin hypercube sampling as a search
%                           method.
%   searchneldermead      - Implements nelder-mead simplex method
%                           (FMINSEARCH) to use as a search method.
%   searchga              - Implements genetic algorithm (GA) to use as a 
%                           search method.
%   searchfcntemplate     - Template file for a custom search method.
%
% Plot Functions for pattern search
%   psplotbestf           - Plots best function value.
%   psplotbestx           - Plots current point in every iteration as a bar
%                           plot.
%   psplotfuncount        - Plots the number of function evaluation in every
%                           iteration.
%   psplotmeshsize        - Plots mesh size used in every iteration.
%
% Output functions for pattern search 
%   psoutputhistory       - Displays iteration number, number of function 
%                           evaluations, function value, mesh size and
%                           method used in every iteration in a separate
%                           window.
%   psoutputfcntemplate   - Template file for a custom output function.
%
% Utility functions
%   allfeasible           - Filter infeasible points.
%   gacreationuniform     - Create the initial population for genetic algorithm.
%   gray2int              - Convert a gray code array to an integer.
%   lhspoint              - Generates latin hypercube design point.
%   nextpoint             - Return the best iterate assuming feasibility.
%
% Help files for genetic algorithm
%   fitnessfunction       - Help on fitness functions.
%   fitnessscaling        - Help on fitness scaling.

%   Copyright 2004 The MathWorks, Inc.
%   $Revision  $   $Date: 2004/01/08 20:54:10 $
