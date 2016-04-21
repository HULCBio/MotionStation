## Copyright (C) 2008, 2009, 2010 Luca Favatella <slackydeb@gmail.com>
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

## -*- texinfo -*-
## @deftypefn{Function File} {@var{options} =} gaoptimset
## @deftypefnx{Function File} {@var{options} =} gaoptimset ('@var{param1}', @var{value1}, '@var{param2}', @var{value2}, @dots{})
## Create genetic algorithm options structure.
##
## @strong{Inputs}
## @table @var
## @item param
## Parameter to set. Unspecified parameters are set to their default
## values; specifying no parameters is allowed.
## @item value
## Value of @var{param}.
## @end table
##
## @strong{Outputs}
## @table @var
## @item options
## Structure containing the options, or parameters, for the genetic algorithm.
## @end table
##
## @strong{Options}
## @table @code
## @item CreationFcn
## @item CrossoverFcn
## @item CrossoverFraction
## @item EliteCount
## @item FitnessLimit
## @item FitnessScalingFcn
## @item Generations
## @item InitialPopulation
##       Can be partial.
## @item InitialScores
##       column vector | [] (default) . Can be partial.
## @item MutationFcn
## @item PopInitRange
## @item PopulationSize
## @item SelectionFcn
## @item TimeLimit
## @item UseParallel
##       "always" | "never" (default) . Parallel evaluation of objective function. TODO: parallel evaluation of nonlinear constraints
## @item Vectorized
##       "on" | "off" (default) . Vectorized evaluation of objective function. TODO: vectorized evaluation of nonlinear constraints
## @end table
##
## @seealso{ga}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 4.4.7

function options = gaoptimset (varargin)
  if ((nargout != 1) ||
      (mod (length (varargin), 2) == 1))
    print_usage ();
  else

    ## initialize the return variable to a structure with all parameters
    ## set to their default value
    options = __gaoptimset_default_options__ ();

    ## set custom options
    for i = 1:2:length (varargin)
      param = varargin{i};
      value = varargin{i + 1};
      if (! isfield (options, param))
        error ("wrong parameter");
      else
        options = setfield (options, param, value);
      endif
    endfor
  endif
endfunction


## number of input arguments
%!error options = gaoptimset ("odd number of arguments")
%!error options = gaoptimset ("Generations", 123, "odd number of arguments")

## number of output arguments
%!error gaoptimset ("Generations", 123)
%!error [a, b] = gaoptimset ("Generations", 123)

## type of arguments
# TODO
%!#error options = gaoptimset ("Vectorized", "bad value") # TODO: fix
%!#error options = gaoptimset ("UseParallel", "bad value") # TODO: fix

# TODO: structure/add tests below

%!assert (getfield (gaoptimset ("Generations", 123), "Generations"), 123)

%!test
%! options = gaoptimset ("EliteCount", 1,
%!                       "FitnessLimit", 1e-7,
%!                       "Generations", 1000,
%!                       "PopInitRange", [-5; 5],
%!                       "PopulationSize", 200);
%!
%! ## "CrossoverFraction" is not specified, so gaoptimset should put the default value: testing this too
%! assert ([(getfield (options, "CrossoverFraction"));
%!          (getfield (options, "EliteCount"));
%!          (getfield (options, "FitnessLimit"));
%!          (getfield (options, "Generations"));
%!          (getfield (options, "PopInitRange"));
%!          (getfield (options, "PopulationSize"))],
%!         [0.8; 1; 1e-7; 1000; [-5; 5]; 200])
