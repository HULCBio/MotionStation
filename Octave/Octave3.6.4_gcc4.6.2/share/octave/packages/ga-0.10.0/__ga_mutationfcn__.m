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
## Version: 1.3

function mutationChildren = \
      __ga_mutationfcn__ (parents, options, nvars, FitnessFcn,
                          state, thisScore,
                          thisPopulation)
  mutationChildren(1:(columns (parents)), 1:nvars) = \
      options.MutationFcn{1, 1} (parents(1, :), options, nvars, FitnessFcn,
                                 state, thisScore,
                                 thisPopulation(:, 1:nvars));
endfunction