## Copyright (C) 2008, 2010 Luca Favatella <slackydeb@gmail.com>
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
## Version: 1.3.1

function state = \
      __ga_problem_update_state_at_each_generation__ (state, problem,
                                                      private_state)
  if ((state.Generation > 0) || isempty (problem.options.InitialScores))
    state.Score(1:problem.options.PopulationSize, 1) = \
        __ga_scores__ (problem, state.Population);
  else ## (Generation == 0) && (! isempty (InitialScores))
    nrIS = rows (problem.options.InitialScores);
    #assert (rows (problem.options.InitialPopulation) <= problem.options.PopulationSize); ## DEBUG
    if (nrIS <= rows (problem.options.InitialPopulation))
      missing_rows = (nrIS+1):problem.options.PopulationSize;
      state.Score(1:problem.options.PopulationSize, 1) = \
          [problem.options.InitialScores(:, 1);
           (__ga_scores__ (problem, state.Population(missing_rows, :)))
           ];
    else
      error ("rows (InitialScores) > rows (InitialPopulation)");
    endif
  endif
  state.Expectation(1, 1:problem.options.PopulationSize) = \
      problem.options.FitnessScalingFcn (state.Score, private_state.nParents);
  state.Best(state.Generation + 1, 1) = min (state.Score);
endfunction


%!error
%! state.Generation = 0;
%! problem = struct ("fitnessfcn", @rastriginsfcn, "nvars", 2, "options", gaoptimset ("Generations", 10, "InitialScores", [0; 0; 0]));
%! unused = 0;
%! __ga_problem_update_state_at_each_generation__ (state, problem, unused);