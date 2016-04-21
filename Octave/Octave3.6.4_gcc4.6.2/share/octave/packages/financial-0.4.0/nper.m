## Copyright (C) 1995-1998, 2000, 2002, 2004-2007 Kurt Hornik <Kurt.Hornik@wu-wien.ac.at>
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
## @deftypefn {Function File} {} nper (@var{r}, @var{p}, @var{a}, @var{l}, @var{method})
## Return the number of regular payments of @var{p} necessary to
## amortize @var{a} loan of amount @var{a} and interest @var{r}.
##
## The optional argument @var{l} may be used to specify an additional
## lump-sum payment of @var{l} made at the end of the amortization time.
##
## The optional argument @var{method} may be used to specify whether
## payments are made at the end (@var{"e"}, default) or at the beginning
## (@var{"b"}) of each period.
##
## Note that the rate @var{r} is specified as a fraction (i.e., 0.05,
## not 5 percent).
## @seealso{pv, pmt, rate, npv}
## @end deftypefn

function n = nper (r, p, a, l, m)

  if (nargin < 3 || nargin > 5)
    print_usage ();
  endif

  if (! (isscalar (r) && r > -1))
    error ("nper: r must be a scalar > -1");
  elseif (! isscalar (p))
    error ("nper: p must be a scalar");
  elseif (! isscalar (a))
    error ("nper: a must be a scalar");
  endif

  if (nargin == 5)
    if (! ischar (m))
      error ("nper: `method' must be a string");
    endif
  elseif (nargin == 4)
    if (ischar (l))
      m = l;
      l = 0;
    else
      m = "e";
    endif
  else
    m = "e";
    l = 0;
  endif

  if (strcmp (m, "b"))
    p = p * (1 + r);
  endif

  q = (p - r * a) / (p - r * l);

  if (q > 0)
    n = - log (q) / log (1 + r);
  else
    n = Inf;
  endif

endfunction
