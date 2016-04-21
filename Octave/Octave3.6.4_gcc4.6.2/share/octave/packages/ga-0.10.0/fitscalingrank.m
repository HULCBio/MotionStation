## Copyright (C) 2008, 2009 Luca Favatella <slackydeb@gmail.com>
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
## Version: 1.3.3

function expectation = fitscalingrank (scores, nParents)
  nr_scores = rows (scores);
  r(1, 1:nr_scores) = ranks (scores(1:nr_scores, 1));
                                #TODO
                                #ranks ([7,2,2]) == [3.0,1.5,1.5]
                                #is [3,1,2] (or [3,2,1]) useful? 
  expectation_wo_nParents(1, 1:nr_scores) = arrayfun (@(n) 1 / sqrt (n), r);
  expectation(1, 1:nr_scores) = \
      (nParents / sum (expectation_wo_nParents)) * \
      expectation_wo_nParents;
endfunction


## number of input arguments
# TODO

## number of output arguments
# TODO

## type of arguments
# TODO

# TODO

%!shared scores, nParents, expectation
%! scores = rand (20, 1);
%! nParents = 32;
%! expectation = fitscalingrank (scores, nParents);
%!assert (sum (expectation), nParents, 1e-9);
%!test
%! [trash index_min_scores] = min (scores);
%! [trash index_max_expectation] = max (expectation);
%! assert (index_min_scores, index_max_expectation);
%!test
%! [trash index_max_scores] = max (scores);
%! [trash index_min_expectation] = min (expectation);
%! assert (index_max_scores, index_min_expectation);