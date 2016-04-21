## Copyright (C) 2008, 2010, 2012 Luca Favatella <slackydeb@gmail.com>
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
## @deftypefn{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB}, @var{nonlcon})
## @deftypefnx{Function File} {@var{x} =} ga (@var{fitnessfcn}, @var{nvars}, @var{A}, @var{b}, @var{Aeq}, @var{beq}, @var{LB}, @var{UB}, @var{nonlcon}, @var{options})
## @deftypefnx{Function File} {@var{x} =} ga (@var{problem})
## @deftypefnx{Function File} {[@var{x}, @var{fval}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}, @var{population}] =} ga (@dots{})
## @deftypefnx{Function File} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}, @var{population}, @var{scores}] =} ga (@dots{})
## Find minimum of function using genetic algorithm.
##
## @strong{Inputs}
## @table @var
## @item fitnessfcn
## The objective function to minimize. It accepts a vector @var{x} of
## size 1-by-@var{nvars}, and returns a scalar evaluated at @var{x}.
## @item nvars
## The dimension (number of design variables) of @var{fitnessfcn}.
## @item options
## The structure of the optimization parameters; can be created using
## the @code{gaoptimset} function. If not specified, @code{ga} minimizes
## with the default optimization parameters.
## @item problem
## A structure containing the following fields:
## @itemize @bullet
## @item @code{fitnessfcn}
## @item @code{nvars}
## @item @code{Aineq}
## @item @code{Bineq}
## @item @code{Aeq}
## @item @code{Beq}
## @item @code{lb}
## @item @code{ub}
## @item @code{nonlcon}
## @item @code{randstate}
## @item @code{randnstate}
## @item @code{solver}
## @item @code{options}
## @end itemize
## @end table
##
## @strong{Outputs}
## @table @var
## @item x
## The local unconstrained found minimum to the objective function,
## @var{fitnessfcn}.
## @item fval
## The value of the fitness function at @var{x}.
## @end table
##
## @seealso{gaoptimset}
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 6.0.1

function [x fval exitflag output population scores] = \
      ga (fitnessfcn_or_problem,
          nvars,
          A = [], b = [],
          Aeq = [], beq = [],
          LB = [], UB = [],
          nonlcon = [],
          options = gaoptimset ())
  if ((nargout > 6) ||
      (nargin < 1) ||
      (nargin == 3) ||
      (nargin == 5) ||
      (nargin == 7) ||
      (nargin > 10))
    print_usage ();
  else

    ## retrieve the problem structure
    if (nargin == 1)
      problem = fitnessfcn_or_problem;
    else
      problem.fitnessfcn = fitnessfcn_or_problem;
      problem.nvars = nvars;
      problem.Aineq = A;
      problem.Bineq = b;
      problem.Aeq = Aeq;
      problem.Beq = beq;
      problem.lb = LB;
      problem.ub = UB;
      problem.nonlcon = nonlcon;
      problem.randstate = rand ("state");
      problem.randnstate = randn ("state");
      problem.solver = "ga";
      problem.options = options;
    endif

    ## call the function that manages the problem structure
    [x fval exitflag output population scores] = __ga_problem__ (problem);
  endif
endfunction


## number of input arguments
%!shared f, nvars
%! f = @rastriginsfcn;
%! nvars = 2;
%!error x = ga ()
%!error x = ga (f)
%!error x = ga (f, nvars, [])
%!error x = ga (f, nvars, [], [], [])
%!error x = ga (f, nvars, [], [], [], [], [])
%!error x = ga (f, nvars, [], [], [], [], [], [], @(x) [[], []], gaoptimset (), [])

## number of output arguments
# TODO

## type of arguments
%!function f = ff (nvars)
%!  f = @(x) sum (x(:, 1:nvars) .** 2, 2);
%!error x = ga (ff (3), 2);
# TODO
# TODO: test that each field in the user-specified "problem" structure is checked


