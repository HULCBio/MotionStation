## Copyright (C) 2008-2012 VZLU Prague, a.s.
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.
##
## Author: Jaroslav Hajek <highegg@gmail.com>

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{x}, @var{fval}, @var{info}, @var{output}] =} fminbnd (@var{fun}, @var{a}, @var{b}, @var{options})
## Find a minimum point of a univariate function.  @var{fun} should be a
## function
## handle or name.  @var{a}, @var{b} specify a starting interval.  @var{options}
## is a
## structure specifying additional options.  Currently, @code{fminbnd}
## recognizes these options: @code{"FunValCheck"}, @code{"OutputFcn"},
## @code{"TolX"}, @code{"MaxIter"}, @code{"MaxFunEvals"}.
## For description of these options, see @ref{doc-optimset,,optimset}.
##
## On exit, the function returns @var{x}, the approximate minimum point
## and @var{fval}, the function value thereof.
## @var{info} is an exit flag that can have these values:
##
## @itemize
## @item 1
## The algorithm converged to a solution.
##
## @item 0
## Maximum number of iterations or function evaluations has been exhausted.
##
## @item -1
## The algorithm has been terminated from user output function.
## @end itemize
## @seealso{optimset, fzero, fminunc}
## @end deftypefn

## This is patterned after opt/fmin.f from Netlib, which in turn is taken from
## Richard Brent: Algorithms For Minimization Without Derivatives, Prentice-Hall (1973)

## PKG_ADD: ## Discard result to avoid polluting workspace with ans at startup.
## PKG_ADD: [~] = __all_opts__ ("fminbnd");

function [x, fval, info, output] = fminbnd (fun, xmin, xmax, options = struct ())

  ## Get default options if requested.
  if (nargin == 1 && ischar (fun) && strcmp (fun, 'defaults'))
    x = optimset ("MaxIter", Inf, "MaxFunEvals", Inf, "TolX", 1e-8, \
    "OutputFcn", [], "FunValCheck", "off");
    return;
  endif

  if (nargin < 2 || nargin > 4)
    print_usage ();
  endif

  if (ischar (fun))
    fun = str2func (fun, "global");
  endif

  ## TODO
  ## displev = optimget (options, "Display", "notify");
  funvalchk = strcmpi (optimget (options, "FunValCheck", "off"), "on");
  outfcn = optimget (options, "OutputFcn");
  tolx = optimget (options, "TolX", 1e-8);
  maxiter = optimget (options, "MaxIter", Inf);
  maxfev = optimget (options, "MaxFunEvals", Inf);

  if (funvalchk)
    ## Replace fun with a guarded version.
    fun = @(x) guarded_eval (fun, x);
  endif

  ## The default exit flag if exceeded number of iterations.
  info = 0;
  niter = 0;
  nfev = 0;
  sqrteps = eps (class (xmin + xmax));

  c = 0.5*(3-sqrt(5));
  a = xmin; b = xmax;
  v = a + c*(b-a);
  w = x = v;
  e = 0;
  fv = fw = fval = fun (x);
  nfev++;

  while (niter < maxiter && nfev < maxfev)
    xm = 0.5*(a+b);
    ## FIXME: the golden section search can actually get closer than sqrt(eps)...
    ## sometimes. Sometimes not, it depends on the function. This is the strategy
    ## from the Netlib code. Something yet smarter would be good.
    tol = 2 * sqrteps * abs (x) + tolx / 3;
    if (abs (x - xm) <= (2*tol - 0.5*(b-a)))
      info = 1;
      break;
    endif

    if (abs (e) > tol)
      dogs = false;
      ## Try inverse parabolic step.
      r = (x - w)*(fval - fv);
      q = (x - v)*(fval - fw);
      p = (x - v)*q - (x - w)*r;
      q = 2*(q - r);
      p *= -sign (q);
      q = abs (q);
      r = e;
      e = d;

      if (abs (p) < abs (0.5*q*r) && p > q*(a-x) && p < q*(b-x))
        ## The parabolic step is acceptable.
        d = p / q;
        u = x + d;

        ## f must not be evaluated too close to ax or bx.
        if (min (u-a, b-u) < 2*tol)
          d = tol * (sign (xm - x) + (xm == x));
        endif
      else
        dogs = true;
      endif
    else
      dogs = true;
    endif
    if (dogs)
      ## Default to golden section step.
      e = ifelse (x >= xm, a - x, b - x);
      d = c * e;
    endif

     ## f must not be evaluated too close to x.
     u = x + max (abs (d), tol) * (sign (d) + (d == 0));

     fu = fun (u);
     nfev++;
     niter++;

     ## update  a, b, v, w, and x

     if (fu <= fval)
       if (u < x)
         b = x;
       else
         a = x;
       endif
       v = w; fv = fw;
       w = x; fw = fval;
       x = u; fval = fu;
     else
       ## The following if-statement was originally executed even if fu == fval.
       if (u < x)
         a = u;
       else
         b = u;
       endif
       if (fu <= fw || w == x)
         v = w; fv = fw;
         w = u; fw = fu;
       elseif (fu <= fv || v == x || v == w)
         v = u;
         fv = fu;
       endif
     endif

    ## If there's an output function, use it now.
    if (outfcn)
      optv.funccount = nfev;
      optv.fval = fval;
      optv.iteration = niter;
      if (outfcn (x, optv, "iter"))
        info = -1;
        break;
      endif
    endif
  endwhile

  output.iterations = niter;
  output.funcCount = nfev;
  output.bracket = [a, b];
  ## FIXME: bracketf possibly unavailable.

endfunction

## An assistant function that evaluates a function handle and checks for
## bad results.
function fx = guarded_eval (fun, x)
  fx = fun (x);
  fx = fx(1);
  if (! isreal (fx))
    error ("fminbnd:notreal", "fminbnd: non-real value encountered");
  elseif (isnan (fx))
    error ("fminbnd:isnan", "fminbnd: NaN value encountered");
  endif
endfunction

%!shared opt0
%! opt0 = optimset ("tolx", 0);
%!assert (fminbnd (@cos, pi/2, 3*pi/2, opt0), pi, 10*sqrt(eps))
%!assert (fminbnd (@(x) (x - 1e-3)^4, -1, 1, opt0), 1e-3, 10e-3*sqrt(eps))
%!assert (fminbnd (@(x) abs(x-1e7), 0, 1e10, opt0), 1e7, 10e7*sqrt(eps))
%!assert (fminbnd (@(x) x^2 + sin(2*pi*x), 0.4, 1, opt0), fzero (@(x) 2*x + 2*pi*cos(2*pi*x), [0.4, 1], opt0), sqrt(eps))
