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
## Version: 1.1.1

function private_state = __ga_problem_private_state__ (options)
  private_state.ReproductionCount.elite = options.EliteCount;
  private_state.ReproductionCount.crossover = \
      fix (options.CrossoverFraction *
           (options.PopulationSize - options.EliteCount));
  private_state.ReproductionCount.mutation = \
      options.PopulationSize - \
      (private_state.ReproductionCount.elite +
       private_state.ReproductionCount.crossover);
  assert (private_state.ReproductionCount.elite +
          private_state.ReproductionCount.crossover +
          private_state.ReproductionCount.mutation,
          options.PopulationSize); ## DEBUG

  private_state.parentsCount.crossover = \
      2 * private_state.ReproductionCount.crossover;
  private_state.parentsCount.mutation = \
      1 * private_state.ReproductionCount.mutation;
  private_state.nParents = \
      private_state.parentsCount.crossover + \
      private_state.parentsCount.mutation;

  private_state.parentsSelection.crossover = \
      1:private_state.parentsCount.crossover;
  private_state.parentsSelection.mutation = \
      private_state.parentsCount.crossover + \
      (1:private_state.parentsCount.mutation);
  assert (length (private_state.parentsSelection.crossover) +
          length (private_state.parentsSelection.mutation),
          private_state.nParents); ## DEBUG
endfunction