## flawless execution with right arguments
%!shared f, nvars
%! f = @rastriginsfcn;
%! nvars = 2;
%!function [C, Ceq] = nonlcon (x)
%!  C = [];
%!  Ceq = [];
%!test x = ga (f, nvars);
%!test x = ga (f, nvars, [], []);
%!test x = ga (f, nvars, ones (3, nvars), ones (3, 1));
%!test x = ga (f, nvars, [], [], [], []);
%!test x = ga (f, nvars, [], [], ones (4, nvars), ones (4, 1));
%!test x = ga (f, nvars, [], [], [], [], [], []);
%!test x = ga (f, nvars, [], [], [], [], - Inf (1, nvars), Inf (1, nvars));
%!test x = ga (f, nvars, [], [], [], [], - ones (1, nvars), ones (1, nvars));
%!test x = ga (f, nvars, [], [], [], [], [], [], @(x) [[], []]);
%!test x = ga (f, nvars, [], [], [], [], [], [], @nonlcon);
%!test x = ga (f, nvars, [], [], [], [], [], [], @(x) [[], []], gaoptimset ());
%!test # TODO: convert to error after implementing private ga-specific createOptimProblem. All fields in the user-specified structure should be checked
%! problem = struct ("fitnessfcn", @rastriginsfcn,
%!                   "nvars", 2,
%!                   "options", gaoptimset ());
%! x = ga (problem);

## flawless execution with any nvars
%!function f = ff (nvars)
%!  f = @(x) sum (x(:, 1:nvars) .** 2, 2);
%!test
%! nvars = 1;
%! x = ga (ff (nvars), nvars);
%!test
%! nvars = 2;
%! x = ga (ff (nvars), nvars);
%!test
%! nvars = 3;
%! x = ga (ff (nvars), nvars);

## flawless execution with any supported optimization parameter
## different from the default value
%!shared f, nvars, default_options
%! f = @rastriginsfcn;
%! nvars = 2;
%! default_options = gaoptimset ();
%!function [C, Ceq] = nonlcon (x)
%!  C = [];
%!  Ceq = [];
%!test
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, default_options);
%!test # TODO: use non-default value
%! options = gaoptimset ("CreationFcn", @gacreationuniform);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # TODO: use non-default value
%! options = gaoptimset ("CrossoverFcn", @crossoverscattered);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! options = gaoptimset ("CrossoverFraction", rand);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! ps = getfield (default_options, "PopulationSize");
%! options = gaoptimset ("EliteCount", randi ([0, ps]));
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! options = gaoptimset ("FitnessLimit", 1e-7);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # TODO: use non-default value
%! options = gaoptimset ("FitnessScalingFcn", @fitscalingrank);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! g = getfield (default_options, "Generations");
%! options = gaoptimset ("Generations", g + 1);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! ps = getfield (default_options, "PopulationSize");
%! ## Initial population can be partial
%! options_w_full_ip = \
%!     gaoptimset ("InitialPopulation", rand (ps,         nvars));
%! partial_ip = randi ([0, ps - 1]);
%! options_w_partial_ip = \
%!     gaoptimset ("InitialPopulation", rand (partial_ip, nvars));
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options_w_full_ip);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options_w_partial_ip);
%!test
%! ps = getfield (default_options, "PopulationSize");
%! ## Initial scores needs initial population
%!
%! options_w_full_ip_full_is = \
%!     gaoptimset ("InitialPopulation", rand (ps, nvars),
%!                 "InitialScores",     rand (ps, 1    ));
%! partial_ip = randi ([2, ps - 1]);
%! options_w_partial_ip_full_is = \
%!     gaoptimset ("InitialPopulation", rand (partial_ip, nvars),
%!                 "InitialScores",     rand (partial_ip, 1    ));
%!
%! ## Initial scores can be partial
%! partial_is_when_full_ip    = randi ([1, ps         - 1]);
%! partial_is_when_partial_ip = randi ([1, partial_ip - 1]);
%! options_w_full_ip_partial_is = \
%!     gaoptimset ("InitialPopulation", rand (ps,                      nvars),
%!                 "InitialScores",     rand (partial_is_when_full_ip, 1    ));
%! options_w_partial_ip_partial_is = \
%!     gaoptimset ("InitialPopulation", rand (partial_ip,                 nvars),
%!                 "InitialScores",     rand (partial_is_when_partial_ip, 1    ));
%!
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon,
%!         options_w_full_ip_full_is);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon,
%!         options_w_partial_ip_full_is);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon,
%!         options_w_full_ip_partial_is);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon,
%!         options_w_partial_ip_partial_is);
%!test # TODO: use non-default value
%! options = gaoptimset ("MutationFcn", {@mutationgaussian, 1, 1});
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! options = gaoptimset ("PopInitRange", [-2; 2]);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! options = gaoptimset ("PopulationSize", 200);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # TODO: use non-default value
%! options = gaoptimset ("SelectionFcn", @selectionstochunif);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # TODO: use non-default value
%! options = gaoptimset ("TimeLimit", Inf);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!error # TODO: this should become test
%! options = gaoptimset ("UseParallel", "always");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test
%! options = gaoptimset ("Vectorized", "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);


## error with conflicting optimization parameters: population size et al.
%!shared f, nvars
%! f = @rastriginsfcn;
%! nvars = 2;
%!function [C, Ceq] = nonlcon (x)
%!  C = [];
%!  Ceq = [];
%!error # Elite count cannot be greater than the population size
%! ps = 3;
%! bad_options = gaoptimset ("PopulationSize", ps,
%!                           "EliteCount",     ps + 1);
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error # The number of individuals in the initial population cannot be greater of the population size
%! ps = 3;
%! bad_options = gaoptimset ("PopulationSize",    ps,
%!                           "InitialPopulation", zeros (ps + 1, nvars));
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error # Initial scores cannot be specified without specifying the initial population too
%! bad_options = gaoptimset ("InitialScores", zeros (3, 1));
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error # The number of initial scores specified cannot be greater of the number of individuals in the initial population
%! ip = 3;
%! bad_options = gaoptimset ("InitialPopulation", zeros (ip, nvars),
%!                           "InitialScores",     zeros (ip + 1, 1));
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);

