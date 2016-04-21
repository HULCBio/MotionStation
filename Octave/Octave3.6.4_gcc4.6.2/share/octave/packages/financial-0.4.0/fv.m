## Copyright (C) 1995-1998, 2000, 2002, 2005-2007 Kurt Hornik <Kurt.Hornik@wu-wien.ac.at>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} fv (@var{r}, @var{n}, @var{p}, @var{l}, @var{method})
## Return the future value at the end of period @var{n} of an investment
## which consists of @var{n} payments of @var{p} in each period,
## assuming an interest rate @var{r}.
##
## The optional argument @var{l} may be used to specify an
## additional lump-sum payment.
##
## The optional argument @var{method} may be used to specify whether the
## payments are made at the end (@code{"e"}, default) or at the
## beginning (@code{"b"}) of each period.
##
## Note that the rate @var{r} is specified as a fraction (i.e., 0.05,
## not 5 percent).
## @end deftypefn

function v = fv (r, n, p, l, m)

  if (nargin < 3 || nargin > 5)
    print_usage ();
  endif

  if (! (isscalar (r) && r > -1))
    error ("fv: r must be a scalar > -1");
  elseif (! (isscalar (n) && n > 0))
    error ("fv: n must be a positive scalar");
  elseif (! isscalar (p))
    error ("fv: p must be a scalar");
  endif

  if (r != 0)
    v = p * ((1 + r)^n - 1) / r;
  else
    v = p * n;
  endif

  if (nargin > 3)
    if (nargin == 5)
      if (! ischar (m))
        error ("fv: `method' must be a string");
      endif
    elseif ischar (l)
      m = l;
      l = 0;
    else
      m = "e";
    endif
    if strcmp (m, "b")
      v = v * (1 + r);
    endif
    if isscalar (l)
      v = v + fvl (r, n, l);
    else
      error ("fv: l must be a scalar");
    endif
  endif

endfunction
