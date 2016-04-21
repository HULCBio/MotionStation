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
## Version: 1.1

function [x fval exitflag output population scores] = \
      __ga_problem_return_variables__ (state, problem)
  [trash IndexMinScore] = min (state.Score);
  x = state.Population(IndexMinScore, 1:problem.nvars);

  fval = problem.fitnessfcn (x);

                                #TODO exitflag

  ## output.randstate and output.randnstate must be assigned at the
  ## start of the algorithm
  output.generations = state.Generation;
                                #TODO output.funccount
                                #TODO output.message
                                #TODO output.maxconstraint

  population = state.Population;

  scores = state.Score;
endfunction