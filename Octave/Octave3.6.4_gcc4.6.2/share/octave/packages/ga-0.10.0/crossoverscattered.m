## Copyright (C) 2008, 2009, 2011 Luca Favatella <slackydeb@gmail.com>
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
## Version: 7.0

function xoverKids = crossoverscattered (parents, options, nvars, FitnessFcn,
                                         unused,
                                         thisPopulation)

  ## simplified example (nvars == 4)
  ## p1 = [varA varB varC varD]
  ## p2 = [var1 var2 var3 var4]
  ## b = [1 1 0 1]
  ## child = [varA varB var3 varD]
  nc_parents = columns (parents);
  n_children = nc_parents / 2;
  p1(1:n_children, 1:nvars) = \
      thisPopulation(parents(1, 1:n_children), 1:nvars);
  p2(1:n_children, 1:nvars) = \
      thisPopulation(parents(1, n_children + (1:n_children)), 1:nvars);
  b(1:n_children, 1:nvars) = randi (1, n_children, nvars); ## TODO: test randi
  xoverKids(1:n_children, 1:nvars) = \
      b .* p1 + (ones (n_children, nvars) - b) .* p2;
endfunction


## number of input arguments
# TODO

## number of output arguments
# TODO

## type of arguments
# TODO

# TODO
