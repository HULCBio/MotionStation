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

function parents = selectionstochunif (expectation, nParents, options)
  nc_expectation = columns (expectation);
  line(1, 1:nc_expectation) = cumsum (expectation(1, 1:nc_expectation));
  max_step_size = line(1, nc_expectation);
  step_size = max_step_size * rand ();
  steps(1, 1:nParents) = rem (step_size * (1:nParents), max_step_size);
  for index_steps = 1:nParents ## fix an entry of the steps (or parents) vector
    #assert (steps(1, index_steps) < max_step_size); ## DEBUG
    index_line = 1;
    while (steps(1, index_steps) >= line(1, index_line))
      #assert ((index_line >= 1) && (index_line < nc_expectation)); ## DEBUG
      index_line++;
    endwhile
    parents(1, index_steps) = index_line;
  endfor
endfunction


## number of input arguments
# TODO

## number of output arguments
# TODO

## type of arguments
# TODO

# TODO
