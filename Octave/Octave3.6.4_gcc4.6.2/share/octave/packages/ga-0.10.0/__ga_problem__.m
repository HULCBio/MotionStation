## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 5.9

function [x fval exitflag output population scores] = __ga_problem__ (problem)

  ## first instruction
  state.StartTime = time ();

  ## second instruction
  output = struct ("randstate", rand ("state"),
                   "randnstate", randn ("state"));

  ## instructions not to be executed at each generation
  state.Population(1:problem.options.PopulationSize, 1:problem.nvars) = \
      __ga_initial_population__ (problem.nvars,
                                 problem.fitnessfcn,
                                 problem.options);
  state.Generation = 0;
  private_state = __ga_problem_private_state__ (problem.options);
  state.Selection = __ga_problem_state_selection__ (private_state,
                                                    problem.options);

  ## instructions to be executed at each generation
  state = __ga_problem_update_state_at_each_generation__ (state, problem,
                                                          private_state);

  NextPopulation = zeros (problem.options.PopulationSize, problem.nvars);
  while (! __ga_stop__ (problem, state)) ## fix a generation

    ## elite
    if (private_state.ReproductionCount.elite > 0)
      [trash IndexSortedScores] = sort (state.Score);
      NextPopulation(state.Selection.elite, 1:problem.nvars) = \
          state.Population \
          (IndexSortedScores(1:private_state.ReproductionCount.elite, 1),
           1:problem.nvars);
    endif

    ## selection for crossover and mutation
    parents(1, 1:private_state.nParents) = __ga_selectionfcn__ \
        (state.Expectation, private_state.nParents, problem.options);

    ## crossover
    if (private_state.ReproductionCount.crossover > 0)
      NextPopulation(state.Selection.crossover, 1:problem.nvars) = \
          __ga_crossoverfcn__ \
          (parents(1, private_state.parentsSelection.crossover),
           problem.options, problem.nvars, problem.fitnessfcn,
           false, ## unused
           state.Population);
    endif

    ## mutation
    if (private_state.ReproductionCount.mutation > 0)
      NextPopulation(state.Selection.mutation, 1:problem.nvars) = \
          __ga_mutationfcn__ \
          (parents(1, private_state.parentsSelection.mutation),
           problem.options, problem.nvars, problem.fitnessfcn,
           state, state.Score,
           state.Population);
    endif

    ## update state structure
    state.Population(1:problem.options.PopulationSize,
                     1:problem.nvars) = NextPopulation;
    state.Generation++;
    state = __ga_problem_update_state_at_each_generation__ (state, problem,
                                                            private_state);
  endwhile

  [x fval exitflag output population scores] = \
      __ga_problem_return_variables__ (state, problem);
endfunction

                                #state structure fields
                                #DONE state.Population
                                #DONE state.Score
                                #DONE state.Generation
                                #DONE state.StartTime
                                #state.StopFlag
                                #DONE state.Selection
                                #DONE state.Expectation
                                #DONE state.Best
                                #state.LastImprovement
                                #state.LastImprovementTime
                                #state.NonlinIneq
                                #state.NonlinEq