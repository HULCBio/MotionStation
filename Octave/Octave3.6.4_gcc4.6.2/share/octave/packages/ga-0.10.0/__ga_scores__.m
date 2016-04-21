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
## Version: 5.7

function Scores = __ga_scores__ (problem, Population)
  [nrP ncP] = size (Population);
  switch problem.options.Vectorized
    case "on" ## using vectorized evaluation
      switch problem.options.UseParallel
        case "always"
          warning ("'Vectorized' option is 'on': ignoring 'UseParallel' option, even if it is 'always'");
        case "never"
          ## Nothing.
        otherwise
          warning ("'Vectorized' option is 'on': ignoring invalid 'UseParallel' option value (it should be 'always' or 'never')");
      endswitch
      Scores = (problem.fitnessfcn (Population))(1:nrP, 1);
    case "off" ## not using vectorized evaluation
      switch problem.options.UseParallel
        case "always" ## using parallel evaluation
          error ("TODO: implement parallel evaluation of objective function");
        case "never" ## using serial evaluation (i.e. loop)
          tmp = zeros (nrP, 1);
          for index = 1:nrP
            tmp(index, 1) = problem.fitnessfcn (Population(index, 1:ncP));
          endfor
          Scores = tmp(1:nrP, 1);
        otherwise
          error ("'UseParallel' option must be 'always' or 'never'");
      endswitch
    otherwise
      error ("'Vectorized' option must be 'on' or 'off'");
  endswitch
endfunction