## error with vectorized evaluation of objective function. Vectorized
## objective functions are better because can be evaluated both as
## serial and vectorized.
%!shared nvars
%! nvars = 2;
%!function [C, Ceq] = nonlcon (x)
%!  C = [];
%!  Ceq = [];
%!function f = ff (nvars)
%!  f = @(x) sum (x(:, 1:nvars) .** 2, 2);
%!function f_not_vectorized = ff_not_vectorized (nvars)
%!  f_not_vectorized = @(x) sum (x(1:nvars) .** 2);
%!test # A non-vectorized objective function works when no vectorization is required
%! f = ff_not_vectorized (nvars);
%! options = gaoptimset ("Vectorized", "off");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!error # A non-vectorized objective function does not work when vectorization is required
%! f = ff_not_vectorized (nvars);
%! options = gaoptimset ("Vectorized", "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # A vectorized objective function works when no vectorization is required
%! f = ff (nvars);
%! options = gaoptimset ("Vectorized", "off");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!test # A vectorized objective function works when vectorization is required
%! f = ff (nvars);
%! options = gaoptimset ("Vectorized", "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);

## error with conflicting optimization parameters: parallel and
## vectorized evaluation of objective function
%!shared f, nvars
%! f = @rastriginsfcn;
%! nvars = 2;
%!function [C, Ceq] = nonlcon (x)
%!  C = [];
%!  Ceq = [];
%!test
%! options = gaoptimset ("UseParallel", "never",
%!                       "Vectorized",  "off");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!error # TODO: this should become test
%! options = gaoptimset ("UseParallel", "always",
%!                       "Vectorized",  "off");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!error
%! bad_options = gaoptimset ("UseParallel", "garbage",
%!                           "Vectorized",  "off");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!test
%! options = gaoptimset ("UseParallel", "never",
%!                       "Vectorized",  "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, options);
%!warning
%! bad_options = gaoptimset ("UseParallel", "always",
%!                           "Vectorized",  "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!warning
%! bad_options = gaoptimset ("UseParallel", "garbage",
%!                           "Vectorized",  "on");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error
%! bad_options = gaoptimset ("UseParallel", "never",
%!                           "Vectorized",  "garbage");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error
%! bad_options = gaoptimset ("UseParallel", "always",
%!                           "Vectorized",  "garbage");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
%!error
%! bad_options = gaoptimset ("UseParallel", "garbage",
%!                           "Vectorized",  "garbage");
%! x = ga (f, nvars, [], [], [], [], [], [], @nonlcon, bad_options);
